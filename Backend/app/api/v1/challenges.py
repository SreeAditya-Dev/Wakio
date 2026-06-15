from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.challenge import ChallengeOut
from app.services import challenge_service

router = APIRouter()


@router.get("/today", response_model=ChallengeOut)
async def todays_challenge(user: User = Depends(get_current_user)):
    return await challenge_service.get_today(user.id)
