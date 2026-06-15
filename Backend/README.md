# Wakio — Backend (FastAPI)

FastAPI service that owns auth + business logic and uses **Supabase** (Postgres +
Realtime + Storage) as the data/sync/file backbone. JWTs are signed with the
**Supabase JWT secret**, so the same access token also authorizes Supabase
Realtime/Storage via RLS.

## Quick start (local dev)

```bash
cd Backend
python -m venv .venv
. .venv/Scripts/activate        # Windows (Git Bash):  source .venv/Scripts/activate
pip install -r requirements.txt

cp .env.example .env            # fill in values (local defaults work for pg+redis)

docker compose up -d            # local Postgres + Redis
alembic upgrade head            # create tables

uvicorn app.main:app --reload   # http://localhost:8000/docs
```

## Connecting to Supabase (instead of local Postgres)
1. Set `DATABASE_URL` to the Supabase **Direct connection** URI (async driver:
   `postgresql+asyncpg://...`).
2. `alembic upgrade head` against it.
3. Run `supabase/rls_policies.sql` in the Supabase SQL editor.
4. Set `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, and
   **`SUPABASE_JWT_SECRET`** (this must match Supabase or Realtime/Storage auth fails).

## Object detection weights (hybrid fallback)
```bash
python -c "from ultralytics import YOLO; YOLO('yolo11n.pt')"   # downloads weights
# move the cached yolo11n.pt to app/ml/weights/ or set YOLO_MODEL_PATH
```
> ⚠️ Ultralytics YOLO11 is **AGPL-3.0**. Fine for personal/open use; a commercial
> release needs an Ultralytics license or an Apache/MIT-licensed detector.

## Key endpoints
| Method | Path | Notes |
|---|---|---|
| POST | `/api/v1/auth/signup` `/login` `/refresh` `/google` | JWT (Supabase-secret signed) |
| GET | `/api/v1/auth/me` | current user |
| GET/POST | `/api/v1/alarms` | list / upsert (offline-first id honored) |
| PATCH/DELETE | `/api/v1/alarms/{id}` | update / soft-delete |
| GET | `/api/v1/challenges/today` | deterministic-per-day scan object |
| POST | `/api/v1/detection/verify` | YOLOv11n server-side verify |
