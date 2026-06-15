# On-device detection model

Place the exported YOLOv11n TFLite model here as `yolo11n.tflite`.

Export from Ultralytics (int8 quantized for low-end phones):

```bash
pip install ultralytics
yolo export model=yolo11n.pt format=tflite int8=True imgsz=320
# produces yolo11n_int8.tflite -> rename to yolo11n.tflite and drop it here
```

`labels.txt` holds the 80 COCO class names in model-output order.

> ⚠️ Ultralytics YOLO11 is AGPL-3.0 — fine for personal/open use; a commercial
> release needs an Ultralytics license or an Apache/MIT-licensed detector.
