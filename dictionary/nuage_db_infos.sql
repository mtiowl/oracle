/*
     /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /// 
	 /// 1) This script SHOULD be executed using SQL/Plus. See command line syntax below. 
	 /// 2) To pull all information you SHOULD use a DBA account.
	 ///
	 /// SQL/Plus command line syntax:
	 \\\ C:\ORACLE_DIR\bin\sqlplusw.exe <user>/<password>@<TNS_NAME> @db_infos.sql
	 \\\ 
	 \\\ ORACLE_DIR: Your Oracle client install folder. Usually looks like: C:\oracle\10.2.0\client_1\
	 \\\ 
	 \\\ Updates Log:
	 \\\ -----------
     \\\ 03/06/2013 System Grants and User Objects Grants querys were updated to handle directories. - Romulo
	 \\\ 03/14/2013 Duplicate the SQL for Database Config for version 9.2, just removing FLASHBACK_ON column. - Romulo 
	 \\\ 
	 \\\ 
	 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*/
clear breaks
clear columns
set echo off
set serverout on size 1000000
set maxdata 60000
set arraysize 10
set scan on
set linesize 800
set pagesize 3000
set verify off
set heading on
set feedback on
set feedback 5
set trimspool off
set termout off
set pause off

column product format a50
column version format a15
column status format a15
column value format a200
column file_name format a80
column object_name format a100
column date_column new_value today_var
SELECT 'db_info_' || name || '_' || to_char(sysdate, 'yyyymmdd_hhMISS') || '.txt' date_column
  FROM v$database;

spool c:\temp\&today_var

prompt
prompt #######################################################################
prompt ##
prompt ## Database file config info: &today_var
prompt ##
prompt #######################################################################
prompt

prompt #######################################################################
prompt ## Start Database Info Summary
prompt #######################################################################
SELECT * FROM (
SELECT 'NLS Database Params' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM NLS_DATABASE_PARAMETERS
 UNION ALL
 SELECT 'NLS Session Params' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM NLS_SESSION_PARAMETERS
UNION ALL
SELECT 'NLS Instance Params' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM NLS_INSTANCE_PARAMETERS
UNION ALL
SELECT 'Control Files' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM v$controlfile
UNION ALL
SELECT 'Log Files' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM v$logfile
UNION ALL
SELECT 'Links' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_db_links
UNION ALL  
SELECT 'Tablespaces' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM user_tablespaces
UNION ALL
SELECT 'Tables' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_all_tables
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL
SELECT 'Views' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_views
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 UNION ALL
SELECT 'Sequences' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_sequences
 WHERE sequence_owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL 
SELECT 'Constraints' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_constraints
 WHERE owner  NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL 
SELECT 'Users' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_users
UNION ALL
SELECT 'Roles' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_roles
UNION ALL
SELECT 'Objects privileges' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_tab_privs 
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL 
SELECT 'Types' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_types
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL 
SELECT 'Triggers' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'TRIGGER'
UNION ALL 
SELECT 'Packages' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'PACKAGE'
UNION ALL
SELECT 'Functions' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'FUNCTION'
UNION ALL 
SELECT 'Procedures' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'PROCEDURE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL    
SELECT 'Directories' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects 
 WHERE object_type ='DIRECTORY'
UNION ALL	
SELECT 'Job Classes' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'JOB CLASS'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL   
SELECT 'Indexes' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_indexes
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL   
SELECT 'Rules' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'RULE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL
SELECT 'Schedules' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'SCHEDULE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')    
UNION ALL
SELECT 'Libraries' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'LIBRARY'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL
SELECT 'Synonyms' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'SYNONYM'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS', 'PUBLIC')
UNION ALL   
SELECT 'Jobs' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'JOB'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL
SELECT 'Lobs' DB_OBJECT, COUNT(*) TOTAL_ROWS
  FROM dba_objects
 WHERE object_type = 'LOB'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
UNION ALL
SELECT 'Grants' DB_OBJECT, COUNT(*) TOTAL_ROWS
 FROM dba_tab_privs
WHERE  owner in ('SYS','SYSTEM')) MYTAB
ORDER BY DB_OBJECT;  
prompt
prompt #######################################################################
prompt ## End Database Info Summary
prompt #######################################################################
prompt
prompt ##*#################################################################### 
prompt ## Version / Component Products Infos 
prompt ##*#################################################################### 
prompt
prompt ## Installed Products and Versions
prompt ## ===============================
SELECT product, version, status 
  FROM PRODUCT_COMPONENT_VERSION
 ORDER BY 1,2,3;
  
prompt ##*#################################################################### 
prompt ## DB Engine 10/11g: DataFiles, Configuration and Instance Info 
prompt ##*#################################################################### 
prompt
prompt ## Instance Data Files
prompt ## ===================
SELECT file_name, AUTOEXTENSIBLE, online_status, status, tablespace_name
  FROM dba_data_files
 ORDER BY 1,2,3,4,5;

