rem   utlxpls.sql
rem
rem   MY VERSION OF $ORACLE_HOME/RDBMS/ADMIN/UTLXPLS.SQL
rem   THE PARTITION INFORMATION HAS BEEN REMOVED
Rem
Rem $Header: utlxpls.sql 25-may-98.16:30:44 bdagevil Exp $
Rem
Rem utlxpls.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      utlxpls.sql - UTiLity eXPLain Serial plans
Rem
Rem    DESCRIPTION
Rem      script utility to display the explain plan of the last explain plan
Rem   command. Do not display information related to Parallel Query
Rem
Rem    NOTES
Rem      Assume that the PLAN_TABLE table has been created. The script 
Rem   utlxplan.sql should be used to create that table
Rem
Rem      To avoid lines from truncating or wrapping around:
Rem         'set charwidth 80' in svrmgrl
Rem       'set linesize  80' in SQL*Plus
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bdagevil    05/07/98 - Explain plan script for serial plans             
Rem    bdagevil    05/07/98 - Created
Rem
Rem
Rem Display last explain plan
Rem


select '| Operation                        |  Name                         |  Rows | Bytes|  Cost |'  as "Plan Table" from dual
union all
select '-------------------------------------------------------------------------------------------' from dual
union all
select rpad('| '||substr(lpad(' ',1*(level-1))||operation||
            decode(options, null,'',' '||options), 1, 34), 35, ' ')||'|'||
       rpad(substr(object_name||' ',1, 30), 30, ' ')||'|'||
       lpad(decode(cardinality,null,'  ',
                decode(sign(cardinality-1000), -1, cardinality||' ',
            decode(sign(cardinality-1000000), -1, trunc(cardinality/1000)||'K',
      decode(sign(cardinality-1000000000), -1, trunc(cardinality/1000000)||'M',
                       trunc(cardinality/1000000000)||'G')))), 7, ' ') || '|' ||
       lpad(decode(bytes,null,' ',
                decode(sign(bytes-1024), -1, bytes||' ', 
                decode(sign(bytes-1048576), -1, trunc(bytes/1024)||'K', 
                decode(sign(bytes-1073741824), -1, trunc(bytes/1048576)||'M', 
                       trunc(bytes/1073741824)||'G')))), 6, ' ') || '|' ||
       lpad(decode(cost,null,' ',
                decode(sign(cost-10000000), -1, cost||' ', 
                decode(sign(cost-1000000000), -1, trunc(cost/1000000)||'M', 
                trunc(cost/1000000000)||'G'))), 7, ' ') ||
        '|' as "Explain plan"
--from plan_table
from sqln_explain_plan
start with id=0 AND statement_id = 'MTI'
connect by prior id = parent_id 
        and prior nvl(statement_id, ' ') = nvl(statement_id, ' ')
        and prior timestamp <= timestamp
union all
select '--------------------------------------------------------------------------------' from dual
/