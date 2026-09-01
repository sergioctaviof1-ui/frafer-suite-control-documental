-- ============================================================
-- Migración v4 — Campos faltantes en pol_politicas
-- Ejecutar en Supabase SQL Editor
-- ============================================================

-- Agregar columnas que el formulario usa pero no existían en el schema v2.1
alter table pol_politicas
  add column if not exists definiciones  text,
  add column if not exists sanciones     text,
  add column if not exists excepciones   text,
  add column if not exists num_reglas    int;

-- Verificar resultado
select column_name, data_type
from information_schema.columns
where table_name = 'pol_politicas'
  and column_name in ('definiciones','sanciones','excepciones','num_reglas')
order by column_name;
