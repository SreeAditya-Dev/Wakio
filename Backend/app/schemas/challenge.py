from __future__ import annotations

from datetime import date

from pydantic import BaseModel


class ChallengeOut(BaseModel):
    date: date
    object_class: str       # e.g. "chair"
    display_name: str       # e.g. "Chair"
    points: int = 10


class DetectionResult(BaseModel):
    target: str
    target_present: bool
    confidence: float
    detected: list[str]
