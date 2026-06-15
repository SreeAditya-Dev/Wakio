"""Quick standalone test: verify YOLO detection works with the local model weights.

Run from the Backend directory:
    python test_detection.py

This tests the model loading + inference WITHOUT starting the full FastAPI server,
so we can isolate whether detection itself works.
"""
import sys
import os
import io

# Add the Backend dir to path so we can import app modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_model_loading():
    """Test 1: Can we load the YOLO model?"""
    print("=" * 60)
    print("TEST 1: Loading YOLO model...")
    print("=" * 60)
    
    model_path = os.path.join("app", "ml", "weights", "yolo11n.pt")
    if not os.path.exists(model_path):
        model_path = "yolo11n.pt"
    
    if not os.path.exists(model_path):
        print(f"  FAIL: Model file not found at either path")
        return None
    
    print(f"  Model file found: {model_path} ({os.path.getsize(model_path)} bytes)")
    
    try:
        from ultralytics import YOLO
        model = YOLO(model_path)
        print(f"  SUCCESS: Model loaded successfully")
        print(f"  Model type: {type(model)}")
        print(f"  Model names (first 10): {dict(list(model.names.items())[:10])}")
        print(f"  Total classes: {len(model.names)}")
        return model
    except ImportError:
        print("  FAIL: 'ultralytics' package not installed")
        print("  Run: pip install ultralytics")
        return None
    except Exception as e:
        print(f"  FAIL: {e}")
        return None


def test_detection_with_synthetic_image(model):
    """Test 2: Can we run inference on a blank image?"""
    print()
    print("=" * 60)
    print("TEST 2: Running inference on a synthetic test image...")
    print("=" * 60)
    
    try:
        from PIL import Image
        import numpy as np
        
        img = Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8))
        
        results = model.predict(img, conf=0.45, verbose=False)
        
        detected = []
        for r in results:
            for box in r.boxes:
                label = r.names[int(box.cls)].lower()
                conf = float(box.conf)
                detected.append((label, conf))
        
        print(f"  SUCCESS: Inference completed")
        if detected:
            print(f"  Detected {len(detected)} objects (on random noise):")
            for label, conf in detected:
                print(f"    - {label}: {conf:.2f}")
        else:
            print(f"  No objects detected (expected on random noise)")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def test_coco_classes(model):
    """Test 3: Check that our household objects are valid COCO classes."""
    print()
    print("=" * 60)
    print("TEST 3: Validating household object classes...")
    print("=" * 60)
    
    household_objects = [
        'chair', 'couch', 'bed', 'dining table', 'potted plant', 'vase', 'clock',
        'bottle', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'microwave', 'oven',
        'toaster', 'sink', 'refrigerator',
        'tv', 'laptop', 'mouse', 'keyboard', 'cell phone', 'remote',
        'backpack', 'umbrella', 'handbag', 'suitcase',
        'book', 'scissors',
        'toothbrush', 'hair drier',
        'teddy bear', 'sports ball',
    ]
    
    model_classes = [name.lower() for name in model.names.values()]
    
    valid = []
    invalid = []
    for obj in household_objects:
        if obj in model_classes:
            valid.append(obj)
        else:
            invalid.append(obj)
    
    print(f"  Valid classes ({len(valid)}/{len(household_objects)}):")
    for v in valid:
        print(f"    OK  {v}")
    
    if invalid:
        print(f"\n  INVALID classes ({len(invalid)}):")
        for inv in invalid:
            print(f"    XX  {inv}")
        print(f"\n  Available model classes: {model_classes}")
    else:
        print(f"\n  ALL {len(household_objects)} household objects are valid COCO classes!")
    
    return len(invalid) == 0


def test_detection_function():
    """Test 4: Test the app's detect() function directly."""
    print()
    print("=" * 60)
    print("TEST 4: Testing app.ml.yolo.detect() function...")
    print("=" * 60)
    
    try:
        os.environ.setdefault("YOLO_MODEL_PATH", "app/ml/weights/yolo11n.pt")
        os.environ.setdefault("YOLO_CONFIDENCE", "0.45")
        
        from app.ml.yolo import detect
        from PIL import Image
        import numpy as np
        
        img = Image.fromarray(np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8))
        buf = io.BytesIO()
        img.save(buf, format="JPEG")
        jpeg_bytes = buf.getvalue()
        
        present, conf, detected = detect(jpeg_bytes, "chair")
        print(f"  SUCCESS: detect() returned")
        print(f"    target_present: {present}")
        print(f"    confidence: {conf:.4f}")
        print(f"    detected: {detected}")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("Wakio Detection Service - Quick Test")
    print("=" * 60)
    print()
    
    model = test_model_loading()
    if model is None:
        print("\nStopping: model could not be loaded.")
        sys.exit(1)
    
    test_detection_with_synthetic_image(model)
    test_coco_classes(model)
    test_detection_function()
    
    print()
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
