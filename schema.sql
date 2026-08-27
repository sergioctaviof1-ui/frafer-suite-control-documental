-- ============================================================
-- Sistema de Control Documental — Grupo Morsa
-- Frafer Consulting · Schema v2.0
-- Arquitectura de 5 niveles con catálogos base pre-alimentados
-- ============================================================

-- 1. LIMPIAR ESQUEMA ANTERIOR
drop table if exists pol_comentarios  cascade;
drop table if exists pol_historial    cascade;
drop table if exists pol_politicas    cascade;
drop table if exists pol_catalogo     cascade;
drop table if exists pol_actividades  cascade;
drop table if exists pol_departamentos cascade;
drop table if exists pol_areas        cascade;
drop table if exists pol_divisiones   cascade;
drop table if exists pol_direcciones  cascade;

drop function if exists update_pol_updated_at cascade;
drop function if exists log_pol_status        cascade;

-- 2. TABLAS

-- EMPRESAS (ya existe con GM y EPL)
create table if not exists pol_empresas (
  id         uuid primary key default gen_random_uuid(),
  codigo     text not null unique,
  nombre     text not null,
  activa     boolean default true,
  created_at timestamptz default now()
);

-- DIRECCIONES
create table pol_direcciones (
  id         uuid primary key default gen_random_uuid(),
  empresa_id uuid references pol_empresas(id) on delete cascade,
  codigo     text not null,          -- DG, DA, DO, DC
  nombre     text not null,
  tipo       text check (tipo in ('gobierno','soporte','primaria')) default 'soporte',
  orden      int  default 0,
  activa     boolean default true,
  created_at timestamptz default now(),
  unique(empresa_id, codigo)
);

-- ÁREAS (600–613)
create table pol_areas (
  id           uuid primary key default gen_random_uuid(),
  direccion_id uuid references pol_direcciones(id) on delete cascade,
  numero       text not null,        -- '600', '601', etc.
  nombre       text not null,
  orden        int  default 0,
  activa       boolean default true,
  created_at   timestamptz default now(),
  unique(direccion_id, numero)
);

-- DEPARTAMENTOS
create table pol_departamentos (
  id         uuid primary key default gen_random_uuid(),
  area_id    uuid references pol_areas(id) on delete cascade,
  nombre     text not null,
  orden      int  default 0,
  activo     boolean default true,
  created_at timestamptz default now()
);

-- ACTIVIDADES / TRANSACCIONES
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

-- CATÁLOGO DE DOCUMENTOS
create table pol_catalogo (
  id               uuid primary key default gen_random_uuid(),
  area_id          uuid references pol_areas(id) on delete cascade,
  actividad_id     uuid references pol_actividades(id) on delete set null,
  tipo_documento   text not null check (tipo_documento in ('PLT','PCS','PCD')),
  numero           int  not null,
  codigo_documento text not null unique,   -- PLT-DA-604-001
  nombre           text not null,
  descripcion      text,
  prioridad        text check (prioridad in ('alta','media','baja')) default 'media',
  activo           boolean default true,
  created_at       timestamptz default now(),
  unique(area_id, tipo_documento, numero)
);

-- POLÍTICAS / DOCUMENTOS
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

-- HISTORIAL
create table pol_historial (
  id              uuid primary key default gen_random_uuid(),
  politica_id     uuid references pol_politicas(id) on delete cascade,
  status_anterior text,
  status_nuevo    text not null,
  actor           text,
  notas           text,
  created_at      timestamptz default now()
);

-- COMENTARIOS
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
-- 5. SEED DATA — Catálogos Base (Propuesta Frafer · Grupo Morsa)
-- ============================================================

-- EMPRESAS
insert into pol_empresas (codigo, nombre) values
  ('GM',  'Grupo Morsa'),
  ('EPL', 'Energy Parts LTH')
on conflict (codigo) do nothing;

