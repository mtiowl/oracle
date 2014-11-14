set pagesize 500
set linesize 200
column objdep format a40 hea "Object Name (Type)"
column refr format a100 hea "Object Reference (Type)"
break on objdep

select owner||'.'||name||' ('||decode(type,  'MATERIALIZED VIEW', 'MV'
                                            ,'DIMENSION', 'DIM'
                                            ,'EVALUATION CONTXT', 'EVALCTXT'
                                            , 'PACKAGE BODY', 'PKGBDY'
                                            ,'CUBE.DIMENSION','CUBE.DIM', type)||')' objdep
       ,referenced_name||' ('||decode(referenced_type, 'EVALUATION CONTXT', 'EVALCTXT'
                                                     , 'NON-EXISTENT CONTXT','NO-EXIST'
                                                     , 'PACKAGE BODY','PKGBDY'
                                                     , 'CUBE.DIMENSION','CUBE.DIM', referenced_type)||')' refr
  from dba_dependencies 
  where owner=user
    and name = upper('&modified_object')
  order by objdep; 
