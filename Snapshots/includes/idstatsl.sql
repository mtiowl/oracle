set verify off

set pagesize 40
start includes/idstats.sql &1

/* ***** LIST SQL WITH "FROM" STARTING ON A NEW LINE */       
select sql_text from (
select DECODE(INSTR(UPPER(sql_text),' FROM '),0,sql_text,
              substr(sql_text,1,INSTR(UPPER(sql_text),' FROM '))) sql_text,
       piece,'1' part
  from v$sqltext
 where sql_id='&1'
UNION
select ' '||substr(sql_text,INSTR(UPPER(sql_text),' FROM ')),
       piece,'2' part
  from v$sqltext
 where sql_id='&1'
   and INSTR(UPPER(sql_text),' FROM ')>0)
 order by piece,part;

set linesize 110
col    operation   format a20 head 'EXECUTION PLAN'
col    options     format a15
col    object_name format a20
col    io_cost     format 9999990
col    cardinality format 9999990 head ROWS
col    id          noprint
col    pdate       format a5

break on plan_hash on ptime PAGE
select DISTINCT operation, options, object_name, cost, io_cost,
       cardinality, id, plan_hash_value plan_hash, to_char(timestamp,'MM-DD') pdate
  from sys.v_$sql_plan
 where sql_id='&1'
 order by plan_hash, pdate, id;
