-- ============================================================
-- Migración v3.3 — 5 Direcciones (DGR / DAF / DRH / DOP / DCO)
-- Corre este script en Supabase SQL Editor
-- ============================================================

-- 1. Renombrar DG → DGR
update pol_direcciones set codigo = 'DGR', nombre = 'Dirección General'
where codigo = 'DG';

-- 2. Renombrar DA → DAF y actualizar nombre
update pol_direcciones set codigo = 'DAF', nombre = 'Dirección de Administración y Finanzas'
where codigo = 'DA';

-- 3. Renombrar DO → DOP
update pol_direcciones set codigo = 'DOP', nombre = 'Dirección de Operaciones'
where codigo = 'DO';

-- 4. Renombrar DC → DCO
update pol_direcciones set codigo = 'DCO', nombre = 'Dirección Comercial'
where codigo = 'DC';

-- 5. Crear nueva Dirección DRH
with emp as (select id from pol_empresas where codigo = 'GM')
insert into pol_direcciones (empresa_id, codigo, nombre, tipo, orden)
select emp.id, 'DRH', 'Dirección de Recursos Humanos y Desarrollo Organizacional', 'soporte', 3
from emp
on conflict do nothing;

-- Reordenar: DOP = 4, DCO = 5
update pol_direcciones set orden = 4 where codigo = 'DOP';
update pol_direcciones set orden = 5 where codigo = 'DCO';

-- 6. Mover Área 605 (Recursos Humanos) a DRH
update pol_areas
set direccion_id = (select id from pol_direcciones where codigo = 'DRH')
where numero = '605';

-- Reordenar áreas dentro de DAF (604 queda en 1, 606→2, 607→3, 608→4)
update pol_areas set orden = 1 where numero = '604';
update pol_areas set orden = 2 where numero = '606';
update pol_areas set orden = 3 where numero = '607';
update pol_areas set orden = 4 where numero = '608';

-- Verificar resultado
select dir.codigo, dir.nombre, dir.orden, ar.numero, ar.nombre as area
from pol_direcciones dir
left join pol_areas ar on ar.direccion_id = dir.id
order by dir.orden, ar.orden;
