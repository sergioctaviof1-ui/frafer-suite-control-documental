-- ============================================================
-- Migración v9 — Catálogo Baseline (Snapshot de referencia)
-- Ejecutar en Supabase SQL Editor (proyecto lygpotmaneqgewjcetzw)
-- ============================================================

create table if not exists pol_catalogo_baseline (
  id             uuid primary key default gen_random_uuid(),
  snapshot_label text not null default 'v1.0 — Propuesta Inicial',
  snapshot_fecha date not null default current_date,

  -- Dirección
  dir_codigo     text not null,
  dir_nombre     text not null,
  dir_tipo       text,

  -- Área
  area_num       text not null,
  area_nombre    text not null,

  -- Departamento
  dept_codigo    text not null,
  dept_nombre    text not null,
  dept_orden     int,

  -- Actividad
  act_codigo     text not null,
  act_nombre     text not null,

  -- Códigos de documento
  codigo_plt     text,
  codigo_pcs     text,
  codigo_pcd     text,

  -- Auditoría de cambios estructurales
  estado         text not null default 'propuesta'
                 check (estado in ('propuesta','conservada','movida','eliminada','nueva')),
  notas          text,
  created_at     timestamptz not null default now()
);

alter table pol_catalogo_baseline enable row level security;

create policy "baseline_auth" on pol_catalogo_baseline
  for all to authenticated
  using (true) with check (true);

create index if not exists pol_catalogo_baseline_dir_idx
  on pol_catalogo_baseline(dir_codigo, area_num);

create index if not exists pol_catalogo_baseline_estado_idx
  on pol_catalogo_baseline(estado);

-- Verificar
select count(*) as "pol_catalogo_baseline creada" from pol_catalogo_baseline;
