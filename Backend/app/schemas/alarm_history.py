from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class AlarmHistoryCreate(BaseModel):
    # Allow the client to keep its locally-generated id for offline-first sync.
    id: uuid.UUID | None = None
    alarm_id: uuid.UUID | None = None
    fired_at: datetime
    challenge_type: str = "object_scan"
    challenge_object: str | None = None
    completed: bool = False
    wake_time: datetime | None = None
    points: int = 0
    recheck_status: str = "pending"


class RecheckUpdate(BaseModel):
    recheck_status: str = Field(pattern="^(pending|verified|relapsed)$")
    recheck_at: datetime | None = None


class AlarmHistoryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    alarm_id: uuid.UUID | None
    fired_at: datetime
    challenge_type: str
    challenge_object: str | None
    completed: bool
    wake_time: datetime | None
    points: int
    recheck_status: str
    recheck_at: datetime | None
    created_at: datetime
