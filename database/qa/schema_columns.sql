-- JanastolMeds QA: list JMEDS columns as TABLE|COLUMN|TYPE|NULL in JM-DOC-03 notation,
-- for .github/scripts/check-schema-vs-design.sh. Standard audit and soft-delete columns are excluded
-- (JM-DOC-03 section 1; jm_ut_schema checks their types).
set heading off feedback off pagesize 0 linesize 300 trimspool on
select c.table_name || '|' || c.column_name || '|' ||
       case
         when c.data_type = 'VARCHAR2' then
              'VARCHAR2(' || c.char_length || case c.char_used when 'C' then ' CHAR' end || ')'
         when c.data_type = 'NUMBER' then
              case when c.data_precision is null then 'NUMBER'
                   when nvl(c.data_scale, 0) = 0 then 'NUMBER(' || c.data_precision || ')'
                   else 'NUMBER(' || c.data_precision || ',' || c.data_scale || ')' end
         when c.data_type like 'TIMESTAMP(%) WITH LOCAL TIME ZONE' then 'TIMESTAMP WITH LOCAL TIME ZONE'
         else c.data_type
       end || '|' || c.nullable
  from user_tab_columns c
  join user_tables t on t.table_name = c.table_name
 where c.table_name like 'JM\_%' escape '\'
   and c.column_name not in ('CREATED_BY', 'CREATED_ON', 'UPDATED_BY', 'UPDATED_ON', 'ROW_VERSION',
                             'RECORD_STATUS', 'DELETED_ON', 'DELETED_BY', 'DELETE_REASON')
 order by c.table_name, c.column_id;
