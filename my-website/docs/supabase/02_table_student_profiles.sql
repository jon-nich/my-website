-- 02_table_student_profiles.sql
-- Purpose: Create student_profiles table and RLS policies for per-user profiles

create extension if not exists "pgcrypto";

create table if not exists public.student_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  first_name text,
  last_name text,
  preferred_name text,
  email text,
  phone text,
  bio text,
  avatar_url text,
  updated_at timestamptz not null default now(),
  unique (user_id)
);

-- If the table existed before without expected columns/constraints, ensure they exist
alter table public.student_profiles
  add column if not exists user_id uuid,
  add column if not exists first_name text,
  add column if not exists last_name text,
  add column if not exists preferred_name text,
  add column if not exists email text,
  add column if not exists phone text,
  add column if not exists bio text,
  add column if not exists avatar_url text,
  add column if not exists updated_at timestamptz not null default now();

-- Ensure id default exists
do $$ begin
  begin
    alter table public.student_profiles alter column id set default gen_random_uuid();
  exception when others then
    null;
  end;
end $$;

-- Add unique constraint on user_id if missing
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.student_profiles'::regclass
      and conname = 'student_profiles_user_id_key'
  ) then
    alter table public.student_profiles
      add constraint student_profiles_user_id_key unique (user_id);
  end if;
end $$;

-- Add FK to auth.users if missing
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.student_profiles'::regclass
      and conname = 'student_profiles_user_id_fkey'
  ) then
    alter table public.student_profiles
      add constraint student_profiles_user_id_fkey
      foreign key (user_id) references auth.users(id) on delete cascade;
  end if;
end $$;

-- RLS on
alter table public.student_profiles enable row level security;

-- Policy: users can select their own row
drop policy if exists "Users can read their own student profile" on public.student_profiles;
create policy "Users can read their own student profile"
  on public.student_profiles for select
  using (auth.uid() = user_id);

-- Policy: users can insert their own row
drop policy if exists "Users can insert their own student profile" on public.student_profiles;
create policy "Users can insert their own student profile"
  on public.student_profiles for insert to authenticated
  with check (auth.uid() = user_id);

-- Policy: users can update their own row
drop policy if exists "Users can update their own student profile" on public.student_profiles;
create policy "Users can update their own student profile"
  on public.student_profiles for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
