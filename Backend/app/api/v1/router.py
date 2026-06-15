"""Aggregate v1 API router."""
from fastapi import APIRouter

from app.api.v1 import alarm_history, alarms, auth, challenges, detection

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(alarms.router, prefix="/alarms", tags=["alarms"])
api_router.include_router(
    alarm_history.router, prefix="/alarm-history", tags=["alarm-history"]
)
api_router.include_router(challenges.router, prefix="/challenges", tags=["challenges"])
api_router.include_router(detection.router, prefix="/detection", tags=["detection"])
