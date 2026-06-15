"""Shared FastAPI dependencies."""
from __future__ import annotations

import uuid

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import ACCESS, JWTError, decode_token
from app.db.session import get_db
from app.models.user import User

bearer = HTTPBearer(auto_error=True)

_credentials_exc = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    try:
        payload = decode_token(creds.credentials)
        if payload.get("type") != ACCESS:
            raise _credentials_exc
        user_id = uuid.UUID(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise _credentials_exc

    user = await db.get(User, user_id)
    if user is None:
        raise _credentials_exc
    return user
