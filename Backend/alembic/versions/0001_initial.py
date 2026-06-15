"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-06-14
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_uuid = postgresql.UUID(as_uuid=True)
_ts = dict(server_default=sa.text("now()"), nullable=False)


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("email", sa.String(255), nullable=False, unique=True),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("password_hash", sa.String(255), nullable=True),
        sa.Column("avatar_url", sa.String(512), nullable=True),
        sa.Column("google_sub", sa.String(255), nullable=True, unique=True),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_users_email", "users", ["email"])

    op.create_table(
        "sound_profiles",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=True),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("kind", sa.String(32), server_default="default", nullable=False),
        sa.Column("storage_path", sa.String(512), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_sound_profiles_user_id", "sound_profiles", ["user_id"])

    op.create_table(
        "alarms",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("label", sa.String(120), server_default="Alarm", nullable=False),
        sa.Column("time", sa.Time(), nullable=False),
        sa.Column("repeat_days", postgresql.ARRAY(sa.Integer()), server_default="{}", nullable=False),
        sa.Column("sound_id", _uuid, sa.ForeignKey("sound_profiles.id", ondelete="SET NULL"), nullable=True),
        sa.Column("challenge_type", sa.String(32), server_default="object_scan", nullable=False),
        sa.Column("volume", sa.Integer(), server_default="100", nullable=False),
        sa.Column("snooze_minutes", sa.Integer(), server_default="5", nullable=False),
        sa.Column("vibrate", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("enabled", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_alarms_user_id", "alarms", ["user_id"])

    op.create_table(
        "alarm_history",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("alarm_id", _uuid, sa.ForeignKey("alarms.id", ondelete="SET NULL"), nullable=True),
        sa.Column("fired_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("challenge_type", sa.String(32), server_default="object_scan", nullable=False),
        sa.Column("challenge_object", sa.String(64), nullable=True),
        sa.Column("completed", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("wake_time", sa.DateTime(timezone=True), nullable=True),
        sa.Column("points", sa.Integer(), server_default="0", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_alarm_history_user_id", "alarm_history", ["user_id"])

    op.create_table(
        "streaks",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True),
        sa.Column("current_streak", sa.Integer(), server_default="0", nullable=False),
        sa.Column("best_streak", sa.Integer(), server_default="0", nullable=False),
        sa.Column("total_points", sa.Integer(), server_default="0", nullable=False),
        sa.Column("last_completed_date", sa.Date(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_streaks_user_id", "streaks", ["user_id"])

    op.create_table(
        "devices",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("fcm_token", sa.String(512), nullable=False),
        sa.Column("platform", sa.String(16), server_default="android", nullable=False),
        sa.Column("last_seen", sa.DateTime(timezone=True), **_ts),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_devices_user_id", "devices", ["user_id"])

    op.create_table(
        "notifications",
        sa.Column("id", _uuid, primary_key=True),
        sa.Column("user_id", _uuid, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("type", sa.String(32), server_default="update", nullable=False),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("body", sa.Text(), server_default="", nullable=False),
        sa.Column("read", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), **_ts),
        sa.Column("updated_at", sa.DateTime(timezone=True), **_ts),
    )
    op.create_index("ix_notifications_user_id", "notifications", ["user_id"])


def downgrade() -> None:
    for t in (
        "notifications", "devices", "streaks", "alarm_history",
        "alarms", "sound_profiles", "users",
    ):
        op.drop_table(t)
