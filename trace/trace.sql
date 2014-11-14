show parameter dump

alter session set tracefile_identifier="MTI3";

alter session set events '10046 trace name context forever, level 8';

exec trace_test.run

alter session set events '10046 trace name context off';


Using the trace file
===============================================
1. telnet to the db server
2. locate your file within the user_dump_dest
    2.1.  Example:  ls -alt /e00/oracle/diag/rdbms/psold/PSOLD/trace/*MTI*.trc
3. use tkprof to make the trace readable
   3.1. To see the list of parameters just type tkprof at command line


When reviewing the tkprof output, you may find a SQL that you want to figure out where it came from. 

Example:

SQL ID: a0f4nn77bryt7 Plan Hash: 3496153345

SELECT VIEW_NAME, TEXT_LENGTH, OWNER
FROM
 MTI_VIEWS


call     count       cpu    elapsed       disk      query    current        rows
------- ------  -------- ---------- ---------- ---------- ----------  ----------
Parse        1      0.00       0.00          0          1          0           0
Execute      1      0.00       0.00          0          0          0           0
Fetch       39      0.00       0.00          0         57          0        3817
------- ------  -------- ---------- ---------- ---------- ----------  ----------
total       41      0.00       0.00          0         58          0        3817

Misses in library cache during parse: 1
Optimizer mode: ALL_ROWS
Parsing user id: 73  (CUSTPRO)   (recursive depth: 1)
Number of plan statistics captured: 1

Rows (1st) Rows (avg) Rows (max)  Row Source Operation
---------- ---------- ----------  ---------------------------------------------------
      3817       3817       3817  TABLE ACCESS FULL MTI_VIEWS (cr=57 pr=0 pw=0 time=773 us cost=7 size=179399 card=3817)


Rows     Execution Plan
-------  ---------------------------------------------------
      0  SELECT STATEMENT   MODE: ALL_ROWS
   3817   TABLE ACCESS (FULL) OF 'MTI_VIEWS' (TABLE)


Next, use the SQL ID in the following query:

SELECT object_name, program_line#
  FROM v$sql
      ,dba_objects
  WHERE object_id = program_id
    AND SQL_ID = 'a0f4nn77bryt7';