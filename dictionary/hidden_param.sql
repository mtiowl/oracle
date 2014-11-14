SET linesize 235
col Parameter FOR a50
col SESSION FOR a28
col Instance FOR a55
col S FOR a1
col I FOR a1
col D FOR a1
col Description FOR a90

SELECT  
  a.ksppinm  "Parameter", 
  decode(p.isses_modifiable,'FALSE',NULL,NULL,NULL,b.ksppstvl) "Session", 
  c.ksppstvl "Instance",
  decode(p.isses_modifiable,'FALSE','F','TRUE','T') "S",
  decode(p.issys_modifiable,'FALSE','F','TRUE','T','IMMEDIATE','I','DEFERRED','D') "I",
  decode(p.isdefault,'FALSE','F','TRUE','T') "D",
  a.ksppdesc "Description"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c, v$parameter p
WHERE a.indx = b.indx AND a.indx = c.indx
  AND p.name(+) = a.ksppinm
  AND UPPER(a.ksppinm) LIKE UPPER('%&1%')
ORDER BY a.ksppinm;