accept db PROMPT 'Enter instance name: '
accept username PROMPT 'Enter username: '
accept pwd PROMPT 'Ener password: ' HIDE

set linesize 300
column tablespace format a20
column data_file format a50
column mount_point format a5
column filesystem format a25

CREATE DATABASE LINK monitor CONNECT TO &username IDENTIFIED BY &pwd USING '&db';

SPOOL  dbfiles.out

SELECT ts.name tablespace, df.name data_file, u.filesystem
      ,round(df.bytes/1000000,2) size_mb
  FROM v$tablespace@monitor ts
      ,v$datafile@monitor df
      ,unix_file_system u
  WHERE ts.ts# = df.ts#
    AND substr(df.name, 1, INSTR(df.name, '/', 2)-1) = u.mount_point
UNION
SELECT '** Script Output **', '/swp/c1/prod/files/areafcp', u2.filesystem
      ,kilobytes
  FROM unix_file_system u2
  WHERE u2.mount_point = '/swp/c1/prod/files'
ORDER BY tablespace, data_file;

spool off

DROP DATABASE LINK monitor;
set linesize 100