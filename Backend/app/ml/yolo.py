"""YOLOv11n inference for the hybrid detection fallback.

The model is loaded lazily on first use (keeps startup fast and lets the API boot
without weights present). Download once:

    from ultralytics import YOLO; YOLO("yolo11n.pt")   # caches the weights

then point YOLO_MODEL_PATH at the file.
"""
from __future__ import annotations

import io
import threading

from app.core.config import settings

_model = None
_lock = threading.Lock()


def _get_model():
    global _model
    if _model is None:
        with _lock:
            if _model is None:
                from ultralytics import YOLO

                _model = YOLO(settings.YOLO_MODEL_PATH)
    return _model


def detect(image_bytes: bytes, target: str) -> tuple[bool, float, list[str]]:
    """Return (target_present, best_confidence_for_target, all_detected_labels)."""
    from PIL import Image

    model = _get_model()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    results = model.predict(
        image, conf=settings.YOLO_CONFIDENCE, verbose=False
    )

    detected: list[str] = []
    best_conf = 0.0
    target_l = target.lower()
    for r in results:
        names = r.names
        for box in r.boxes:
            label = names[int(box.cls)].lower()
            conf = float(box.conf)
            detected.append(label)
            if label == target_l and conf > best_conf:
                best_conf = conf

    return best_conf > 0.0, best_conf, sorted(set(detected))
