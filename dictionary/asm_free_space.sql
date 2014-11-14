--# Determine ASM Free space
--
select name, state, round(total_mb/1024,1) total_gb, round(free_mb/1024,1) free_gb from v$asm_diskgroup
/
