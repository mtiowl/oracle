SELECT instance_name "Instance Name" from v$instance;

prompt
Prompt ***************  Objects by Schema  *****************
prompt 
select owner, object_type, count(*)
  from dba_objects
  where owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'WMSYS', 'EXFSYS', 'AIM_ADMINISTRATOR', 'APPQOSSYS', 'CTXSYS', 'DISCO', 'OAS_PUBLIC', 'PPLQUEST', 'XDB', 'WEBSYS', 'ORACLE_OCM')
  group by owner, object_type
  order by object_type, owner
/

prompt
Prompt ***************  Invalid Objects  *****************
prompt 
select owner, object_type, status, count(*)
  from dba_objects
  where owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'WMSYS', 'EXFSYS', 'AIM_ADMINISTRATOR', 'APPQOSSYS', 'CTXSYS', 'DISCO', 'OAS_PUBLIC', 'PPLQUEST', 'XDB', 'WEBSYS', 'ORACLE_OCM')
    and status = 'INVALID'
  group by owner, object_type, status
  order by object_type, owner
/

prompt
Prompt ***************  Large Tables (Over 2 GB in Size)  *****************
prompt 
SELECT t.owner, t.table_name, lpad(to_char(round(s.bytes/1024/1024), '999,999,990'), 12) "MB"
  FROM dba_tables t
      ,dba_segments s
  WHERE t.table_name = s.segment_name
    AND t.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'WMSYS', 'EXFSYS', 'AIM_ADMINISTRATOR', 'APPQOSSYS', 'CTXSYS', 'DISCO', 'OAS_PUBLIC', 'PPLQUEST', 'XDB', 'WEBSYS', 'ORACLE_OCM')
    AND partitioned = 'NO'
    AND round(bytes/1024/1024) > 2000
    --AND rownum < 11
  ORDER BY bytes DESC
/

prompt
prompt ***************  Partitioned Tables  *****************
prompt
SELECT p.table_owner, p.table_name, p.partition_name, p.blocks/1024/1024 "MB", p.compression
  FROM dba_tab_partitions p
  WHERE p.table_owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'WMSYS', 'EXFSYS', 'AIM_ADMINISTRATOR', 'APPQOSSYS', 'CTXSYS', 'DISCO', 'OAS_PUBLIC', 'PPLQUEST', 'XDB', 'WEBSYS', 'ORACLE_OCM')
/

prompt
Prompt ***************  Tables with chained rows  *****************
prompt 
SELECT t.owner, t.table_name, lpad(to_char(chain_cnt, '999,999,990'),12) "Chained Rows", round(chain_cnt/num_rows*100, 1) "%"
  FROM dba_tables t
  WHERE t.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'WMSYS', 'EXFSYS', 'AIM_ADMINISTRATOR', 'APPQOSSYS', 'CTXSYS', 'DISCO', 'OAS_PUBLIC', 'PPLQUEST', 'XDB', 'WEBSYS', 'ORACLE_OCM')
    AND chain_cnt > 0
  ORDER BY chain_cnt DESC
/


prompt
Prompt ***************  Fragmented Tables  (over 1 GB fragmented) *****************
prompt 
select table_name
      ,lpad(to_char(round((blocks*to_number(v.value))/1024/1024,2), '999,999,990.00'), 20) "size (mb)" 
      ,lpad(to_char(round((num_rows*avg_row_len/1024/1024),2), '999,999,990.00'), 20) "actual_data (mb)"
      ,lpad(to_char((round((blocks*to_number(v.value))/1024/1024,2) - round((num_rows*avg_row_len/1024/1024),2)), '999,999,990.00'), 20) "wasted_space (mb)"
from dba_tables t
    ,v$parameter v
where round((blocks*to_number(v.value)),2) > round(num_rows*avg_row_len,2)
  and v.name = 'db_block_size'
  and (round((blocks*to_number(v.value))/1024/1024,2) - round((num_rows*avg_row_len/1024/1024),2)) > 1000
order by 4 desc
/


prompt
Prompt ***************  Candidates for Index Compression   *****************
prompt 
@ic.sql