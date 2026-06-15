"""Supabase service-role client for Storage signed upload/download URLs.

Only used for file storage (sound profiles). Auth + data live in FastAPI/Postgres.
Lazily constructed so the app still boots without Supabase configured.
"""
from __future__ import annotations

from functools import lru_cache

from app.core.config import settings


@lru_cache
def get_supabase():
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        return None
    from supabase import create_client

    return create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)
