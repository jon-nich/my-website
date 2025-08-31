-- Ensure a unique index exists on assignment_title (works for ON CONFLICT by column)
-- This avoids PL/pgSQL blocks so editors using MSSQL parsers won't flag syntax.
create unique index if not exists assignment_spec_descriptors_assignment_title_key
  on public.assignment_spec_descriptors (assignment_title);
