"""Wakio Detection — Latency & Throughput Benchmark

Measures:
  1. Model cold-start load time
  2. Single-image inference latency (various resolutions)
  3. app.ml.yolo.detect() end-to-end latency
  4. Warm-cache throughput (repeated inferences)
"""
import sys, os, io, time, statistics
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image
import numpy as np

def fmt(ms): return f"{ms:>8.1f} ms"

# ── 1. Cold-start model load ─────────────────────────────────
print("=" * 65)
print("  Wakio Detection — Latency & Throughput Benchmark")
print("=" * 65)

model_path = os.path.join("app", "ml", "weights", "yolo11n.pt")
if not os.path.exists(model_path):
    model_path = "yolo11n.pt"

print(f"\n[1] Model cold-start load time")
t0 = time.perf_counter()
from ultralytics import YOLO
model = YOLO(model_path)
load_ms = (time.perf_counter() - t0) * 1000
print(f"    Load time:  {fmt(load_ms)}")

# ── 2. Single-image inference at different resolutions ────────
resolutions = [
    ("320x240  (low)",    320, 240),
    ("640x480  (medium)", 640, 480),
    ("1280x720 (HD)",     1280, 720),
    ("1920x1080 (FHD)",   1920, 1080),
]

print(f"\n[2] Single-image inference latency (first call includes warm-up)")
# Warm-up run (first inference is always slower due to CUDA/CPU init)
warmup_img = Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8))
model.predict(warmup_img, conf=0.45, verbose=False)

for label, w, h in resolutions:
    img = Image.fromarray(np.random.randint(0, 255, (h, w, 3), dtype=np.uint8))
    t0 = time.perf_counter()
    results = model.predict(img, conf=0.45, verbose=False)
    elapsed = (time.perf_counter() - t0) * 1000
    n_det = sum(len(r.boxes) for r in results)
    print(f"    {label}:  {fmt(elapsed)}  ({n_det} detections)")

# ── 3. End-to-end detect() function (JPEG decode + inference) ─
print(f"\n[3] app.ml.yolo.detect() end-to-end latency")
os.environ.setdefault("YOLO_MODEL_PATH", model_path)
os.environ.setdefault("YOLO_CONFIDENCE", "0.45")

# Force reimport with fresh model
import importlib
if "app.ml.yolo" in sys.modules:
    importlib.reload(sys.modules["app.ml.yolo"])
from app.ml.yolo import detect as app_detect

# Create a realistic JPEG (640x480, quality 85 — similar to phone camera)
test_img = Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8))
buf = io.BytesIO()
test_img.save(buf, format="JPEG", quality=85)
jpeg_bytes = buf.getvalue()
jpeg_kb = len(jpeg_bytes) / 1024

targets = ["chair", "bottle", "cup", "cell phone", "laptop", "remote"]
for target in targets:
    t0 = time.perf_counter()
    present, conf, detected = app_detect(jpeg_bytes, target)
    elapsed = (time.perf_counter() - t0) * 1000
    print(f"    target='{target}':  {fmt(elapsed)}  "
          f"(JPEG {jpeg_kb:.0f}KB, present={present})")

# ── 4. Throughput benchmark (20 consecutive inferences) ───────
print(f"\n[4] Warm-cache throughput (20 consecutive runs, 640x480)")
times = []
for i in range(20):
    img = Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8))
    t0 = time.perf_counter()
    model.predict(img, conf=0.45, verbose=False)
    times.append((time.perf_counter() - t0) * 1000)

print(f"    Min:     {fmt(min(times))}")
print(f"    Max:     {fmt(max(times))}")
print(f"    Mean:    {fmt(statistics.mean(times))}")
print(f"    Median:  {fmt(statistics.median(times))}")
print(f"    Stdev:   {fmt(statistics.stdev(times))}")
print(f"    P95:     {fmt(sorted(times)[int(len(times)*0.95)])}")
print(f"    FPS:     {1000/statistics.mean(times):.1f}")

# ── 5. JPEG decode overhead ──────────────────────────────────
print(f"\n[5] JPEG decode overhead (isolated)")
buf2 = io.BytesIO()
Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)).save(
    buf2, format="JPEG", quality=85)
raw = buf2.getvalue()
decode_times = []
for _ in range(50):
    t0 = time.perf_counter()
    Image.open(io.BytesIO(raw)).convert("RGB")
    decode_times.append((time.perf_counter() - t0) * 1000)
print(f"    Mean decode:  {fmt(statistics.mean(decode_times))}")
print(f"    Median:       {fmt(statistics.median(decode_times))}")

# ── Summary ──────────────────────────────────────────────────
print(f"\n{'=' * 65}")
print(f"  SUMMARY")
print(f"{'=' * 65}")
print(f"  Model load (cold):     {fmt(load_ms)}")
print(f"  Inference (640x480):   {fmt(statistics.median(times))}")
print(f"  E2E detect() latency:  ~{statistics.median(times):.0f}ms")
print(f"  Throughput:            {1000/statistics.mean(times):.1f} FPS")
print(f"  JPEG decode overhead:  {fmt(statistics.median(decode_times))}")
print(f"{'=' * 65}")
