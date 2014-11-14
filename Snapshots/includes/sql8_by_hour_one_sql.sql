--           h:\sql\u\sql8_by_hour_one_sql.txt

-- input parameters: hash_value of SQL to report
--                   SQL rank in category

-- called by h:\sql\u\sql_by_hour.txt

define one_hash_value = &1
clear computes breaks

set pagesize 0
select '                                                                ',
       '                                                                ',
       '================================================================',
       '                            SQL &one_hash_value                 ',
       '================================================================'
  from dual;
set pagesize 60

/*--------------------------------------------------------*/
/*     LIST THE SQL TEXT                                  */
/*--------------------------------------------------------*/
select sql_text,
       DECODE(instr(UPPER(sql_text),' FROM' ),0,
       DECODE(instr(UPPER(sql_text),' WHERE'),0,
       ' ','where'), 'from') " "
  from stats$sqltext
 where hash_value=&one_hash_value
 order by hash_value, piece;

/*--------------------------------------------------------*/
/*     FIRST LOAD TIME AND MODULE                         */
/*--------------------------------------------------------*/
set pagesize 0

select ' ' from dual;

select 'FIRST TIME = '||SUBSTR(first_load_time,1,10)||' '||
                        SUBSTR(first_load_time,12,5)
  from v$sqlarea
 where hash_value=&one_hash_value;

select 'MODULE     = '||SUBSTR(max(module),1,40)
  from temporary_sql_all
 where hash_value=&one_hash_value;


/*--------------------------------------------------------*/
/*     HOURLY DIFFERENCE DETAILS                          */
/*--------------------------------------------------------*/
set pagesize 60
clear breaks
break on report
compute sum of mins        on report
compute sum of cpu         on report
compute sum of elapsed     on report
compute sum of executions  on report
compute sum of buffer_gets on report
compute sum of disk_reads  on report
compute sum of processed   on report
col processed format 99999999

select  to_char(begin_time,'MM/DD HH24') Starting,
        (end_time-begin_time)*1440          mins,
        cpu, elapsed, executions, buffer_gets, disk_reads,
        rows_processed processed, substr(module,1,17) module
  from  temporary_sql_all
 where  hash_value=&one_hash_value
 order  by 1;


