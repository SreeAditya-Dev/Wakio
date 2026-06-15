from __future__ import annotations

import uuid
from datetime import datetime
from datetime import time as dtime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Time
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, Timestamps, UUIDPrimaryKey

if TYPE_CHECKING:
    from app.models.user import User


class Alarm(UUIDPrimaryKey, Timestamps, Base):
    __tablename__ = "alarms"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    label: Mapped[str] = mapped_column(String(120), default="Alarm")
    # Local wall-clock time the alarm should fire.
    time: Mapped[dtime] = mapped_column(Time, nullable=False)
    # 0=Mon .. 6=Sun; empty list = one-shot.
    repeat_days: Mapped[list[int]] = mapped_column(
        ARRAY(Integer), default=list, nullable=False
    )
    sound_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("sound_profiles.id", ondelete="SET NULL"),
        nullable=True,
    )
    # object_scan | math | steps | selfie
    challenge_type: Mapped[str] = mapped_column(String(32), default="object_scan")
    volume: Mapped[int] = mapped_column(Integer, default=100)  # 0..100
    snooze_minutes: Mapped[int] = mapped_column(Integer, default=5)
    vibrate: Mapped[bool] = mapped_column(Boolean, default=True)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)

    # Soft delete for last-write-wins multi-device sync.
    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    user: Mapped["User"] = relationship(back_populates="alarms")
