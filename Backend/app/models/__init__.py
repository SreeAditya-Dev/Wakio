"""Import all models so Alembic autogenerate + Base.metadata see them."""
from app.models.user import User
from app.models.alarm import Alarm
from app.models.sound_profile import SoundProfile
from app.models.alarm_history import AlarmHistory
from app.models.streak import Streak
from app.models.device import Device
from app.models.notification import Notification

__all__ = [
    "User",
    "Alarm",
    "SoundProfile",
    "AlarmHistory",
    "Streak",
    "Device",
    "Notification",
]
