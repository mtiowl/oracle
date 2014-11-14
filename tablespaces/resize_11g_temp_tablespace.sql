

SELECT tablespace_name, file_name, bytes/1000000 meg_bytes
  FROM dba_temp_files WHERE tablespace_name like 'TEMP%';


ALTER DATABASE TEMPFILE '<name of file with full path>' DROP INCLUDING DATAFILES;


ALTER TABLESPACE temp ADD TEMPFILE '<name of file with full path>' SIZE 512m
  AUTOEXTEND ON NEXT 250m MAXSIZE UNLIMITED;