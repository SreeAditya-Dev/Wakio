from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, Timestamps, UUIDPrimaryKey

if TYPE_CHECKING:
    from app.models.alarm import Alarm
    from app.models.streak import Streak


class User(UUIDPrimaryKey, Timestamps, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    # Null for pure Google accounts.
    password_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    google_sub: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)

    alarms: Mapped[list["Alarm"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    streak: Mapped["Streak | None"] = relationship(
        back_populates="user", cascade="all, delete-orphan", uselist=False
    )
