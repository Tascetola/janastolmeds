-- JanastolMeds QA: deterministic snapshot of the JMEDS schema definition, for before/after comparison
-- (rollback test, environment comparison). Excludes names Oracle generates itself (identity sequences,
-- LOB and system NOT NULL constraint names) so two builds of the same changelog compare equal.
set heading off feedback off pagesize 0 linesize 4000 trimspool on long 1000000 longchunksize 1000000
select 'TABLE|' || table_name from user_tables where table_name like 'JM\_%' escape '\' order by 1;
select 'COLUMN|' || table_name || '|' || column_id || '|' || column_name || '|' || data_type || '|' || data_length || '|' ||
       data_precision || '|' || data_scale || '|' || char_used || '|' || nullable || '|' || identity_column || '|' || virtual_column
  from user_tab_cols where table_name like 'JM\_%' escape '\' and hidden_column = 'NO' order by table_name, column_id;
select 'CONSTRAINT|' || c.table_name || '|' || case when c.constraint_name like 'SYS\_%' escape '\' then '(system)' else c.constraint_name end || '|' ||
       c.constraint_type || '|' || c.search_condition_vc || '|' || c.r_constraint_name || '|' || c.delete_rule || '|' || c.status || '|' ||
       (select listagg(cc.column_name, ',') within group (order by cc.position) from user_cons_columns cc where cc.constraint_name = c.constraint_name)
  from user_constraints c where c.table_name like 'JM\_%' escape '\' order by 1;
select 'INDEX|' || i.table_name || '|' || i.index_name || '|' || i.uniqueness || '|' || i.index_type || '|' ||
       (select listagg(ic.column_name || ' ' || ic.descend, ',') within group (order by ic.column_position) from user_ind_columns ic where ic.index_name = i.index_name)
  from user_indexes i where i.table_name like 'JM\_%' escape '\' and i.index_type <> 'LOB' order by 1;
select 'FBI|' || ie.index_name || '|' || ie.column_position || '|' || ie.column_expression
  from user_ind_expressions ie where ie.table_name like 'JM\_%' escape '\' order by ie.index_name, ie.column_position;
select 'SEQUENCE|' || sequence_name || '|' || min_value || '|' || increment_by || '|' || cache_size || '|' || cycle_flag || '|' || order_flag
  from user_sequences where sequence_name like 'JM\_%' escape '\' order by 1;
select 'TRIGGER|' || trigger_name || '|' || table_name || '|' || trigger_type || '|' || triggering_event || '|' || status
  from user_triggers where table_name like 'JM\_%' escape '\' order by 1;
select 'SOURCE|' || name || '|' || type || '|' || line || '|' || rtrim(text, chr(10))
  from user_source where name like 'JM\_%' escape '\' and name not like 'JM\_UT\_%' escape '\' order by name, type, line;
select 'JOB|' || job_name || '|' || enabled || '|' || repeat_interval || '|' || job_type
  from user_scheduler_jobs where job_name like 'JM\_%' escape '\' order by 1;
select 'ROWS|JM_ROLES|' || count(*) from jm_roles;
select 'ROWS|JM_DEPARTMENTS|' || count(*) from jm_departments;
select 'ROWS|JM_LOOKUPS|' || count(*) from jm_lookups;
select 'ROWS|JM_ICD10_CODES|' || count(*) from jm_icd10_codes;
