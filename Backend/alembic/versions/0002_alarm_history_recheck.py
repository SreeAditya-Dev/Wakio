"""add recheck status/at to alarm_history

Revision ID: 0002_alarm_history_recheck
Revises: 0001_initial
Create Date: 2026-06-16
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0002_alarm_history_recheck"
down_revision: Union[str, None] = "0001_initial"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "alarm_history",
        sa.Column("recheck_status", sa.String(16), server_default="pending", nullable=False),
    )
    op.add_column(
        "alarm_history",
        sa.Column("recheck_at", sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("alarm_history", "recheck_at")
    op.drop_column("alarm_history", "recheck_status")
