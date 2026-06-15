"""Authentication business logic."""
from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    REFRESH,
    JWTError,
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.streak import Streak
from app.models.user import User
from app.schemas.auth import SignupRequest, TokenPair


async def _get_by_email(db: AsyncSession, email: str) -> User | None:
    res = await db.execute(select(User).where(User.email == email.lower()))
    return res.scalar_one_or_none()


def _issue_tokens(user: User) -> TokenPair:
    return TokenPair(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )


async def signup(db: AsyncSession, data: SignupRequest) -> tuple[User, TokenPair]:
    if await _get_by_email(db, data.email):
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
    user = User(
        email=data.email.lower(),
        name=data.name,
        password_hash=hash_password(data.password),
    )
    db.add(user)
    await db.flush()
    db.add(Streak(user_id=user.id))
    await db.flush()
    await db.refresh(user)
    return user, _issue_tokens(user)


async def login(db: AsyncSession, email: str, password: str) -> tuple[User, TokenPair]:
    user = await _get_by_email(db, email)
    if not user or not user.password_hash or not verify_password(password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid email or password")
    return user, _issue_tokens(user)


async def refresh(db: AsyncSession, refresh_token: str) -> TokenPair:
    try:
        payload = decode_token(refresh_token)
        if payload.get("type") != REFRESH:
            raise ValueError
        user = await db.get(User, __import__("uuid").UUID(payload["sub"]))
    except (JWTError, KeyError, ValueError):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token")
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token")
    return _issue_tokens(user)


async def login_with_google(db: AsyncSession, id_token_str: str) -> tuple[User, TokenPair]:
    from google.auth.transport import requests as g_requests
    from google.oauth2 import id_token as g_id_token

    from app.core.config import settings

    try:
        info = g_id_token.verify_oauth2_token(
            id_token_str, g_requests.Request(), settings.GOOGLE_CLIENT_ID
        )
    except ValueError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid Google token")

    email = info["email"].lower()
    user = await _get_by_email(db, email)
    if user is None:
        user = User(
            email=email,
            name=info.get("name", email.split("@")[0]),
            avatar_url=info.get("picture"),
            google_sub=info.get("sub"),
        )
        db.add(user)
        await db.flush()
        db.add(Streak(user_id=user.id))
        await db.flush()
        await db.refresh(user)
    return user, _issue_tokens(user)