prompt ##*#################################################################### 
prompt ## DB Engine 8/9: DataFiles, Configuration and Instance Info 
prompt ##*#################################################################### 
prompt
prompt ## Instance Data Files
prompt ## ===================
SELECT file_name, AUTOEXTENSIBLE, status, tablespace_name
  FROM dba_data_files
 ORDER BY 1,2,3,4;
 
prompt ## Database Config
prompt ## =============== 
SELECT NAME, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, DATABASE_ROLE, ARCHIVELOG_COMPRESSION, DATAGUARD_BROKER, FLASHBACK_ON
  FROM v$database
 ORDER BY 1,2,3,4,5,6,7,8;  

prompt ## Database Config v9.2
prompt ## ==================== 
SELECT NAME, OPEN_MODE, PROTECTION_MODE, PROTECTION_LEVEL, DATABASE_ROLE, ARCHIVELOG_COMPRESSION, DATAGUARD_BROKER
  FROM v$database
 ORDER BY 1,2,3,4,5,6,7;  

prompt ## DB Parameters 
prompt ## ============= 
SELECT name, value
  FROM v$parameter
 ORDER BY 1,2;

prompt ## SGA Infos
prompt ## ========= 
SELECT * FROM v$sgainfo
 ORDER BY 1,2,3;

prompt ## DB Instance Infos
prompt ## =================
SELECT INSTANCE_NAME, VERSION, HOST_NAME, STATUS, DATABASE_STATUS, INSTANCE_ROLE, ACTIVE_STATE 
  FROM v$instance
 ORDER BY 1,2,3,4,5,6,7;  

prompt
prompt ##*#################################################################### 
prompt ## DB Engine Collation Parameters 
prompt ##*#################################################################### 
prompt   
prompt ## NLS Database Parameters
prompt ## =======================
SELECT * 
  FROM NLS_DATABASE_PARAMETERS
 ORDER BY 1,2;

prompt ## NLS Session Parameters
prompt ## ======================
 SELECT * 
  FROM NLS_SESSION_PARAMETERS
 ORDER BY 1,2;

prompt ## NLS Instance Parameters
prompt ## =======================
 SELECT * 
  FROM NLS_INSTANCE_PARAMETERS
 ORDER BY 1,2;

prompt ##*#################################################################### 
prompt ## DB Engine Log Infos 
prompt ##*#################################################################### 
prompt
prompt ## DB Control Files
prompt ## ================
SELECT name, status
  FROM v$controlfile
 ORDER BY 1,2;
  
prompt ## DB Log Files
prompt ## ============  
SELECT member, status
  FROM v$logfile
 ORDER BY 1,2;
  
prompt ##*#################################################################### 
prompt ## DB Links 
prompt ##*#################################################################### 
SELECT owner, db_link
  FROM dba_db_links
 ORDER BY 1,2;

prompt ##*#################################################################### 
prompt ## Table Space Infos 
prompt ##*#################################################################### 
prompt
prompt ## Table Spaces
prompt ## ============  
SELECT TABLESPACE_NAME, STATUS
  FROM user_tablespaces
 ORDER BY 1,2;

prompt ## Tablespaces Sizes
prompt ## =================
SELECT Total.name "Tablespace Name",
        Free_space, (total_space-Free_space) Used_space, total_space
  FROM (SELECT tablespace_name, sum(bytes/1024/1024) Free_Space
          FROM sys.dba_free_space
         GROUP BY tablespace_name
        ) Free,
       (SELECT b.name, sum(bytes/1024/1024) TOTAL_SPACE
          FROM sys.v_$datafile a, sys.v_$tablespace B
         WHERE a.ts# = b.ts#
         GROUP BY b.name
        ) Total
 WHERE Free.Tablespace_name = Total.name
 ORDER BY 1;

prompt ##*#################################################################### 
prompt ## All Tables, Views, Indexes, Sequences and Constraints
prompt ##*#################################################################### 
prompt
prompt ## DB Tables - Oracle 8/9 versions
prompt ## ===============================  
SELECT owner, table_name, tablespace_name
  FROM dba_all_tables
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3;

prompt ## DB Tables - Oracle 10/11g versions 
prompt ## ==================================  
SELECT owner, table_name, tablespace_name, status
  FROM dba_all_tables
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;
 
prompt ## DB Indexes
prompt ## ==========  
SELECT owner, index_name, table_name, index_type, table_type, status 
  FROM dba_indexes
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4,5,6;
 
prompt ## DB Views
prompt ## ========  
SELECT owner, view_name
  FROM dba_views
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2;

prompt ## DB Sequences
prompt ## ============  
SELECT sequence_owner, sequence_name, last_number
  FROM dba_sequences
 WHERE sequence_owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3;  
 
