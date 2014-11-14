set pagesize 500
set linesize 300
column objdep format a50 hea "Object Name (Type)"
column refr format a50 hea "Object Reference (Type)"
column dependency_type format a10
column referenced_link_name format a10
break on refr

select referenced_name||' ('||referenced_type||')' refr
      ,owner||'.'||name||' ('||type||')' objdep
      ,dependency_type
      ,referenced_link_name
  from dba_dependencies 
  where owner=user
    and referenced_name = UPPER('&modified_object')
  order by objdep; 
