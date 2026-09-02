-- ============================================================
-- Migración v6 — Repositorio de versiones de documentos
-- Ejecutar en Supabase SQL Editor (proyecto lygpotmaneqgewjcetzw)
-- ============================================================

-- Tabla central: una fila por cada documento generado o adjuntado
create table if not exists pol_versiones (
  id             uuid primary key default gen_random_uuid(),
  politica_id    uuid references pol_politicas(id) on delete cascade not null,
  version        int not null default 1,
  folio          text,
  fuente         text not null default 'generado'
                   check (fuente in ('generado','adjuntado')),
  url_storage    text,        -- path dentro del bucket politicas-docs
  nombre_archivo text,
  elaboro        text,
  autorizo       text,
  created_at     timestamptz not null default now()
);

alter table pol_versiones enable row level security;

create policy "pol_versiones_auth" on pol_versiones
  for all to authenticated
  using (true)
  with check (true);

create index if not exists pol_versiones_pol_idx
  on pol_versiones (politica_id, created_at desc);

-- Verificar
select count(*) as "pol_versiones creada" from pol_versiones;
