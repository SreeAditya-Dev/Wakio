# Wakio — Scan-to-Stop Alarm

An offline-first alarm app whose alarms can only be dismissed by physically
scanning a **random daily object** (e.g. "scan a chair") with the camera, verified
by **YOLOv11n**. Alarms ring at **full volume even in silent / Do-Not-Disturb mode**,
sync across devices in real time, and run on low-end Android hardware.

| Part | Stack |
|---|---|
| `mobile-app/` | Flutter (Android), Riverpod, Material 3, Drift (offline-first), go_router, `alarm` engine, camera + TFLite |
| `Backend/` | FastAPI, async SQLAlchemy, Supabase Postgres + Realtime + Storage, Redis, Ultralytics YOLOv11n |

> **Architecture glue:** FastAPI signs JWTs with the **Supabase JWT secret**, so one
> access token authorizes both the API and Supabase Realtime/Storage (RLS on `auth.uid()`).

---

## 1. Backend

```bash
cd Backend
python -m venv .venv && . .venv/Scripts/activate
pip install -r requirements.txt
cp .env.example .env          # local defaults work with docker-compose
docker compose up -d          # Postgres + Redis
alembic upgrade head
uvicorn app.main:app --reload --port 8011
# -> http://localhost:8011/docs
```

To use Supabase instead of local Postgres: set `DATABASE_URL` + the `SUPABASE_*`
vars in `.env`, run `alembic upgrade head`, then apply `supabase/rls_policies.sql`.

## 2. Mobile app

```bash
cd mobile-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run -d <android-emulator-or-device> \
  --dart-define=API_BASE_URL=http://10.0.2.2:8011/api/v1
```

`10.0.2.2` is the Android emulator's alias for your host machine.

### Testing the alarm (must use a real device / emulator, not web)
1. Sign up, create an alarm 1–2 minutes out.
2. Lock the phone and turn on **silent + Do Not Disturb**.
3. The alarm fires at full volume over the lockscreen and **cannot be swiped away**.
4. Tap **Open Camera**, point at the wrong object (no dismiss), then the day's
   target object → alarm stops, Scan Success shows points + streak.

## 3. Object detection model
On-device detection needs the TFLite model in `mobile-app/assets/models/yolo11n.tflite`:
```bash
pip install ultralytics
yolo export model=yolo11n.pt format=tflite int8=True imgsz=320
# rename the int8 .tflite to yolo11n.tflite, drop it in assets/models/
```
Until the model is present, the app automatically uses the **backend** `/detection/verify`
endpoint (the server has Ultralytics). ⚠️ Ultralytics YOLO11 is **AGPL-3.0**.

## What's implemented (vertical slice)
Auth (signup/login/refresh) → create alarm → full-volume/DND ring over lockscreen →
scan-to-stop (hybrid YOLO) → streak/points, all offline-first with backend sync.
Remaining screens (sound library, notification center, edit/list polish, Google
sign-in, FCM push) are scaffolded and navigable for the next phase.

## Required external config (placeholders provided)
Supabase project (URL, keys, **JWT secret**, DB URL) · Google OAuth client IDs ·
Firebase `google-services.json` (FCM) · Redis · Android device/emulator.
