-- ============================================================
-- Migración v7 — Estructura completa de política (3 secciones nuevas)
-- Ejecutar en Supabase SQL Editor (proyecto lygpotmaneqgewjcetzw)
-- ============================================================

alter table pol_politicas
  add column if not exists marco_normativo       text,
  add column if not exists responsabilidades     text,
  add column if not exists controles_cumplimiento text;

-- Verificar
select column_name, data_type
from information_schema.columns
where table_name = 'pol_politicas'
  and column_name in ('marco_normativo','responsabilidades','controles_cumplimiento')
order by column_name;
