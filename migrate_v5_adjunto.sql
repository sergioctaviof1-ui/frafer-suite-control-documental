-- ============================================================
-- Migración v5 — Repositorio de documentos adjuntos
-- Ejecutar en Supabase SQL Editor (como postgres)
-- ============================================================

-- 1. Columnas en pol_politicas
alter table pol_politicas
  add column if not exists documento_adjunto_url    text,
  add column if not exists documento_adjunto_nombre text;

-- 2. Bucket de Storage: politicas-docs (privado, 10 MB por archivo)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'politicas-docs',
  'politicas-docs',
  false,
  10485760,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
on conflict (id) do nothing;

-- 3. RLS para el bucket (solo usuarios autenticados)
create policy "politicas_docs_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'politicas-docs');

create policy "politicas_docs_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'politicas-docs');

create policy "politicas_docs_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'politicas-docs');

create policy "politicas_docs_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'politicas-docs');

-- Verificar
select column_name, data_type
from information_schema.columns
where table_name = 'pol_politicas'
  and column_name in ('documento_adjunto_url','documento_adjunto_nombre')
order by column_name;
