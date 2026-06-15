from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.alarm import Alarm
from app.models.alarm_history import AlarmHistory
from app.models.user import User
from app.schemas.alarm_history import AlarmHistoryCreate, AlarmHistoryOut, RecheckUpdate
from app.services import streak_service

router = APIRouter()


@router.get("", response_model=list[AlarmHistoryOut])
async def list_history(
    user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
):
    res = await db.execute(
        select(AlarmHistory)
        .where(AlarmHistory.user_id == user.id)
        .order_by(AlarmHistory.fired_at.desc())
    )
    return list(res.scalars())


@router.post("", response_model=AlarmHistoryOut, status_code=status.HTTP_201_CREATED)
async def create_history(
    data: AlarmHistoryCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    payload = data.model_dump(exclude_none=True)
    history_id = payload.pop("id", None)

    # alarm_id is a soft reference (SET NULL on delete) — if the alarm hasn't
    # synced to this account yet, drop it rather than fail the whole record.
    alarm_id = payload.get("alarm_id")
    if alarm_id is not None:
        alarm = await db.get(Alarm, alarm_id)
        if alarm is None or alarm.user_id != user.id:
            payload["alarm_id"] = None

    # Honor a client-supplied id for offline-first sync; upsert if it already exists.
    if history_id:
        existing = await db.get(AlarmHistory, history_id)
        if existing and existing.user_id == user.id:
            for k, v in payload.items():
                setattr(existing, k, v)
            await db.flush()
            await streak_service.recompute(db, user.id)
            await db.refresh(existing)
            return existing

    history = AlarmHistory(
        user_id=user.id, **({"id": history_id} if history_id else {}), **payload
    )
    db.add(history)
    await db.flush()
    await streak_service.recompute(db, user.id)
    await db.refresh(history)
    return history


@router.patch("/{history_id}/recheck", response_model=AlarmHistoryOut)
async def update_recheck(
    history_id: uuid.UUID,
    data: RecheckUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    history = await db.get(AlarmHistory, history_id)
    if history is None or history.user_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "History record not found")

    history.recheck_status = data.recheck_status
    history.recheck_at = data.recheck_at
    await db.flush()
    await streak_service.recompute(db, user.id)
    await db.refresh(history)
    return history
