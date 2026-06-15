"""Password hashing + JWT creation/verification.

Tokens are signed with the **Supabase JWT secret** (HS256) and carry the
`aud="authenticated"` + `role="authenticated"` claims, so the same access token
authorizes both this API and Supabase Realtime/Storage (RLS on auth.uid()).
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

ACCESS = "access"
REFRESH = "refresh"


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def _create_token(subject: str, token_type: str, expires_delta: timedelta) -> str:
    now = datetime.now(timezone.utc)
    payload: dict[str, Any] = {
        "sub": str(subject),
        "aud": "authenticated",      # required by Supabase RLS
        "role": "authenticated",     # required by Supabase RLS
        "type": token_type,
        "iat": now,
        "exp": now + expires_delta,
        "jti": str(uuid.uuid4()),
    }
    return jwt.encode(
        payload, settings.SUPABASE_JWT_SECRET, algorithm=settings.JWT_ALGORITHM
    )


def create_access_token(subject: str) -> str:
    return _create_token(
        subject, ACCESS, timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )


def create_refresh_token(subject: str) -> str:
    return _create_token(
        subject, REFRESH, timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    )


def decode_token(token: str) -> dict[str, Any]:
    """Decode + validate a token. Raises jose.JWTError on failure."""
    return jwt.decode(
        token,
        settings.SUPABASE_JWT_SECRET,
        algorithms=[settings.JWT_ALGORITHM],
        audience="authenticated",
    )


__all__ = [
    "hash_password",
    "verify_password",
    "create_access_token",
    "create_refresh_token",
    "decode_token",
    "JWTError",
    "ACCESS",
    "REFRESH",
]
