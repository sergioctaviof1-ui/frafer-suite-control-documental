-- ============================================================
-- Migración v8 — Entrevista Dirección General
-- Ejecutar en Supabase SQL Editor (proyecto lygpotmaneqgewjcetzw)
-- ============================================================

create table if not exists pol_entrevista_dg (
  id            uuid primary key default gen_random_uuid(),
  entrevistado  text,
  cargo         text,
  fecha         date,
  consultores   text,
  respuestas    jsonb not null default '{}',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

alter table pol_entrevista_dg enable row level security;

create policy "entrevista_dg_auth" on pol_entrevista_dg
  for all to authenticated
  using (true)
  with check (true);

-- Trigger para updated_at automático
create or replace function _set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger entrevista_dg_updated_at
  before update on pol_entrevista_dg
  for each row execute function _set_updated_at();

-- Verificar
select count(*) as "pol_entrevista_dg creada" from pol_entrevista_dg;
