"""S3-protocol client for Supabase Storage (boto3).

Alternative to `supabase_client.py` that doesn't require the service-role
key — only the S3 access key pair from Project Settings -> Storage -> S3
Connection. Lazily constructed so the app still boots without S3 configured.
"""
from __future__ import annotations

from functools import lru_cache

from app.core.config import settings


@lru_cache
def get_s3_client():
    if not settings.SUPABASE_S3_ENDPOINT or not settings.SUPABASE_S3_ACCESS_KEY_ID:
        return None

    import boto3

    return boto3.client(
        "s3",
        endpoint_url=settings.SUPABASE_S3_ENDPOINT,
        region_name=settings.SUPABASE_S3_REGION,
        aws_access_key_id=settings.SUPABASE_S3_ACCESS_KEY_ID,
        aws_secret_access_key=settings.SUPABASE_S3_SECRET_ACCESS_KEY,
    )
