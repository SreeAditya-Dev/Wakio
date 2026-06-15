"""Streak/points bookkeeping derived from a user's alarm history.

Mirrors the offline-first calculation the mobile app does locally
(StreakRepository): a relapsed wake (missed the post-wake check-in) doesn't
count toward the streak or points.
"""
from __future__ import annotations

import uuid
from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.alarm_history import AlarmHistory
from app.models.streak import Streak


async def recompute(db: AsyncSession, user_id: uuid.UUID) -> Streak:
    res = await db.execute(
        select(AlarmHistory).where(AlarmHistory.user_id == user_id)
    )
    rows = list(res.scalars())
    completed = [
        h for h in rows if h.completed and h.recheck_status != "relapsed"
    ]
    total_points = sum(h.points for h in completed)

    days = sorted({h.fired_at.date() for h in completed}, reverse=True)
    cursor = date.today()
    if days and days[0] < cursor:
        cursor = days[0]

    streak = 0
    for d in days:
        if d == cursor:
            streak += 1
            cursor -= timedelta(days=1)
        elif d < cursor:
            break

    res = await db.execute(select(Streak).where(Streak.user_id == user_id))
    streak_row = res.scalar_one_or_none()
    if streak_row is None:
        streak_row = Streak(user_id=user_id)
        db.add(streak_row)

    streak_row.current_streak = streak
    streak_row.best_streak = max(streak_row.best_streak, streak)
    streak_row.total_points = total_points
    streak_row.last_completed_date = days[0] if days else None
    await db.flush()
    return streak_row
