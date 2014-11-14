set serveroutput on size 1000000
DECLARE

  p_type      VARCHAR2(1000) := 'PC,BO';
  p_suppliers VARCHAR2(1000) := 'TESI,GEXA';
  p_start_date  DATE := sysdate-7;
  p_end_date   DATE := sysdate;
  p_status     VARCHAR2(5) := 'T';
  
  
  
  l_status     VARCHAR2(100);
  l_sql_stmnt  VARCHAR2(4000);
  l_status1    VARCHAR2(2) := 'P';
  l_status2    VARCHAR2(2) := 'S';
  

BEGIN

  dbms_output.put_line ('starting');
  
   --Main query for dynamic cursor
    l_sql_stmnt           := 'SELECT GW.KY_GW_AUDIT, GW.KY_GW_TRANSACTION, '||
                               ' FROM PGOODWRENCH.GW_AUDIT GW, '||
                                   '  ACCOUNT A '||
                                   ', BILL_ACCOUNT BA '||
                                ' WHERE A.KY_ENROLL = GW.KY_ENROLL '||
                                  ' AND GW.KY_ENROLL = BA.KY_ENROLL ';
    --Adds status to cursor
    IF (p_status = 'T') THEN
        l_sql_stmnt := l_sql_stmnt || ' AND GW.KY_STATUS IN(  '''||l_status1||''','
                       ||''''||l_status2||''')';
    ELSE
        l_sql_stmnt := l_sql_stmnt || ' AND GW.KY_STATUS = '''||p_status||'''';
    END IF;

    --Adds dates to cursor
    IF (p_start_date IS NOT NULL) THEN
      l_sql_stmnt := l_sql_stmnt || ' AND GW.DT_REQUEST <= '''||l_date_to||
                       ''' and GW.DT_REQUEST >= '''||l_date_from||'''';
    END IF;

    --Adds suppliers to cursor
    IF l_supplier_count > 0 THEN
        l_sql_stmnt := l_sql_stmnt || ' AND A.KY_SUPPLIER IN(';
        FOR i in 1..l_supplier_count LOOP
            IF p_supplier_value(i) IS NOT NULL THEN
                IF i < l_supplier_count THEN
                    l_sql_stmnt:= l_sql_stmnt ||''''||p_supplier_value(i)||''''||',';

                ELSE
                    l_sql_stmnt:= l_sql_stmnt ||''''||p_supplier_value(i)||''''||')';

                END IF;
            END IF;
        END LOOP;
     END IF;

    --Adds enrollment number to cursor
    IF (p_enroll IS NOT NULL) THEN
        l_sql_stmnt := l_sql_stmnt || ' AND A.KY_ENROLL = '||TO_NUMBER(p_enroll);
    END IF;

    --Adds bill accout number to cursor
    IF (p_billing_number IS NOT NULL) THEN
        l_sql_stmnt := l_sql_stmnt || ' AND BA.TX_BILLING_NUMBER = '||TO_NUMBER(p_billing_number);
    END IF;

    --Adds utility account number and utility name to cursor
    IF (p_utility_account IS NOT NULL) THEN
        l_sql_stmnt := l_sql_stmnt || ' AND A.TX_UTILITY_ACCOUNT = '''||p_utility_account||
                                      ''' AND A.KY_UTILITY_NAME = '''||p_utility_name||'''';
    END IF;

    --Adds utility name to cursor
    IF (p_utility_account IS NULL) AND (p_utility_name IS NOT NULL) THEN
        l_sql_stmnt := l_sql_stmnt || ' AND A.KY_UTILITY_NAME = '''||p_utility_name||'''';
    END IF;

    --Orders the cursor
    l_sql_stmnt := l_sql_stmnt || ' ORDER BY A.KY_ENROLL, GW.DT_REQUEST  ';



END;
/