prompt ## DB Constraints
prompt ## ==============   
SELECT owner, constraint_name, constraint_type, table_name, index_name, status
  FROM dba_constraints
 WHERE owner  NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4,5,6;  
  
prompt ##*#################################################################### 
prompt ## Users / Roles and Privileges Infos 
prompt ##*#################################################################### 
prompt
prompt ## DB Users
prompt ## ========  
SELECT USERNAME, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE, DEFAULT_TABLESPACE, PROFILE
  FROM dba_users
 ORDER BY 1,2,3,4,5,6;  

prompt ## DB Roles
prompt ## ========  
SELECT * 
  FROM dba_roles
 ORDER BY 1,2;

SELECT grantee, privilege, admin_option "Admin"
  FROM  sys.dba_sys_privs
 WHERE  grantee NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS','DBA')
 ORDER BY 1,2,3;

prompt ## System Grants
prompt ## =============
SELECT grantee
       ,owner||'.'||table_name user_table_name
       ,decode(sum(decode(privilege, 'SELECT', 1, 0)),1,'S',NULL) "S"
       ,decode(sum(decode(privilege, 'INSERT', 1, 0)),1,'I',NULL) "I"
       ,decode(sum(decode(privilege, 'UPDATE', 1, 0)),1,'U',NULL) "U"
       ,decode(sum(decode(privilege, 'DELETE', 1, 0)),1,'D',NULL) "D"
       ,decode(sum(decode(privilege, 'READ', 1, 0)),1,'R',NULL) "R"
       ,decode(sum(decode(privilege, 'WRITE', 1, 0)),1,'W',NULL) "W"   
       ,decode(sign(sum(decode(privilege, 'EXECUTE', 1, 0))),1,'X',NULL) "EXE"
       ,grantable "Adm"
  FROM dba_tab_privs
 WHERE owner in ('SYS','SYSTEM')
 GROUP BY grantee, owner||'.'||table_name ,grantable 
  ORDER BY 1;
	  
prompt ## User Objects Grants
prompt ## ===================   
SELECT owner, table_name, grantee, privilege, grantor
  FROM dba_tab_privs 
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 UNION ALL
SELECT owner, table_name, grantee, privilege, grantor
  FROM dba_tab_privs 
 WHERE table_name IN (SELECT directory_name  FROM dba_directories) 
 ORDER BY 1,2,3,4;  
 
prompt ## Types
prompt ## =====  
SELECT owner, type_name
  FROM dba_types
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY owner, type_name;
 
prompt ##*#################################################################### 
prompt ## Triggers, Packages, Functions, Procedures, Directories, Jobs,   
prompt ##*#################################################################### 
prompt
prompt ## DB Triggers
prompt ## ===========  
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'TRIGGER'
 ORDER BY 1,2,3,4;  

prompt ## DB Packages
prompt ## ===========  
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'PACKAGE'
 ORDER BY 1,2,3,4;  

prompt ## DB Functions
prompt ## ============   
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
   AND object_type = 'FUNCTION'
 ORDER BY 1,2,3,4; 

prompt ## DB Procedures
prompt ## =============   
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'PROCEDURE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
   
prompt ## DB Directory
prompt ## ============     
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects 
 WHERE object_type ='DIRECTORY'
 ORDER BY 1,2,3,4;  
 
col directory_path format a50
SELECT * 
  FROM dba_directories;

col value_col_plus_show_param format a40
col NAME_COL_PLUS_SHOW_PARAM format a15
show parameter utl_file_dir



prompt ## DB Job Class
prompt ## ============  	
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'JOB CLASS'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  

prompt ## DB Rule
prompt ## =======     
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'RULE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
 
prompt ## DB Schedule
prompt ## ===========     
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'SCHEDULE'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
 
prompt ## DB Library
prompt ## ==========        
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'LIBRARY'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
 
prompt ## DB Synonym
prompt ## ==========        
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'SYNONYM'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS', 'PUBLIC')
 ORDER BY 1,2,3,4;  
    
prompt ## DB Job
prompt ## ======         
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'JOB'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
   
prompt ## DB Lob
prompt ## ======           
SELECT owner, object_name, subobject_name, status 
  FROM dba_objects
 WHERE object_type = 'LOB'
   AND owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'XDB', 'SYSMAN', 'TSMSYS', 'WMSYS')
 ORDER BY 1,2,3,4;  
 
prompt ## Invalids
prompt ## ========           
SELECT owner, object_type, object_name, subobject_name
  FROM dba_objects
 WHERE status='INVALID'
 ORDER BY 1,2,3,4;  
 
prompt #######################################################################
prompt ##
prompt ## End of Database file config info: &today_var
prompt ##
prompt #######################################################################
spool off