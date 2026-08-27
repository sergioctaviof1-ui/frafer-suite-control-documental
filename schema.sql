-- ============================================================
-- Frafer Suite Control Documental · Schema v2.1
-- Estructura Organizacional v3.2 — aprobada 2026-08-27
-- 4 Direcciones · 18 Áreas (600–617) · Departamentos reales
-- ============================================================

-- 1. LIMPIAR ESQUEMA ANTERIOR
drop table if exists pol_comentarios   cascade;
drop table if exists pol_historial     cascade;
drop table if exists pol_politicas     cascade;
drop table if exists pol_catalogo      cascade;
drop table if exists pol_actividades   cascade;
drop table if exists pol_departamentos cascade;
drop table if exists pol_areas         cascade;
drop table if exists pol_divisiones    cascade;
drop table if exists pol_direcciones   cascade;

drop function if exists update_pol_updated_at cascade;
drop function if exists log_pol_status        cascade;

-- 2. TABLAS

create table if not exists pol_empresas (
  id         uuid primary key default gen_random_uuid(),
  codigo     text not null unique,
  nombre     text not null,
  activa     boolean default true,
  created_at timestamptz default now()
);

create table pol_direcciones (
  id         uuid primary key default gen_random_uuid(),
  empresa_id uuid references pol_empresas(id) on delete cascade,
  codigo     text not null,
  nombre     text not null,
  tipo       text check (tipo in ('gobierno','soporte','primaria')) default 'soporte',
  orden      int  default 0,
  activa     boolean default true,
  created_at timestamptz default now(),
  unique(empresa_id, codigo)
);

create table pol_areas (
  id           uuid primary key default gen_random_uuid(),
  direccion_id uuid references pol_direcciones(id) on delete cascade,
  numero       text not null,
  nombre       text not null,
  orden        int  default 0,
  activa       boolean default true,
  created_at   timestamptz default now(),
  unique(direccion_id, numero)
);

create table pol_departamentos (
  id         uuid primary key default gen_random_uuid(),
  area_id    uuid references pol_areas(id) on delete cascade,
  nombre     text not null,
  orden      int  default 0,
  activo     boolean default true,
  created_at timestamptz default now()
);

create table pol_actividades (
  id               uuid primary key default gen_random_uuid(),
  area_id          uuid references pol_areas(id) on delete cascade,
  departamento_id  uuid references pol_departamentos(id) on delete set null,
  nombre           text not null,
  descripcion      text,
  tipo             text check (tipo in ('actividad','transaccion','decision')) default 'actividad',
  activa           boolean default true,
  created_at       timestamptz default now()
);

create table pol_catalogo (
  id               uuid primary key default gen_random_uuid(),
  area_id          uuid references pol_areas(id) on delete cascade,
  actividad_id     uuid references pol_actividades(id) on delete set null,
  tipo_documento   text not null check (tipo_documento in ('PLT','PCS','PCD')),
  numero           int  not null,
  codigo_documento text not null unique,
  nombre           text not null,
  descripcion      text,
  prioridad        text check (prioridad in ('alta','media','baja')) default 'media',
  activo           boolean default true,
  created_at       timestamptz default now(),
  unique(area_id, tipo_documento, numero)
);

create table pol_politicas (
  id           uuid primary key default gen_random_uuid(),
  catalogo_id  uuid references pol_catalogo(id) on delete cascade,
  version      int  not null default 1,
  status text not null default 'pendiente' check (status in (
    'pendiente','en_levantamiento','borrador',
    'en_revision','autorizado','publicado','vencido'
  )),
  objeto                  text,
  alcance                 text,
  responsable_direccion   text,
  responsable_elaboracion text,
  colaboradores           text,
  contenido               text,
  canal_comunicacion      text,
  esquema_capacitacion    text,
  directrices_valores     text,
  vigencia_meses          int,
  fecha_inicio_vigencia   date,
  fecha_vencimiento       date,
  levantado_por           text,
  revisado_por            text,
  autorizado_por          text,
  levantamiento_at        timestamptz,
  borrador_at             timestamptz,
  revision_at             timestamptz,
  autorizacion_at         timestamptz,
  publicacion_at          timestamptz,
  created_at              timestamptz default now(),
  updated_at              timestamptz default now(),
  unique(catalogo_id, version)
);

