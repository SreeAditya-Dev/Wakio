from __future__ import annotations

import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, Timestamps, UUIDPrimaryKey


class SoundProfile(UUIDPrimaryKey, Timestamps, Base):
    __tablename__ = "sound_profiles"

    # Null user_id = built-in / shared sound.
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True
    )
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    # default | nature | loud | custom
    kind: Mapped[str] = mapped_column(String(32), default="default")
    # Supabase Storage object path (custom uploads) or bundled asset key.
    storage_path: Mapped[str | None] = mapped_column(String(512), nullable=True)
