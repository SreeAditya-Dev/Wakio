"""Redis client (cache, rate limiting, refresh-token blocklist).

Degrades gracefully: if Redis is unreachable, callers should treat a miss as
"not cached" rather than failing the request.
"""
from __future__ import annotations

import logging
import redis.asyncio as aioredis

from app.core.config import settings

logger = logging.getLogger("app.redis")

_pool: aioredis.Redis | None = None


def get_redis() -> aioredis.Redis:
    global _pool
    if _pool is None:
        logger.info("Initializing Redis connection pool...")
        _pool = aioredis.from_url(
            settings.REDIS_URL, encoding="utf-8", decode_responses=True
        )
    return _pool


async def close_redis() -> None:
    global _pool
    if _pool is not None:
        logger.info("Closing Redis connection pool...")
        await _pool.aclose()
        _pool = None
