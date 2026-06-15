from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import (
    AuthResponse,
    ForgotPasswordRequest,
    GoogleLoginRequest,
    LoginRequest,
    RefreshRequest,
    SignupRequest,
    TokenPair,
    UserOut,
)
from app.services import auth_service

logger = logging.getLogger("app.auth")
router = APIRouter()


@router.post("/signup", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def signup(data: SignupRequest, db: AsyncSession = Depends(get_db)):
    logger.info("User signup requested for email: %s", data.email)
    user, tokens = await auth_service.signup(db, data)
    logger.info("User signup successful for email: %s", data.email)
    return AuthResponse(user=UserOut.model_validate(user), tokens=tokens)


@router.post("/login", response_model=AuthResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    logger.info("User login requested for email: %s", data.email)
    user, tokens = await auth_service.login(db, data.email, data.password)
    logger.info("User login successful for email: %s", data.email)
    return AuthResponse(user=UserOut.model_validate(user), tokens=tokens)


@router.post("/google", response_model=AuthResponse)
async def google_login(data: GoogleLoginRequest, db: AsyncSession = Depends(get_db)):
    user, tokens = await auth_service.login_with_google(db, data.id_token)
    return AuthResponse(user=UserOut.model_validate(user), tokens=tokens)


@router.post("/refresh", response_model=TokenPair)
async def refresh(data: RefreshRequest, db: AsyncSession = Depends(get_db)):
    return await auth_service.refresh(db, data.refresh_token)


@router.post("/forgot-password", status_code=status.HTTP_202_ACCEPTED)
async def forgot_password(data: ForgotPasswordRequest):
    # Stub: integrate Supabase Auth recovery / email provider in a later phase.
    return {"message": "If that email exists, a reset link has been sent."}


@router.get("/me", response_model=UserOut)
async def me(user: User = Depends(get_current_user)):
    return UserOut.model_validate(user)
