set serveroutput on size 1000000
set linesize 300

REM  ky_enrolls
REM
REM    PSOLD        PSOLPT
REM  ---------    --------
REM    1000147     1566339
REM    1061769
REM    1077414
REM    1077511
REM    1077521
REM    1078973
REM    1080168
REM    1086711
REM    1119311
REM    1126688
REM    1139549
REM    1476673
REM    1486850
REM    1576958
REM    2166571
REM   12312333
REM  901117901



DECLARE
  l_comments  sys_refcursor;
  l_error     NUMBER;
  l_error_msg VARCHAR2(500);

  TYPE l_rec_type IS RECORD (ID                   NUMBER
                            ,source               VARCHAR2(100)
                            ,TS_ADDED             DATE
                            ,FL_CRITICAL_COMMENT  VARCHAR2(100)
                            ,CD_FOLLOW_UP_STATUS  VARCHAR2(100)
                            ,TX_CALL_TYPE         VARCHAR2(100)
                            ,NOTATED_BY           VARCHAR2(100)
                            ,KY_NOTATE_TYPE       VARCHAR2(100)
                            ,call_log_msg         VARCHAR2(200));

  l_msg    l_rec_type;


BEGIN

  p_cis_call_log.get_headers(1000147,l_comments, l_error, l_error_msg);

  IF l_error = 0 THEN

     FETCH l_comments INTO l_msg;

     WHILE l_comments%FOUND LOOP 
         DBMS_OUTPUT.PUT_LINE('('||l_comments%rowcount||')   '||l_msg.id||' '||l_msg.source||' '||l_msg.call_log_msg);
         FETCH l_comments INTO l_msg;
     END LOOP;

     dbms_output.put_line ('Found '||l_comments%rowcount||' records');

  ELSE
     dbms_output.put_line ('Error: '||l_error);

  END IF;

END;
/
set linesize 100