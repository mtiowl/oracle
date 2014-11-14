set linesize 300

/*
******  SELECT STATEMENT to DETERMINE LOGFILE SWITCHES ******
*/
select to_char(first_time,'YYYY-MM-DD') day,
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),'999') "00",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),'999') "01",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),'999') "02",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),'999') "03",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),'999') "04",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),'999') "05",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),'999') "06",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),'999') "07",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),'999') "08",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),'999') "09",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),'999') "10",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),'999') "11",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),'999') "12",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),'999') "13",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),'999') "14",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),'999') "15",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),'999') "16",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),'999') "17",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),'999') "18",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),'999') "19",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),'999') "20",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),'999') "21",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),'999') "22",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),'999') "23"
from v$log_history
where first_time >= (sysdate - 60) 
group by to_char(first_time,'YYYY-MM-DD')
order by 1 desc;


Prompt Archived Logs
select trunc(COMPLETION_TIME,'DD') Day, thread#, round(sum(BLOCKS*BLOCK_SIZE)/1048576) MB,count(*) Archives_Generated, status
      ,round(round(sum(BLOCKS*BLOCK_SIZE)/1048576)/count(*), 2) MB_PER
  from v$archived_log
  group by trunc(COMPLETION_TIME,'DD'),thread#, status
  order by 1
/

prompt Archived Logs to be deleted
select name,status, completion_time, round(blocks*block_size/1024/1024,2) file_size_mb
from v$archived_log
where completion_time < sysdate-4/24
and name not like '%rp3440-y.papl.com%'
and name is not null
and status <> 'D'
order by 1
/