create table pol_historial (
  id              uuid primary key default gen_random_uuid(),
  politica_id     uuid references pol_politicas(id) on delete cascade,
  status_anterior text,
  status_nuevo    text not null,
  actor           text,
  notas           text,
  created_at      timestamptz default now()
);

create table pol_comentarios (
  id          uuid primary key default gen_random_uuid(),
  politica_id uuid references pol_politicas(id) on delete cascade,
  autor       text not null,
  comentario  text not null,
  etapa       text,
  resuelto    boolean default false,
  created_at  timestamptz default now()
);

-- 3. TRIGGERS
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

-- 4. RLS
alter table pol_empresas      enable row level security;
alter table pol_direcciones   enable row level security;
alter table pol_areas         enable row level security;
alter table pol_departamentos enable row level security;
alter table pol_actividades   enable row level security;
alter table pol_catalogo      enable row level security;
alter table pol_politicas     enable row level security;
alter table pol_historial     enable row level security;
alter table pol_comentarios   enable row level security;

create policy "auth_all" on pol_empresas      for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_direcciones   for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_areas         for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_departamentos for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_actividades   for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_catalogo      for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_politicas     for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_historial     for all to authenticated using (true) with check (true);
create policy "auth_all" on pol_comentarios   for all to authenticated using (true) with check (true);

-- ============================================================
-- 5. SEED DATA — Estructura Organizacional v3.3
-- 5 Direcciones · DGR/DAF/DRH/DOP/DCO · 18 Áreas · 57 Deptos
-- ============================================================

-- EMPRESAS
insert into pol_empresas (codigo, nombre) values
  ('GM',  'Grupo Morsa'),
  ('EPL', 'Energy Parts LTH')
on conflict (codigo) do nothing;

-- DIRECCIONES (5) — v3.3
with emp as (select id from pol_empresas where codigo = 'GM')
insert into pol_direcciones (empresa_id, codigo, nombre, tipo, orden)
select emp.id, d.codigo, d.nombre, d.tipo::text, d.orden
from emp, (values
  ('DGR', 'Dirección General',                                            'gobierno', 1),
  ('DAF', 'Dirección de Administración y Finanzas',                       'soporte',  2),
  ('DRH', 'Dirección de Recursos Humanos y Desarrollo Organizacional',    'soporte',  3),
  ('DOP', 'Dirección de Operaciones',                                     'primaria', 4),
  ('DCO', 'Dirección Comercial',                                          'primaria', 5)
) as d(codigo, nombre, tipo, orden)
on conflict do nothing;

-- ÁREAS (18 · 600–617)
insert into pol_areas (direccion_id, numero, nombre, orden)
select dir.id, a.numero, a.nombre, a.orden
from pol_direcciones dir
join (values
  -- DGR · Gobierno
  ('DGR','600','Dirección General',                       1),
  ('DGR','601','Contraloría',                             2),
  ('DGR','602','Auditoría Interna',                       3),
  ('DGR','603','Calidad y Mejora Continua',               4),
  -- DAF · Administración y Finanzas
  ('DAF','604','Administración y Finanzas',               1),
  ('DAF','606','Tecnología e Información',                2),
  ('DAF','607','Jurídico y Legal',                        3),
  ('DAF','608','RSE / ESR',                               4),
  -- DRH · Recursos Humanos
  ('DRH','605','Recursos Humanos',                        1),
  -- DOP · Operaciones Primaria
  ('DOP','609','Logística Interna y Almacén',             1),
  ('DOP','610','Cadena de Suministro',                    2),
  ('DOP','611','Operaciones / Puntos de Venta',           3),
  ('DOP','612','Logística Externa y Distribución',        4),
  -- DCO · Comercial Primaria
  ('DCO','613','Planeación Comercial',                    1),
  ('DCO','614','Product Management',                      2),
  ('DCO','615','Marketing y Comunicación Comercial',      3),
  ('DCO','616','Comercial y Ventas',                      4),
  ('DCO','617','Servicio al Cliente',                     5)
) as a(dir_codigo, numero, nombre, orden) on dir.codigo = a.dir_codigo
on conflict do nothing;

