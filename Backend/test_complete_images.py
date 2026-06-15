"""Test YOLO detection on actual generated images and measure processing times & latency.
"""
import sys
import os
import io
import time
import statistics
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Define absolute paths of the generated images
CHAIR_IMG_PATH = r"C:\Users\Aditya\.gemini\antigravity-cli\brain\ca197d1b-9d7c-46a7-90dd-0157793f8c61\test_chair_1781518886846.jpg"
CUP_IMG_PATH = r"C:\Users\Aditya\.gemini\antigravity-cli\brain\ca197d1b-9d7c-46a7-90dd-0157793f8c61\test_cup_1781519900000.jpg" # will check directory listing to find the exact filename if it mismatches

# We will dynamically find any image starting with test_chair or test_cup in the artifact directory to be robust!
ARTIFACT_DIR = r"C:\Users\Aditya\.gemini\antigravity-cli\brain\ca197d1b-9d7c-46a7-90dd-0157793f8c61"
chair_files = [f for f in os.listdir(ARTIFACT_DIR) if f.startswith("test_chair") and f.endswith(".jpg")]
cup_files = [f for f in os.listdir(ARTIFACT_DIR) if f.startswith("test_cup") and f.endswith(".jpg")]

chair_img_path = os.path.join(ARTIFACT_DIR, chair_files[0]) if chair_files else CHAIR_IMG_PATH
cup_img_path = os.path.join(ARTIFACT_DIR, cup_files[0]) if cup_files else CUP_IMG_PATH

def run_test_on_image(model, img_path, target_object):
    print("=" * 70)
    print(f"Testing Image: {os.path.basename(img_path)}")
    print(f"Path: {img_path}")
    print(f"Target object to verify: '{target_object}'")
    print("=" * 70)
    
    if not os.path.exists(img_path):
        print(f"ERROR: Image file not found at {img_path}")
        return None
        
    # Measure image size and load/decode time
    t_start = time.perf_counter()
    with open(img_path, "rb") as f:
        img_bytes = f.read()
    t_read = time.perf_counter()
    
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    width, height = img.size
    t_decode = time.perf_counter()
    
    read_ms = (t_read - t_start) * 1000
    decode_ms = (t_decode - t_read) * 1000
    print(f"  Image size: {width}x{height} pixels ({len(img_bytes)/1024:.1f} KB)")
    print(f"  File read time:   {read_ms:.2f} ms")
    print(f"  JPEG decode time: {decode_ms:.2f} ms")
    
    # Run a single detection and print results
    t_inf_start = time.perf_counter()
    results = model.predict(img, conf=0.25, verbose=False)
    t_inf_end = time.perf_counter()
    
    inference_ms = (t_inf_end - t_inf_start) * 1000
    print(f"  First-run inference latency: {inference_ms:.2f} ms")
    
    # Extract detected classes
    detected = []
    for r in results:
        names = r.names
        for box in r.boxes:
            label = names[int(box.cls)].lower()
            conf = float(box.conf)
            detected.append((label, conf))
            
    print(f"  Detected objects:")
    if detected:
        for label, conf in detected:
            print(f"    - {label:<15} (confidence: {conf*100:.1f}%)")
    else:
        print("    - None")
        
    # Check if target is present
    target_found = any(label == target_object.lower() for label, _ in detected)
    print(f"  Target '{target_object}' found? {'YES' if target_found else 'NO'}")
    
    # Warm run average (10 runs to measure stable warm latency)
    print(f"\n  Running 10 warm-cache iterations to measure latency stability...")
    latencies = []
    for i in range(10):
        t0 = time.perf_counter()
        model.predict(img, conf=0.25, verbose=False)
        latencies.append((time.perf_counter() - t0) * 1000)
        
    mean_lat = statistics.mean(latencies)
    median_lat = statistics.median(latencies)
    min_lat = min(latencies)
    max_lat = max(latencies)
    
    print(f"  Warm inference latency stats (10 runs):")
    print(f"    - Mean:   {mean_lat:.2f} ms")
    print(f"    - Median: {median_lat:.2f} ms")
    print(f"    - Min:    {min_lat:.2f} ms")
    print(f"    - Max:    {max_lat:.2f} ms")
    
    return {
        "file_size_kb": len(img_bytes)/1024,
        "width": width,
        "height": height,
        "read_ms": read_ms,
        "decode_ms": decode_ms,
        "first_inference_ms": inference_ms,
        "mean_inference_ms": mean_lat,
        "median_inference_ms": median_lat,
        "detected": detected,
        "target_found": target_found
    }

if __name__ == "__main__":
    print("=================================================================")
    print("  YOLOv11n Real-world Complete Image Testing & Latency Benchmark")
    print("=================================================================")
    
    model_path = os.path.join("app", "ml", "weights", "yolo11n.pt")
    if not os.path.exists(model_path):
        model_path = "yolo11n.pt"
        
    print(f"Loading model from {model_path}...")
    t0 = time.perf_counter()
    from ultralytics import YOLO
    model = YOLO(model_path)
    load_ms = (time.perf_counter() - t0) * 1000
    print(f"Model load time (cold-start): {load_ms:.2f} ms\n")
    
    # Run warmup
    model.predict(Image.new("RGB", (640, 480)), verbose=False)
    
    results = {}
    results["chair"] = run_test_on_image(model, chair_img_path, "chair")
    print()
    results["cup"] = run_test_on_image(model, cup_img_path, "cup")
    
    print("\n" + "=" * 70)
    print("  SUMMARY OF RESULTS")
    print("=" * 70)
    for name, res in results.items():
        if res is None:
            continue
        print(f"Image: {name} ({res['width']}x{res['height']})")
        print(f"  Detected: {', '.join([f'{l}({c*100:.0f}%)' for l, c in res['detected']])}")
        print(f"  Target Found: {res['target_found']}")
        print(f"  Decode Latency: {res['decode_ms']:.2f} ms")
        print(f"  Median Inference Latency: {res['median_inference_ms']:.2f} ms")
        print(f"  Total Latency (Decode + Inf): {res['decode_ms'] + res['median_inference_ms']:.2f} ms")
        print()
