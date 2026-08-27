-- ============================================================
-- Seed Actividades v1.0 — Grupo Morsa
-- Catálogo de actividades por departamento
-- Corre en Supabase SQL Editor DESPUÉS de migrate_v3.3.sql
-- ============================================================

insert into pol_actividades (area_id, departamento_id, nombre, tipo)
select ar.id, dp.id, a.nombre, 'actividad'
from pol_areas ar
join pol_departamentos dp on dp.area_id = ar.id
join (values

  -- ── DGR · DIRECCIÓN GENERAL ──────────────────────────────────
  -- 600 · Dirección General
  ('600','Oficina del Director General',       'Gestión de agenda directiva'),
  ('600','Oficina del Director General',       'Atención de stakeholders clave'),
  ('600','Oficina del Director General',       'Seguimiento a indicadores del negocio'),
  ('600','Comité Directivo',                   'Convocatoria y sesión de comité'),
  ('600','Comité Directivo',                   'Seguimiento a acuerdos y minutas'),
  ('600','Comité Directivo',                   'Reporte a consejo / socios'),
  ('600','Planeación Estratégica',             'Elaboración del plan estratégico'),
  ('600','Planeación Estratégica',             'Seguimiento a iniciativas estratégicas'),
  ('600','Planeación Estratégica',             'Gestión de KPIs corporativos'),
  ('600','Comunicación Institucional',         'Comunicación interna'),
  ('600','Comunicación Institucional',         'Comunicación externa e imagen corporativa'),

  -- 601 · Contraloría
  ('601','Contraloría',                        'Control interno'),
  ('601','Contraloría',                        'Cumplimiento normativo'),
  ('601','Contraloría',                        'Gestión de riesgos'),

  -- 602 · Auditoría Interna
  ('602','Auditoría Interna',                  'Planeación de auditorías'),
  ('602','Auditoría Interna',                  'Ejecución de auditoría'),
  ('602','Auditoría Interna',                  'Emisión de informe de hallazgos'),
  ('602','Auditoría Interna',                  'Seguimiento a hallazgos'),

  -- 603 · Calidad y Mejora Continua
  ('603','Calidad',                            'Gestión del sistema de calidad'),
  ('603','Calidad',                            'Auditoría de calidad interna'),
  ('603','Calidad',                            'Gestión de no conformidades'),
  ('603','Calidad',                            'Mejora continua / Lean'),

  -- ── DAF · DIRECCIÓN DE ADMINISTRACIÓN Y FINANZAS ─────────────
  -- 604 · Administración y Finanzas
  ('604','Contabilidad',                       'Registro contable (pólizas)'),
  ('604','Contabilidad',                       'Conciliaciones bancarias'),
  ('604','Contabilidad',                       'Cierre mensual y anual'),
  ('604','Tesorería',                          'Gestión de flujo de caja'),
  ('604','Tesorería',                          'Pagos a proveedores'),
  ('604','Tesorería',                          'Cobranza y aplicación de pagos'),
  ('604','Administración Fiscal',              'Declaraciones fiscales (ISR / IVA / IMSS)'),
  ('604','Administración Fiscal',              'Facturación electrónica (CFDI)'),
  ('604','Administración Fiscal',              'Atención a requerimientos SAT'),
  ('604','Administración Financiera',          'Presupuesto y control presupuestal'),
  ('604','Administración Financiera',          'Análisis financiero y variaciones'),
  ('604','Administración Financiera',          'Forecasting y proyecciones'),
  ('604','Nómina',                             'Cálculo de nómina ordinaria'),
  ('604','Nómina',                             'Finiquitos y liquidaciones'),
  ('604','Nómina',                             'Obligaciones patronales (IMSS / Infonavit)'),
  ('604','Compras de Servicios y Suministros', 'Solicitud y cotización de servicios'),
  ('604','Compras de Servicios y Suministros', 'Orden de compra de servicios'),
  ('604','Compras de Servicios y Suministros', 'Control de contratos de servicios'),

  -- 606 · Tecnología e Información
  ('606','Infraestructura y Redes',            'Gestión de red y conectividad'),
  ('606','Infraestructura y Redes',            'Administración de servidores'),
  ('606','Infraestructura y Redes',            'Respaldo y recuperación de información'),
  ('606','Sistemas / ERP',                     'Administración y configuración del ERP'),
  ('606','Sistemas / ERP',                     'Desarrollos y customizaciones'),
  ('606','Sistemas / ERP',                     'Gestión de licencias y actualizaciones'),
  ('606','Soporte Técnico',                    'Mesa de ayuda (tickets)'),
  ('606','Soporte Técnico',                    'Soporte a usuarios (hardware / software)'),
  ('606','Soporte Técnico',                    'Gestión de activos tecnológicos'),
  ('606','Seguridad de la Información',        'Gestión de accesos y permisos'),
  ('606','Seguridad de la Información',        'Monitoreo de ciberseguridad'),
  ('606','Seguridad de la Información',        'Recuperación ante desastres (DR)'),

  -- 607 · Jurídico y Legal
  ('607','Corporativo',                        'Revisión y elaboración de contratos'),
  ('607','Corporativo',                        'Actas de asamblea y poderes notariales'),
  ('607','Corporativo',                        'Asesoría legal a dirección'),
  ('607','Contencioso',                        'Gestión de litigios y demandas'),
  ('607','Contencioso',                        'Atención a autoridades (SAT / STPS / PROFECO)'),
  ('607','Contencioso',                        'Recuperación de cartera por vía legal'),

  -- 608 · RSE / ESR
  ('608','Responsabilidad Social',             'Programas de responsabilidad social'),
  ('608','Responsabilidad Social',             'Donaciones y patrocinios'),
  ('608','Responsabilidad Social',             'Reporte de sustentabilidad'),

  -- ── DRH · DIRECCIÓN DE RECURSOS HUMANOS ──────────────────────
  -- 605 · Recursos Humanos
  ('605','Atracción de Talento',               'Requisición de personal'),
  ('605','Atracción de Talento',               'Reclutamiento y selección'),
  ('605','Atracción de Talento',               'Contratación e inducción'),
  ('605','Desarrollo Organizacional',          'Detección de necesidades de capacitación (DNC)'),
  ('605','Desarrollo Organizacional',          'Programas de capacitación'),
  ('605','Desarrollo Organizacional',          'Evaluación de desempeño'),
  ('605','Desarrollo Organizacional',          'Planes de carrera y sucesión'),
  ('605','Compensaciones y Beneficios',        'Administración de tabulador salarial'),
  ('605','Compensaciones y Beneficios',        'Gestión de beneficios'),
  ('605','Compensaciones y Beneficios',        'Bonos e incentivos'),
  ('605','Relaciones Laborales',               'Gestión de contrato colectivo'),
  ('605','Relaciones Laborales',               'Atención de conflictos laborales'),
  ('605','Relaciones Laborales',               'Trámites ante IMSS / STPS'),
  ('605','Seguridad e Higiene (SHE)',          'Gestión de comisiones mixtas de seguridad'),
  ('605','Seguridad e Higiene (SHE)',          'Inspecciones y programas de prevención'),
  ('605','Seguridad e Higiene (SHE)',          'Atención de accidentes e incidentes'),

  -- ── DOP · DIRECCIÓN DE OPERACIONES ───────────────────────────
  -- 609 · Logística Interna y Almacén
  ('609','Almacén Central',                    'Control de entradas al almacén'),
  ('609','Almacén Central',                    'Control de salidas del almacén'),
  ('609','Almacén Central',                    'Gestión de mermas y devoluciones'),
  ('609','Recepción y Control de Mercancía',   'Recepción física de mercancía'),
  ('609','Recepción y Control de Mercancía',   'Verificación de pedido vs. recepción'),
  ('609','Recepción y Control de Mercancía',   'Inspección de calidad en recepción'),
  ('609','Control de Inventarios',             'Conteos cíclicos'),
  ('609','Control de Inventarios',             'Inventario físico general'),
  ('609','Control de Inventarios',             'Ajustes de inventario'),
  ('609','Control de Inventarios',             'Análisis de rotación y obsolescencia'),

  -- 610 · Cadena de Suministro
  ('610','Administración de Compras',          'Generación de órdenes de compra'),
  ('610','Administración de Compras',          'Seguimiento y confirmación de pedidos'),
  ('610','Administración de Compras',          'Negociación de condiciones con proveedores'),
  ('610','Importaciones',                      'Gestión aduanal y documentación'),
  ('610','Importaciones',                      'Coordinación con agente aduanal'),
  ('610','Importaciones',                      'Cálculo y pago de aranceles'),
  ('610','Gestión de Proveeduría',             'Alta y validación de proveedores'),
  ('610','Gestión de Proveeduría',             'Contratos marco con proveedores'),
  ('610','Gestión de Proveeduría',             'Evaluación de desempeño de proveedores'),

  -- 611 · Operaciones / Puntos de Venta
  ('611','Grupo Morsa — Sucursales',           'Apertura y cierre de sucursal'),
  ('611','Grupo Morsa — Sucursales',           'Gestión de caja y corte'),
  ('611','Grupo Morsa — Sucursales',           'Surtido y exhibición'),
  ('611','Energy Parts LTH — Tiendas',         'Operación de tienda especializada'),
  ('611','Energy Parts LTH — Tiendas',         'Venta técnica de refacciones'),
  ('611','Energy Parts LTH — Tiendas',         'Gestión de inventario en tienda'),
  ('611','Canal Mayorista',                    'Atención a clientes mayoristas'),
  ('611','Canal Mayorista',                    'Procesamiento de pedidos mayoreo'),
  ('611','Canal Mayorista',                    'Condiciones comerciales mayoreo'),

  -- 612 · Logística Externa y Distribución
  ('612','Flota y Distribución',               'Gestión de vehículos y mantenimiento'),
  ('612','Flota y Distribución',               'Asignación de rutas'),
  ('612','Flota y Distribución',               'Monitoreo GPS y cumplimiento de ruta'),
  ('612','Abastecimiento a Sucursales',        'Cálculo de necesidades por sucursal'),
  ('612','Abastecimiento a Sucursales',        'Picking y packing'),
  ('612','Abastecimiento a Sucursales',        'Despacho y confirmación de recepción'),
  ('612','Entrega a Cliente',                  'Programación de entregas'),
  ('612','Entrega a Cliente',                  'Entrega y firma de conformidad'),
  ('612','Entrega a Cliente',                  'Gestión de devoluciones en entrega'),

  -- ── DCO · DIRECCIÓN COMERCIAL ─────────────────────────────────
  -- 613 · Planeación Comercial
  ('613','Planeación de la Demanda',           'Análisis de históricos de venta'),
  ('613','Planeación de la Demanda',           'Elaboración de forecast de demanda'),
  ('613','Planeación de la Demanda',           'Validación con equipo comercial'),
  ('613','Cálculo de Compra',                  'Determinación de necesidades de compra'),
  ('613','Cálculo de Compra',                  'Cálculo de OTB (Open to Buy)'),
  ('613','Cálculo de Compra',                  'Liberación del plan de compras'),
  ('613','Análisis Comercial e Inteligencia',  'Análisis de sell-out por SKU / categoría'),
  ('613','Análisis Comercial e Inteligencia',  'Benchmarking competitivo'),
  ('613','Análisis Comercial e Inteligencia',  'Reportes de desempeño comercial'),

  -- 614 · Product Management
  ('614','Gestión de Categorías',              'Definición de surtido por categoría'),
  ('614','Gestión de Categorías',              'Alta y baja de productos'),
  ('614','Gestión de Categorías',              'Gestión del ciclo de vida del producto'),
  ('614','Pricing y Revenue Management',       'Definición de precios de lista'),
  ('614','Pricing y Revenue Management',       'Gestión de márgenes por categoría'),
  ('614','Pricing y Revenue Management',       'Actualización de precios en sistema'),

  -- 615 · Marketing y Comunicación Comercial
  ('615','Marketing Digital',                  'Gestión de redes sociales'),
  ('615','Marketing Digital',                  'Campañas digitales (SEM / SEO)'),
  ('615','Marketing Digital',                  'Análisis de métricas digitales'),
  ('615','Marca y Comunicación',               'Gestión de identidad de marca'),
  ('615','Marca y Comunicación',               'Producción de materiales de comunicación'),
  ('615','Marca y Comunicación',               'Calendario editorial'),
  ('615','Promociones y Trade Marketing',      'Diseño de promociones'),
  ('615','Promociones y Trade Marketing',      'Ejecución en punto de venta'),
  ('615','Promociones y Trade Marketing',      'Medición de efectividad de promociones'),
  ('615','Inteligencia de Mercado',            'Investigación de mercado'),
  ('615','Inteligencia de Mercado',            'Análisis de competencia'),
  ('615','Inteligencia de Mercado',            'Tendencias del sector automotriz'),

  -- 616 · Comercial y Ventas
  ('616','Ventas Mayoristas',                  'Prospección y desarrollo de cuentas'),
  ('616','Ventas Mayoristas',                  'Negociación y cierre de venta mayoreo'),
  ('616','Ventas Mayoristas',                  'Gestión de pedidos mayoreo'),
  ('616','Ventas Sucursales',                  'Gestión de fuerza de ventas en sucursal'),
  ('616','Ventas Sucursales',                  'Metas y seguimiento de vendedores'),
  ('616','Ventas Sucursales',                  'Cierre y reporte de ventas diarias'),
  ('616','Crédito y Cobranza',                 'Análisis y autorización de crédito'),
  ('616','Crédito y Cobranza',                 'Facturación a crédito'),
  ('616','Crédito y Cobranza',                 'Gestión de cobranza'),
  ('616','Crédito y Cobranza',                 'Cartera vencida y castigos'),

  -- 617 · Servicio al Cliente
  ('617','Atención al Cliente',                'Recepción y atención de consultas'),
  ('617','Atención al Cliente',                'Gestión de quejas y reclamaciones'),
  ('617','Atención al Cliente',                'Escalamiento y seguimiento a resolución'),
  ('617','Garantías y Reclamaciones',          'Recepción de garantía'),
  ('617','Garantías y Reclamaciones',          'Validación y dictamen'),
  ('617','Garantías y Reclamaciones',          'Reposición o devolución'),
  ('617','Postventa',                          'Encuestas de satisfacción'),
  ('617','Postventa',                          'Programa de fidelización'),
  ('617','Postventa',                          'Gestión de devoluciones y cambios')

) as a(area_num, dept_nombre, nombre)
  on ar.numero = a.area_num
 and dp.nombre = a.dept_nombre;

-- Verificar total insertado
select count(*) as total_actividades from pol_actividades;