-- DIRECCIONES
with emp as (select id from pol_empresas where codigo = 'GM')
insert into pol_direcciones (empresa_id, codigo, nombre, tipo, orden)
select emp.id, d.codigo, d.nombre, d.tipo::text, d.orden
from emp, (values
  ('DG', 'Dirección General',                         'gobierno', 1),
  ('DA', 'Dirección Administrativa y Capital Humano', 'soporte',  2),
  ('DO', 'Dirección de Operaciones',                  'primaria', 3),
  ('DC', 'Dirección Comercial',                       'primaria', 4)
) as d(codigo, nombre, tipo, orden)
on conflict do nothing;

-- ÁREAS
insert into pol_areas (direccion_id, numero, nombre, orden)
select dir.id, a.numero, a.nombre, a.orden
from pol_direcciones dir
join (values
  ('DG','600','Dirección General y Gobierno Corporativo', 1),
  ('DG','601','Contraloría',                              2),
  ('DG','602','Auditoría Interna',                        3),
  ('DG','603','Calidad y Mejora Continua',                4),
  ('DA','604','Administración y Finanzas',                1),
  ('DA','605','Recursos Humanos',                         2),
  ('DA','606','Tecnología e Información',                 3),
  ('DA','607','Jurídico y Legal',                         4),
  ('DA','608','RSE / ESR',                                5),
  ('DO','609','Logística y Almacén',                      1),
  ('DO','610','Operaciones (Sucursales y Tiendas)',        2),
  ('DC','611','Compras y Abastecimiento de Producto',     1),
  ('DC','612','Comercial y Ventas',                       2),
  ('DC','613','Servicio al Cliente',                      3)
) as a(dir_codigo, numero, nombre, orden) on dir.codigo = a.dir_codigo
on conflict do nothing;

-- DEPARTAMENTOS
insert into pol_departamentos (area_id, nombre, orden)
select ar.id, d.nombre, d.orden
from pol_areas ar
join (values
  ('600','Consejo Administrativo',             1),
  ('600','Planeación Estratégica',             2),
  ('600','Comunicación Institucional',         3),
  ('601','Control Presupuestal',               1),
  ('601','Control de Gestión',                 2),
  ('601','Reportes Directivos',                3),
  ('602','Auditoría de Sucursales',            1),
  ('602','Control Interno',                    2),
  ('602','Gestión de Riesgos',                 3),
  ('603','Gestión de Calidad',                 1),
  ('603','Mejora de Procesos',                 2),
  ('603','Certificaciones',                    3),
  ('604','Contabilidad',                       1),
  ('604','Tesorería',                          2),
  ('604','Fiscal e Impuestos',                 3),
  ('604','Nómina',                             4),
  ('604','Compras de Servicios y Suministros', 5),
  ('605','Reclutamiento y Selección',          1),
  ('605','Capacitación y Desarrollo',          2),
  ('605','Compensaciones y Beneficios',        3),
  ('605','Relaciones Laborales',               4),
  ('605','Seguridad e Higiene',                5),
  ('606','Infraestructura y Redes',            1),
  ('606','Sistemas / ERP',                     2),
  ('606','Soporte Técnico',                    3),
  ('606','Seguridad de la Información',        4),
  ('607','Contratos',                          1),
  ('607','Litigios y Cumplimiento',            2),
  ('607','Poderes y Actos Corporativos',       3),
  ('608','Responsabilidad Social',             1),
  ('608','Medio Ambiente',                     2),
  ('608','Comunidad y Bienestar',              3),
  ('609','Recepción de Mercancía',             1),
  ('609','Almacén Central',                    2),
  ('609','Distribución y Flota',               3),
  ('609','Control de Inventarios',             4),
  ('610','Grupo Morsa — Sucursales',           1),
  ('610','Energy Parts LTH — Tiendas',         2),
  ('610','Puntos Mayoristas',                  3),
  ('611','Compras Nacionales',                 1),
  ('611','Importaciones',                      2),
  ('611','Gestión de Proveedores',             3),
  ('611','Planeación de la Demanda',           4),
  ('612','Ventas Mayoristas',                  1),
  ('612','Ventas Sucursales',                  2),
  ('612','Precios y Catálogo',                 3),
  ('612','Crédito y Cobranza',                 4),
  ('613','Atención al Cliente',                1),
  ('613','Garantías y Reclamaciones',          2),
  ('613','Postventa',                          3)
) as d(area_num, nombre, orden) on ar.numero = d.area_num;
