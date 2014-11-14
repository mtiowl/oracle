-- Need to have the db link pointing to the instance you want to work with
-- DB Link Name:  dblink


CREATE OR REPLACE PACKAGE utl_db_health IS

   debug_flag           BOOLEAN := FALSE;
   bad_db_version       EXCEPTION;  -- The database instance's version is not supported


   PROCEDURE report (p_start_date  DATE
                    ,p_end_date    DATE);

END utl_db_health;
/
show error





CREATE OR REPLACE PACKAGE BODY utl_db_health IS

   -- *************************************************************************
   --  DEBUG_MSG
   --
   --  If the m_debugging flag is TRUE, this proceudre will call dbms_output
   --
   --  OVERLOADED
   --
   --  Version #1 - Handles VARCHAR2 strings
   --  Version #2 - Handles CLOBs
   -- *************************************************************************
   PROCEDURE debug_msg (p_message VARCHAR2) IS

    l_start_pos  NUMBER;
    
   BEGIN

      IF debug_flag THEN
         IF length(p_message) > 255 THEN
            l_start_pos := 1;
            WHILE length(p_message)-l_start_pos > 255 LOOP
               dbms_output.put_line (substr(p_message, l_start_pos, 255) );
               l_start_pos := l_start_pos + LEAST (255, length(p_message)-l_start_pos);
            END LOOP;
            dbms_output.put_line (substr(p_message, l_start_pos, 255) );
         ELSE
             dbms_output.put_line(p_message);
         END IF;

      END IF;
   END debug_msg;


   PROCEDURE debug_msg (p_message CLOB) IS
        
     -- used when p_debugging is set to "Y"
     l_ep VARCHAR2(4000);
     l_clob CLOB;
       
     l_offset     NUMBER;
     l_clobsize   NUMBER;
   
   BEGIN

      IF debug_flag THEN

         IF dbms_lob.getlength(p_message) > 255 THEN
           l_offset := 1;
           l_clobsize := dbms_lob.getlength(p_message);
           WHILE (l_offset < l_clobsize) loop
               dbms_output.put_line(dbms_lob.substr(p_message,255, l_offset));
               l_offset := l_offset + least(255, (l_clobsize-l_offset));
           end loop;
           dbms_output.put_line(dbms_lob.substr(p_message,255, l_offset));

         ELSE
           dbms_output.put_line(p_message);
         END IF;

      END IF;
   END debug_msg;


   -- *************************************************************************
   --      Fetch the version of the DB Instance
   --
   --   Hidden Method
   -- *************************************************************************
   FUNCTION get_version RETURN NUMBER IS
   
      l_version NUMBER;
   
   BEGIN
     SELECT TO_NUMBER(SUBSTR(version, 0, INSTR(version, '.')-1)) version
       INTO l_version
       FROM v$instance@dblink;
   
     RETURN l_version;
     
   END get_version;
   
   
   -- *************************************************************************
   --      Fetch all the snapshot range for each day
   --   Only works for version 9i
   --   Hidden Method
   -- *************************************************************************
   PROCEDURE fetch_snaps_v9 (p_start_date    DATE
                            ,p_end_date      DATE
                            ,p_snapshots OUT db_health_snapshots) IS
   
   
   BEGIN
   
     SELECT trunc(snap_time) snap_date, count(*) snaps
            ,min(snap_id) MIN_ID, max(snap_id) max_id
            ,'   '||to_char(min(snap_time),'HH24:MI') min_time
            ,to_char(max(snap_time),'HH24:MI')||'   ' max_time
       BULK COLLECT INTO p_snapshots
       FROM stats$snapshot@dblink
       GROUP BY trunc(snap_time)
       ORDER BY 1;

   
   END fetch_snaps_v9;


   -- *************************************************************************
   --      Fetch all the snapshot range for each day
   --   Only works for version 10g and 11g
   --   Hidden Method
   -- *************************************************************************
   PROCEDURE fetch_snaps_v10 (p_start_date    DATE
                             ,p_end_date      DATE
                             ,p_snapshots OUT db_health_snapshots) IS
   
   BEGIN
       
       SELECT trunc(end_interval_time) snap_date
             ,count(*) snaps
             ,min(snap_id) MIN_ID
             ,max(snap_id) max_id
             ,'   '||to_char(min(end_interval_time),'HH24:MI') min_time
             ,to_char(max(end_interval_time),'HH24:MI')||'   ' max_time
             --,trunc(sysdate)-trunc(end_interval_time) age_days
         BULK COLLECT INTO p_snapshots
         FROM dba_hist_snapshot@dblink
         GROUP BY trunc(end_interval_time)
         ORDER BY 1;
   
   END fetch_snaps_v10;
   
   
   -- *************************************************************************
   -- *************************************************************************
   --                  PUBLIC  METHODS
   -- *************************************************************************
   -- *************************************************************************
      
   PROCEDURE report (p_start_date  DATE
                    ,p_end_date    DATE)  IS
                    
      l_version NUMBER;
      l_snaps   db_health_snapshots;
      
   BEGIN
   
     l_version := get_version;
     
     IF l_version = 9 THEN
     
        fetch_snaps_v9 (p_start_date => p_start_date
                       ,p_end_date   => p_end_date
                       ,p_snapshots  => l_snaps);
     
     ELSIF l_version = 10 THEN
     
        fetch_snaps_v10 (p_start_date => p_start_date
                        ,p_end_date   => p_end_date
                        ,p_snapshots  => l_snaps);

     
     ELSE
         raise bad_db_version;
     END IF;
   
   
   EXCEPTION
     WHEN bad_db_version THEN
       debug_msg('Database instance''s version '||l_version||' is not supported');
       
     WHEN others THEN
       debug_msg(DBMS_UTILITY.format_error_backtrace);

   END report;



END utl_db_health;
/
show error