from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, Timestamps, UUIDPrimaryKey


class AlarmHistory(UUIDPrimaryKey, Timestamps, Base):
    __tablename__ = "alarm_history"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    alarm_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("alarms.id", ondelete="SET NULL"), nullable=True
    )
    fired_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    challenge_type: Mapped[str] = mapped_column(String(32), default="object_scan")
    challenge_object: Mapped[str | None] = mapped_column(String(64), nullable=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    # When the user actually dismissed it (their real wake time).
    wake_time: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    points: Mapped[int] = mapped_column(Integer, default=0)
