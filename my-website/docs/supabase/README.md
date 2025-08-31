# Supabase SQL scripts

This folder contains SQL you can run in Supabase (SQL editor) to set up storage, tables, and row-level security for this app.

Files:

- 01_storage_avatars.sql — Creates a public `avatars` bucket and RLS policies
- 02_table_student_profiles.sql — Creates `public.student_profiles` with per-user RLS
- 03_table_descriptors_and_seed.sql — Creates `public.descriptors` with RLS and seeds defaults
- 04_table_assignment_spec_descriptors.sql — Creates `public.assignment_spec_descriptors` with student read-only and admin-only writes
- 05_seed_assignment_spec_descriptors.sql — Adds your email to `app_admins` and seeds seven canonical assignments

Tips:

- Run these scripts in order, while authenticated as a service role or an admin in the Supabase SQL editor.
- For 03_table_descriptors_and_seed.sql, replace the placeholder UUID with your `auth.users.id` before running so the seeded rows have an owner.
- If you already created any of these, the scripts are idempotent (use `if not exists` / `on conflict`).

Suggested order for the Specs table used by the UI:

1. 04_table_assignment_spec_descriptors.sql
2. 05_seed_assignment_spec_descriptors.sql (updates require your email in `app_admins`)
