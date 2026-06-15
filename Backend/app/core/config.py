"""Application settings loaded from environment / .env."""
from __future__ import annotations

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )

    # App
    APP_NAME: str = "Wakio API"
    ENVIRONMENT: str = "development"
    API_V1_PREFIX: str = "/api/v1"
    BACKEND_CORS_ORIGINS: list[str] = Field(default_factory=lambda: ["*"])

    # Supabase
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_JWT_SECRET: str = "dev-insecure-change-me"
    SUPABASE_STORAGE_BUCKET: str = "sounds"

    # Supabase Storage — S3 protocol
    SUPABASE_S3_ENDPOINT: str = ""
    SUPABASE_S3_REGION: str = ""
    SUPABASE_S3_ACCESS_KEY_ID: str = ""
    SUPABASE_S3_SECRET_ACCESS_KEY: str = ""

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/alarm"

    # JWT — signed with SUPABASE_JWT_SECRET so the token also works for
    # Supabase Realtime + Storage RLS (aud="authenticated").
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    JWT_ALGORITHM: str = "HS256"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Google Sign-In
    GOOGLE_CLIENT_ID: str = ""

    # Object detection
    YOLO_MODEL_PATH: str = "app/ml/weights/yolo11n.pt"
    YOLO_CONFIDENCE: float = 0.45

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() == "production"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
