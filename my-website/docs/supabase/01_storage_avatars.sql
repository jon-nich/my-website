-- 01_storage_avatars.sql
-- Purpose: Create a public avatars bucket and RLS policies for read + owner-only write

-- Create the bucket (id is the bucket key)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Enable RLS on storage.objects is always enforced by Supabase; define policies.
-- Public read for the avatars bucket
drop policy if exists "Public read access to avatars" on storage.objects;
create policy "Public read access to avatars"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- Only authenticated users can upload to avatars; they become the owner
drop policy if exists "Authenticated can insert avatars" on storage.objects;
create policy "Authenticated can insert avatars"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
  );

-- Owners can update their own objects in avatars
drop policy if exists "Owners can update their avatars" on storage.objects;
create policy "Owners can update their avatars"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars' and auth.uid() = owner
  )
  with check (
    bucket_id = 'avatars' and auth.uid() = owner
  );

-- Owners can delete their own objects in avatars
drop policy if exists "Owners can delete their avatars" on storage.objects;
create policy "Owners can delete their avatars"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars' and auth.uid() = owner
  );
