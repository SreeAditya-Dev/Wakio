"""Daily scan-to-stop challenge.

The object is deterministic per (user, date) — same all day, different each day —
so the alarm screen and the verify endpoint agree, while still rotating to prevent
habituation. Curated to COCO classes YOLOv11n detects reliably indoors.
"""
from __future__ import annotations

import hashlib
import json
import uuid
from datetime import date

from app.core.redis import get_redis
from app.schemas.challenge import ChallengeOut

# COCO classes that are common indoors / around the house and detect reliably.
CURATED_OBJECTS: list[str] = [
    # Furniture & decor
    "chair", "couch", "bed", "dining table", "potted plant", "vase", "clock",
    # Kitchen & dining
    "bottle", "cup", "fork", "knife", "spoon", "bowl", "microwave", "oven",
    "toaster", "sink", "refrigerator",
    # Electronics
    "tv", "laptop", "mouse", "keyboard", "cell phone", "remote",
    # Personal items
    "backpack", "umbrella", "handbag", "suitcase",
    # Books & office
    "book", "scissors",
    # Bathroom & grooming
    "toothbrush", "hair drier",
    # Fun
    "teddy bear", "sports ball",
]

_CACHE_TTL = 60 * 60 * 26  # a bit over a day


def _pick_for(user_id: uuid.UUID, day: date) -> str:
    seed = f"{user_id}:{day.isoformat()}"
    digest = hashlib.sha256(seed.encode()).hexdigest()
    idx = int(digest, 16) % len(CURATED_OBJECTS)
    return CURATED_OBJECTS[idx]


def _display(name: str) -> str:
    return name.title()


async def get_today(user_id: uuid.UUID, day: date | None = None) -> ChallengeOut:
    day = day or date.today()
    key = f"challenge:{user_id}:{day.isoformat()}"
    redis = get_redis()
    try:
        cached = await redis.get(key)
        if cached:
            return ChallengeOut(**json.loads(cached))
    except Exception:
        pass  # Redis optional — fall through to compute.

    obj = _pick_for(user_id, day)
    result = ChallengeOut(date=day, object_class=obj, display_name=_display(obj))

    try:
        await redis.set(key, result.model_dump_json(), ex=_CACHE_TTL)
    except Exception:
        pass
    return result
