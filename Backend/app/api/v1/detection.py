from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from app.api.deps import get_current_user
from app.ml import yolo
from app.models.user import User
from app.schemas.challenge import DetectionResult

logger = logging.getLogger("app.detection")
router = APIRouter()

_MAX_BYTES = 8 * 1024 * 1024  # 8 MB


@router.post("/verify", response_model=DetectionResult)
async def verify_object(
    target: str = Form(...),
    image: UploadFile = File(...),
    user: User = Depends(get_current_user),
):
    """Hybrid fallback: run YOLOv11n server-side when on-device detection is
    unavailable or to double-check a borderline result."""
    logger.info("YOLO verification requested by user %s for target: %s", user.id, target)
    data = await image.read()
    if len(data) > _MAX_BYTES:
        logger.warning("Upload rejected: image size (%d bytes) exceeds limit", len(data))
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "Image too large")
    try:
        present, conf, detected = yolo.detect(data, target)
        logger.info(
            "YOLO verification result: target_present=%s, conf=%.2f, detected=%s",
            present,
            conf,
            detected,
        )
    except Exception as exc:  # model missing / decode error
        logger.error("YOLO verification failed with error: %s", exc, exc_info=True)
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE, f"Detection unavailable: {exc}"
        )
    return DetectionResult(
        target=target, target_present=present, confidence=conf, detected=detected
    )
