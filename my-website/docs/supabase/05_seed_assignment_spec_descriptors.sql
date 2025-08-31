-- 05_seed_assignment_spec_descriptors.sql
-- Purpose: Seed the seven canonical assignments with optional doc links
-- Requires: 04_table_assignment_spec_descriptors.sql (and you must be an admin per app_admins)

-- Guard: ensure uuid generator and assignment_id default exist (for older schemas)
create extension if not exists "pgcrypto";
alter table public.assignment_spec_descriptors add column if not exists assignment_id uuid;
do $$ begin
  begin
    alter table public.assignment_spec_descriptors alter column assignment_id set default gen_random_uuid();
  exception when others then null;
  end;
end $$;
update public.assignment_spec_descriptors set assignment_id = gen_random_uuid() where assignment_id is null;

-- Guard: ensure new canonical columns exist
alter table public.assignment_spec_descriptors add column if not exists exceeds_expectations text;
alter table public.assignment_spec_descriptors add column if not exists meets_expectations text;
alter table public.assignment_spec_descriptors add column if not exists not_yet_meeting_expectations text;

-- Guard: relax NOT NULL on legacy 'level' column if present (older schemas)
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'assignment_spec_descriptors'
      and column_name = 'level'
  ) then
    begin
      -- Ensure a safe default so inserts that don't specify "level" won't fail
      begin
        alter table public.assignment_spec_descriptors alter column "level" set default ''::text;
      exception when others then null;
      end;
      -- Drop NOT NULL if present (best effort)
      begin
        alter table public.assignment_spec_descriptors alter column "level" drop not null;
      exception when others then null;
      end;
    exception when others then null;
    end;
  end if;
end
$$;

-- Guard: drop legacy CHECK constraint on 'level' if present
do $$
begin
  begin
    alter table public.assignment_spec_descriptors drop constraint if exists assignment_spec_descriptors_level_check;
  exception when others then null;
  end;
end
$$;

-- Guard: relax NOT NULL on legacy 'text' column if present (older schemas)
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'assignment_spec_descriptors'
      and column_name = 'text'
  ) then
    begin
      -- Ensure a safe default so inserts that don't specify "text" won't fail
      begin
        alter table public.assignment_spec_descriptors alter column "text" set default ''::text;
      exception when others then null;
      end;
      -- Drop NOT NULL if present (best effort)
      begin
        alter table public.assignment_spec_descriptors alter column "text" drop not null;
      exception when others then null;
      end;
    exception when others then null;
    end;
  end if;
end
$$;

-- Add your email to app_admins so you can seed
insert into public.app_admins(email)
values ('jon.n@vinuni.edu.vn')
on conflict (email) do nothing;

do $$
declare
  has_level boolean;
  has_text boolean;
begin
  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'assignment_spec_descriptors'
      and column_name = 'level'
  ) into has_level;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'assignment_spec_descriptors'
      and column_name = 'text'
  ) into has_text;

  if has_level and has_text then
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    -- Update existing
    update public.assignment_spec_descriptors d
      set doc_url = s.doc_url,
          exceeds_expectations = coalesce(s.exceeds, d.exceeds_expectations),
          meets_expectations = coalesce(s.meets, d.meets_expectations),
          not_yet_meeting_expectations = coalesce(s.not_yet, d.not_yet_meeting_expectations),
          "level" = coalesce('A'::text, d."level"),
          "text" = coalesce('N/A'::text, d."text")
      from seeds s
      where d.assignment_title = s.assignment_title;
    -- Insert missing
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    insert into public.assignment_spec_descriptors (assignment_title, doc_url, exceeds_expectations, meets_expectations, not_yet_meeting_expectations, "level", "text")
    select s.assignment_title, s.doc_url, s.exceeds, s.meets, s.not_yet, 'A'::text, 'N/A'::text
    from seeds s
    left join public.assignment_spec_descriptors d on d.assignment_title = s.assignment_title
    where d.assignment_title is null;

  elsif has_level then
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    update public.assignment_spec_descriptors d
      set doc_url = s.doc_url,
          exceeds_expectations = coalesce(s.exceeds, d.exceeds_expectations),
          meets_expectations = coalesce(s.meets, d.meets_expectations),
          not_yet_meeting_expectations = coalesce(s.not_yet, d.not_yet_meeting_expectations),
          "level" = coalesce('A'::text, d."level")
      from seeds s
      where d.assignment_title = s.assignment_title;
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    insert into public.assignment_spec_descriptors (assignment_title, doc_url, exceeds_expectations, meets_expectations, not_yet_meeting_expectations, "level")
    select s.assignment_title, s.doc_url, s.exceeds, s.meets, s.not_yet, 'A'::text
    from seeds s
    left join public.assignment_spec_descriptors d on d.assignment_title = s.assignment_title
    where d.assignment_title is null;

  elsif has_text then
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    update public.assignment_spec_descriptors d
      set doc_url = s.doc_url,
          exceeds_expectations = coalesce(s.exceeds, d.exceeds_expectations),
          meets_expectations = coalesce(s.meets, d.meets_expectations),
          not_yet_meeting_expectations = coalesce(s.not_yet, d.not_yet_meeting_expectations),
          "text" = coalesce('N/A'::text, d."text")
      from seeds s
      where d.assignment_title = s.assignment_title;
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    insert into public.assignment_spec_descriptors (assignment_title, doc_url, exceeds_expectations, meets_expectations, not_yet_meeting_expectations, "text")
    select s.assignment_title, s.doc_url, s.exceeds, s.meets, s.not_yet, 'N/A'::text
    from seeds s
    left join public.assignment_spec_descriptors d on d.assignment_title = s.assignment_title
    where d.assignment_title is null;

  else
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    -- Update then insert
    update public.assignment_spec_descriptors d
      set doc_url = s.doc_url,
          exceeds_expectations = coalesce(s.exceeds, d.exceeds_expectations),
          meets_expectations = coalesce(s.meets, d.meets_expectations),
          not_yet_meeting_expectations = coalesce(s.not_yet, d.not_yet_meeting_expectations)
      from seeds s
      where d.assignment_title = s.assignment_title;
    with seeds as (
      select * from (values
          ('Diagnostic Essay', null, null, null, null),
          ('Reflection 1', null, null, null, null),
          ('Reflection 2', null, null, null, null),
          ('Peer Reviews', null, null, null, null),
          ('Professional Portfolio', null, null, null, null),
          ('Literature Review Draft', null, null, null, null),
          ('Literature Review Final', null, null, null, null)
      ) as v(assignment_title, doc_url, exceeds, meets, not_yet)
    )
    insert into public.assignment_spec_descriptors (assignment_title, doc_url, exceeds_expectations, meets_expectations, not_yet_meeting_expectations)
    select s.assignment_title, s.doc_url, s.exceeds, s.meets, s.not_yet
    from seeds s
    left join public.assignment_spec_descriptors d on d.assignment_title = s.assignment_title
    where d.assignment_title is null;
  end if;
end $$;
