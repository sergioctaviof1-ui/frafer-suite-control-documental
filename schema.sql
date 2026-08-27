-- ============================================================
-- Sistema de Control Documental — Grupo Morsa
-- Frafer Consulting · Schema v1.0
-- Ejecutar en Supabase SQL Editor
-- ============================================================

-- EMPRESAS
create table if not exists pol_empresas (
  id         uuid primary key default gen_random_uuid(),
  codigo     text not null unique,
  nombre     text not null,
  activa     boolean default true,
  created_at timestamptz default now()
);

-- DIVISIONES
create table if not exists pol_divisiones (
  id         uuid primary key default gen_random_uuid(),
  empresa_id uuid references pol_empresas(id) on delete cascade,
  codigo     text not null,
  nombre     text not null,
  orden      int  default 0,
  activa     boolean default true,
  created_at timestamptz default now(),
  unique(empresa_id, codigo)
);

-- ÁREAS
create table if not exists pol_areas (
  id          uuid primary key default gen_random_uuid(),
  division_id uuid references pol_divisiones(id) on delete cascade,
  codigo      text not null,
  nombre      text not null,
  orden       int  default 0,
  activa      boolean default true,
  created_at  timestamptz default now(),
  unique(division_id, codigo)
);

-- CATÁLOGO (casillero de políticas por área)
create table if not exists pol_catalogo (
  id              uuid primary key default gen_random_uuid(),
  area_id         uuid references pol_areas(id) on delete cascade,
  numero          int  not null,
  codigo_politica text not null unique,   -- GM-RH-COMP-001
  nombre          text not null,
  descripcion     text,
  prioridad       text check (prioridad in ('alta','media','baja')) default 'media',
  activo          boolean default true,
  created_at      timestamptz default now(),
  unique(area_id, numero)
);

-- POLÍTICAS (contenido completo + tracking de ciclo de vida)
create table if not exists pol_politicas (
  id           uuid primary key default gen_random_uuid(),
  catalogo_id  uuid references pol_catalogo(id) on delete cascade,
  version      int  not null default 1,

  status text not null default 'pendiente' check (status in (
    'pendiente','en_levantamiento','borrador',
    'en_revision','autorizado','publicado','vencido'
  )),

  -- Campos de contenido
  objeto                 text,
  alcance                text,
  responsable_direccion  text,
  responsable_elaboracion text,
  colaboradores          text,
  contenido              text,
  canal_comunicacion     text,
  esquema_capacitacion   text,
  directrices_valores    text,

  -- Vigencia
  vigencia_meses         int,
  fecha_inicio_vigencia  date,
  fecha_vencimiento      date,

  -- Actores del flujo
  levantado_por  text,
  revisado_por   text,
  autorizado_por text,

  -- Timestamps por etapa
  levantamiento_at timestamptz,
  borrador_at      timestamptz,
  revision_at      timestamptz,
  autorizacion_at  timestamptz,
  publicacion_at   timestamptz,

  created_at timestamptz default now(),
  updated_at timestamptz default now(),

  unique(catalogo_id, version)
);

-- HISTORIAL de transiciones de status
create table if not exists pol_historial (
  id              uuid primary key default gen_random_uuid(),
  politica_id     uuid references pol_politicas(id) on delete cascade,
  status_anterior text,
  status_nuevo    text not null,
  actor           text,
  notas           text,
  created_at      timestamptz default now()
);

-- COMENTARIOS del flujo de revisión
create table if not exists pol_comentarios (
  id          uuid primary key default gen_random_uuid(),
  politica_id uuid references pol_politicas(id) on delete cascade,
  autor       text not null,
  comentario  text not null,
  etapa       text,
  resuelto    boolean default false,
  created_at  timestamptz default now()
);

-- TRIGGERS
create or replace function update_pol_updated_at()
returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

create trigger pol_politicas_updated_at
  before update on pol_politicas
  for each row execute function update_pol_updated_at();

create or replace function log_pol_status()
returns trigger as $$
begin
  if old.status is distinct from new.status then
    insert into pol_historial(politica_id, status_anterior, status_nuevo)
    values (new.id, old.status, new.status);
  end if;
  return new;
end;
$$ language plpgsql;

create trigger pol_status_log
  after update on pol_politicas
  for each row execute function log_pol_status();

-- DATOS SEMILLA
insert into pol_empresas (codigo, nombre) values
  ('GM',  'Grupo Morsa'),
  ('EPL', 'Energy Parts LTH')
on conflict (codigo) do nothing;

-- RLS
alter table pol_empresas    enable row level security;
alter table pol_divisiones  enable row level security;
alter table pol_areas       enable row level security;
alter table pol_catalogo    enable row level security;
alter table pol_politicas   enable row level security;
alter table pol_historial   enable row level security;
alter table pol_comentarios enable row level security;

create policy "auth_all" on pol_empresas    for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_divisiones  for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_areas       for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_catalogo    for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_politicas   for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_historial   for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_comentarios for all to authenticated using (true) with check (true);
