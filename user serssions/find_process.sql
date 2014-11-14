set feedback on
set show off
set verify off

accept username PROMPT 'Enter username: '
accept pwd PROMPT 'Ener password: ' HIDE
define p_id = '&process_id'

set term off

create database link psolp_procs connect to &username identified by &pwd using 'PSOLP';
create database link ctp_procs connect to &username identified by &pwd using 'edop';
create database link css_procs connect to &username identified by &pwd using 'cl2prp';
create database link er_procs connect to &username identified by &pwd using 'ersp';

set linesize 300
col sql_text format a100
set term on



select 'PSOLP' as instnace
      ,sesion.process
      ,sesion.sid
      ,serial#
      ,sesion.username
      ,sesion.OSUSER
      ,sesion.program
       ,sql_text
  from v$sqlarea@psolp_procs sqlarea
     , v$session@psolp_procs sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   and sesion.process = '&p_id'
UNION
select 'EDOP'
      ,sesion.process
      ,sesion.sid
      ,serial#
      ,sesion.username
      ,sesion.OSUSER
      ,sesion.program
       ,sql_text
  from v$sqlarea@ctp_procs sqlarea
     , v$session@ctp_procs sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   and sesion.process = '&p_id'
UNION
select 'CL2PRP'
      ,sesion.process
      ,sesion.sid
      ,serial#
      ,sesion.username
      ,sesion.OSUSER
      ,sesion.program
       ,sql_text
  from v$sqlarea@css_procs sqlarea
     , v$session@css_procs sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   and sesion.process = '&p_id'
UNION
select 'ERSP'
      ,sesion.process
      ,sesion.sid
      ,serial#
      ,sesion.username
      ,sesion.OSUSER
      ,sesion.program
       ,sql_text
  from v$sqlarea@er_procs sqlarea
     , v$session@er_procs sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   and sesion.process = '&p_id'
/


set term off
drop database link psolp_procs;
drop database link ctp_procs;
drop database link css_procs;
drop database link er_procs;

set term on