-- DEPARTAMENTOS (solo unidades organizacionales reales)
insert into pol_departamentos (area_id, nombre, orden)
select ar.id, d.nombre, d.orden
from pol_areas ar
join (values
  -- 600 · Dirección General
  ('600','Oficina del Director General',          1),
  ('600','Comité Directivo',                      2),
  ('600','Planeación Estratégica',                3),
  ('600','Comunicación Institucional',            4),
  -- 601 · Contraloría
  ('601','Contraloría',                           1),
  -- 602 · Auditoría Interna
  ('602','Auditoría Interna',                     1),
  -- 603 · Calidad
  ('603','Calidad',                               1),
  -- 604 · Administración y Finanzas
  ('604','Contabilidad',                          1),
  ('604','Tesorería',                             2),
  ('604','Administración Fiscal',                 3),
  ('604','Administración Financiera',             4),
  ('604','Nómina',                                5),
  ('604','Compras de Servicios y Suministros',    6),
  -- 605 · Recursos Humanos
  ('605','Atracción de Talento',                  1),
  ('605','Desarrollo Organizacional',             2),
  ('605','Compensaciones y Beneficios',           3),
  ('605','Relaciones Laborales',                  4),
  ('605','Seguridad e Higiene (SHE)',             5),
  -- 606 · Tecnología e Información
  ('606','Infraestructura y Redes',               1),
  ('606','Sistemas / ERP',                        2),
  ('606','Soporte Técnico',                       3),
  ('606','Seguridad de la Información',           4),
  -- 607 · Jurídico y Legal
  ('607','Corporativo',                           1),
  ('607','Contencioso',                           2),
  -- 608 · RSE / ESR
  ('608','Responsabilidad Social',                1),
  -- 609 · Logística Interna y Almacén
  ('609','Almacén Central',                       1),
  ('609','Recepción y Control de Mercancía',      2),
  ('609','Control de Inventarios',                3),
  -- 610 · Cadena de Suministro
  ('610','Administración de Compras',             1),
  ('610','Importaciones',                         2),
  ('610','Gestión de Proveeduría',                3),
  -- 611 · Operaciones / Puntos de Venta
  ('611','Grupo Morsa — Sucursales',              1),
  ('611','Energy Parts LTH — Tiendas',            2),
  ('611','Canal Mayorista',                       3),
  -- 612 · Logística Externa y Distribución
  ('612','Flota y Distribución',                  1),
  ('612','Abastecimiento a Sucursales',           2),
  ('612','Entrega a Cliente',                     3),
  -- 613 · Planeación Comercial
  ('613','Planeación de la Demanda',              1),
  ('613','Cálculo de Compra',                     2),
  ('613','Análisis Comercial e Inteligencia',     3),
  -- 614 · Product Management
  ('614','Gestión de Categorías',                 1),
  ('614','Pricing y Revenue Management',          2),
  -- 615 · Marketing y Comunicación Comercial
  ('615','Marketing Digital',                     1),
  ('615','Marca y Comunicación',                  2),
  ('615','Promociones y Trade Marketing',         3),
  ('615','Inteligencia de Mercado',               4),
  -- 616 · Comercial y Ventas
  ('616','Ventas Mayoristas',                     1),
  ('616','Ventas Sucursales',                     2),
  ('616','Crédito y Cobranza',                    3),
  -- 617 · Servicio al Cliente
  ('617','Atención al Cliente',                   1),
  ('617','Garantías y Reclamaciones',             2),
  ('617','Postventa',                             3)
) as d(area_num, nombre, orden) on ar.numero = d.area_num;
