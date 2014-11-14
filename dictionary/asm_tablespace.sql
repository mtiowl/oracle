REM**********************************************************************
REM    Displays the amout of free space for a disk group and all of
REM    the tablespaces within that disk group
REM
REM   Helpful to detemine if the ASM Disk Group needs to have more
REM   space allocated.
REM
REM   Example:  If you are about to do a data load, you can make sure
REM             the ASM Disk Group can handle it.
REM**********************************************************************

clear breaks
clear compute
break on asm_disk_group on disk_group_total_gb on disk_group_free_gb
compute sum of tablespace_total_gb on asm_disk_group

set linesize 300
col asm_disk_group format a20
col tablespace_name format a40

select substr(file_name, 2,instr(file_name, '/')-2) asm_disk_group, round(total_mb/1024,1) disk_group_total_gb, round(free_mb/1024,1) disk_group_free_gb
      ,tablespace_name , round(sum(bytes)/1024/1024/1024,2) tablespace_total_gb
from dba_data_files
    ,v$asm_diskgroup_stat
where substr(file_name, 2,instr(file_name, '/')-2) = name
group by tablespace_name , substr(file_name, 2,instr(file_name, '/')-2)
        ,round(total_mb/1024,1), round(free_mb/1024,1)
order by tablespace_name
/
