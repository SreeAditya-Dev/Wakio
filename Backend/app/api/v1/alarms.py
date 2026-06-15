from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.alarm import Alarm
from app.models.user import User
from app.schemas.alarm import AlarmCreate, AlarmOut, AlarmUpdate

router = APIRouter()


async def _owned(db: AsyncSession, user: User, alarm_id: uuid.UUID) -> Alarm:
    alarm = await db.get(Alarm, alarm_id)
    if alarm is None or alarm.user_id != user.id or alarm.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Alarm not found")
    return alarm


@router.get("", response_model=list[AlarmOut])
async def list_alarms(
    user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
):
    res = await db.execute(
        select(Alarm).where(Alarm.user_id == user.id, Alarm.deleted_at.is_(None))
    )
    return list(res.scalars())


@router.post("", response_model=AlarmOut, status_code=status.HTTP_201_CREATED)
async def create_alarm(
    data: AlarmCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    payload = data.model_dump(exclude_none=True)
    # Honor a client-supplied id for offline-first sync; upsert if it already exists.
    alarm_id = payload.pop("id", None)
    if alarm_id:
        existing = await db.get(Alarm, alarm_id)
        if existing and existing.user_id == user.id:
            for k, v in payload.items():
                setattr(existing, k, v)
            existing.deleted_at = None
            await db.flush()
            await db.refresh(existing)
            return existing
    alarm = Alarm(user_id=user.id, **({"id": alarm_id} if alarm_id else {}), **payload)
    db.add(alarm)
    await db.flush()
    await db.refresh(alarm)
    return alarm


@router.patch("/{alarm_id}", response_model=AlarmOut)
async def update_alarm(
    alarm_id: uuid.UUID,
    data: AlarmUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    alarm = await _owned(db, user, alarm_id)
    for k, v in data.model_dump(exclude_none=True).items():
        setattr(alarm, k, v)
    await db.flush()
    await db.refresh(alarm)
    return alarm


@router.delete("/{alarm_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_alarm(
    alarm_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    alarm = await _owned(db, user, alarm_id)
    alarm.deleted_at = datetime.now(timezone.utc)  # soft delete for sync
    await db.flush()
