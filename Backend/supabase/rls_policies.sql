-- ============================================================
--  Row Level Security for the Wakio (Scan-to-Stop Alarm) app.
--  Run this in the Supabase SQL editor AFTER `alembic upgrade head`.
--
--  FastAPI signs JWTs with the Supabase JWT secret and sets
--  sub = users.id, so auth.uid() inside Supabase equals the row owner.
--  This lets the Flutter client subscribe to Realtime / read Storage
--  directly using the same access token, restricted to its own rows.
-- ============================================================

-- Enable RLS
alter table public.users           enable row level security;
alter table public.alarms          enable row level security;
alter table public.sound_profiles  enable row level security;
alter table public.alarm_history   enable row level security;
alter table public.streaks         enable row level security;
alter table public.devices         enable row level security;
alter table public.notifications   enable row level security;

-- Helper: owner check
--   auth.uid() returns the JWT `sub` claim as uuid.

-- users: a user can read/update only their own row.
create policy "users_self_select" on public.users
  for select using (auth.uid() = id);
create policy "users_self_update" on public.users
  for update using (auth.uid() = id);

-- Generic owner policies for user-scoped tables.
do $$
declare t text;
begin
  foreach t in array array[
    'alarms','alarm_history','streaks','devices','notifications'
  ]
  loop
    execute format(
      'create policy %I on public.%I for all using (auth.uid() = user_id) with check (auth.uid() = user_id);',
      t || '_owner_all', t
    );
  end loop;
end$$;

-- sound_profiles: own rows OR shared built-ins (user_id is null).
create policy "sound_profiles_read" on public.sound_profiles
  for select using (user_id is null or auth.uid() = user_id);
create policy "sound_profiles_write" on public.sound_profiles
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Realtime: make the alarms table broadcast changes (multi-device sync).
alter publication supabase_realtime add table public.alarms;
