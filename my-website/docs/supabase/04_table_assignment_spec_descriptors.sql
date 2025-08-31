-- 04_table_assignment_spec_descriptors.sql
-- Purpose: Table used by the Specifications UI (Assignment + A/B/C + optional doc URL)
-- RLS: students (all authenticated) can read; only admins can write.

create extension if not exists "pgcrypto";

-- Optional: separate admin allowlist by email
create table if not exists public.app_admins (
  email text primary key
);

-- Helper: lower-case email from JWT
create or replace function public.current_email()
returns text language sql stable as $$
  select lower(coalesce(nullif(auth.jwt() ->> 'email', ''), ''))
$$;

-- Helper: is current user an admin (by email allowlist)
create or replace function public.is_admin()
returns boolean language sql stable as $$
  with jwt as (
    select auth.jwt() as j
  )
  select
    -- Allowlist by email OR JWT roles include 'admin' or 'ta'
    exists (select 1 from public.app_admins a where a.email = public.current_email())
    or (
      -- Check single role field
      lower(coalesce((select j ->> 'role' from jwt), '')) in ('admin','ta')
      or -- Check roles array
      (
        select exists (
          select 1
          from jsonb_array_elements_text(coalesce((select j -> 'app_metadata' -> 'roles' from jwt), '[]'::jsonb)) as r(val)
          where lower(val) in ('admin','ta')
        )
      )
    )
$$;

-- Main table
create table if not exists public.assignment_spec_descriptors (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid default gen_random_uuid(),
  assignment_title text not null,
  doc_url text,
  exceeds_expectations text,
  meets_expectations text,
  not_yet_meeting_expectations text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (assignment_title)
);

-- updated_at trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_asd_updated_at on public.assignment_spec_descriptors;
create trigger trg_asd_updated_at
before update on public.assignment_spec_descriptors
for each row execute function public.set_updated_at();

-- Migration: ensure new columns exist; backfill from legacy A/B/C if present; drop legacy columns
do $$
begin
  -- Ensure assignment_id exists and has default
  begin
    alter table public.assignment_spec_descriptors add column if not exists assignment_id uuid;
  exception when others then null;
  end;
  begin
    alter table public.assignment_spec_descriptors alter column assignment_id set default gen_random_uuid();
  exception when others then null;
  end;

  -- Ensure new descriptor columns exist
  begin
    alter table public.assignment_spec_descriptors add column if not exists exceeds_expectations text;
  exception when others then null;
  end;
  begin
    alter table public.assignment_spec_descriptors add column if not exists meets_expectations text;
  exception when others then null;
  end;
  begin
    alter table public.assignment_spec_descriptors add column if not exists not_yet_meeting_expectations text;
  exception when others then null;
  end;

  -- Backfill from legacy columns if present
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='assignment_spec_descriptors' and column_name='a_level'
  ) then
    update public.assignment_spec_descriptors
      set exceeds_expectations = coalesce(exceeds_expectations, a_level);
  end if;
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='assignment_spec_descriptors' and column_name='b_level'
  ) then
    update public.assignment_spec_descriptors
      set meets_expectations = coalesce(meets_expectations, b_level);
  end if;
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='assignment_spec_descriptors' and column_name='c_level'
  ) then
    update public.assignment_spec_descriptors
      set not_yet_meeting_expectations = coalesce(not_yet_meeting_expectations, c_level);
  end if;

  -- Drop legacy columns if they exist
  begin
    alter table public.assignment_spec_descriptors drop column if exists a_level;
  exception when others then null;
  end;
  begin
    alter table public.assignment_spec_descriptors drop column if exists b_level;
  exception when others then null;
  end;
  begin
    alter table public.assignment_spec_descriptors drop column if exists c_level;
  exception when others then null;
  end;
end $$;

-- RLS
alter table public.assignment_spec_descriptors enable row level security;

-- Policies: read for all authenticated
drop policy if exists "ASD select (all auth)" on public.assignment_spec_descriptors;
create policy "ASD select (all auth)"
  on public.assignment_spec_descriptors for select to authenticated
  using (true);

-- Policies: writes only for admins
drop policy if exists "ASD insert (admins)" on public.assignment_spec_descriptors;
create policy "ASD insert (admins)"
  on public.assignment_spec_descriptors for insert to authenticated
  with check (public.is_admin());

drop policy if exists "ASD update (admins)" on public.assignment_spec_descriptors;
create policy "ASD update (admins)"
  on public.assignment_spec_descriptors for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "ASD delete (admins)" on public.assignment_spec_descriptors;
create policy "ASD delete (admins)"
  on public.assignment_spec_descriptors for delete to authenticated
  using (public.is_admin());
