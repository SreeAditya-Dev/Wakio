from __future__ import annotations

import uuid
from datetime import datetime
from datetime import time as dtime

from pydantic import BaseModel, ConfigDict, Field

CHALLENGE_TYPES = {"object_scan", "math", "steps", "selfie"}


class AlarmBase(BaseModel):
    label: str = Field(default="Alarm", max_length=120)
    time: dtime
    repeat_days: list[int] = Field(default_factory=list)  # 0=Mon..6=Sun
    sound_id: uuid.UUID | None = None
    challenge_type: str = "object_scan"
    volume: int = Field(default=100, ge=0, le=100)
    snooze_minutes: int = Field(default=5, ge=0, le=60)
    vibrate: bool = True
    enabled: bool = True


class AlarmCreate(AlarmBase):
    # Allow the client to keep its locally-generated id for offline-first sync.
    id: uuid.UUID | None = None


class AlarmUpdate(BaseModel):
    label: str | None = None
    time: dtime | None = None
    repeat_days: list[int] | None = None
    sound_id: uuid.UUID | None = None
    challenge_type: str | None = None
    volume: int | None = Field(default=None, ge=0, le=100)
    snooze_minutes: int | None = Field(default=None, ge=0, le=60)
    vibrate: bool | None = None
    enabled: bool | None = None


class AlarmOut(AlarmBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
