-- 03_table_descriptors_and_seed.sql
-- Purpose: Create descriptors table used by the Specifications tab and seed common defaults

create extension if not exists "pgcrypto";

create table if not exists public.descriptors (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  title text not null,
  description text,
  category text,
  weight numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (slug)
);

-- Keep updated_at current
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_descriptors_updated_at on public.descriptors;
create trigger trg_descriptors_updated_at
before update on public.descriptors
for each row execute function public.set_updated_at();

-- RLS on
alter table public.descriptors enable row level security;

-- Policies: global access for authenticated (reference table)
drop policy if exists "Descriptors select (all auth)" on public.descriptors;
create policy "Descriptors select (all auth)"
  on public.descriptors for select to authenticated
  using (true);

drop policy if exists "Descriptors insert (auth)" on public.descriptors;
create policy "Descriptors insert (auth)"
  on public.descriptors for insert to authenticated
  with check (true);

drop policy if exists "Descriptors update (auth)" on public.descriptors;
create policy "Descriptors update (auth)"
  on public.descriptors for update to authenticated
  using (true)
  with check (true);

drop policy if exists "Descriptors delete (auth)" on public.descriptors;
create policy "Descriptors delete (auth)"
  on public.descriptors for delete to authenticated
  using (true);

-- If an owner_id column exists and is NOT NULL from a previous schema,
-- relax it so reference seeds can insert without an owner
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='descriptors' and column_name='owner_id'
  ) then
    begin
      alter table public.descriptors alter column owner_id drop not null;
    exception when others then null;
    end;
  end if;
end $$;

-- Ensure a unique index exists on slug for ON CONFLICT to target
-- (covers older deployments where the table existed without the UNIQUE constraint)
create unique index if not exists descriptors_slug_key
  on public.descriptors (slug);

-- Seed defaults (idempotent) — no owner required
with seeds as (
  select * from (values
    ('spec-academic-integrity', 'Academic Integrity', 'Upholds academic honesty and integrity in all work', 'conduct', 1.0),
    ('spec-collaboration', 'Collaboration', 'Works effectively with peers and contributes meaningfully', 'skills', 1.0),
    ('spec-communication', 'Communication', 'Communicates clearly in written and oral formats', 'skills', 1.0),
    ('spec-critical-thinking', 'Critical Thinking', 'Analyzes, evaluates, and synthesizes information', 'skills', 1.0),
    ('spec-deadlines', 'Meets Deadlines', 'Submits work on time and manages workload', 'habits', 1.0)
  ) s(slug, title, description, category, weight)
)
insert into public.descriptors (slug, title, description, category, weight)
select s.slug, s.title, s.description, s.category, s.weight
from seeds s
on conflict (slug) do update
set title = excluded.title,
    description = excluded.description,
    category = excluded.category,
    weight = excluded.weight,
    updated_at = now();
