SET SERVEROUTPUT ON SIZE 1000000


create or replace type myTableType as table of varchar2 (255)
/

create or replace function in_list( p_string in varchar2 ) return myTableType  as
    l_string        long default p_string || ',';
    l_data          myTableType := myTableType();
    n               number;
   begin
     loop
         exit when l_string is null;
         n := instr( l_string, ',' );
         l_data.extend;
         l_data(l_data.count) := ltrim( rtrim( substr( l_string, 1, n-1 ) ) );
         l_string := substr( l_string, n+1 );
    end loop;
--    dbms_output.put_line ('in_list ='||l_data);
    return l_data;
end;
/



set serveroutput on size 1000000
DECLARE

   CURSOR get_transactions (p_type      VARCHAR2 
                           ,p_suppliers VARCHAR2
                           ,p_status    VARCHAR2
                           ,p_start     DATE
                           ,p_end       DATE) IS
       SELECT gw.KY_GW_TRANSACTION_TYPE, GW.KY_GW_TRANSACTION,gw.ky_status, a.ky_supplier
         FROM PGOODWRENCH.GW_AUDIT GW
             ,ACCOUNT A
             ,BILL_ACCOUNT BA
          WHERE A.KY_ENROLL = GW.KY_ENROLL
            AND GW.KY_ENROLL = BA.KY_ENROLL
            and rownum < 101
            --
            AND KY_GW_TRANSACTION_TYPE IN (select * from the (select cast( in_list(p_type) as mytableType) FROM dual))
            AND A.KY_SUPPLIER IN (select * from the (select cast( in_list(p_suppliers) as mytableType) FROM dual))
            AND gw.KY_STATUS IN (select * from the (select cast( in_list(p_status) as mytableType) FROM dual))
            AND GW.DT_REQUEST BETWEEN p_start and p_end;

  p_type      VARCHAR2(1000) := 'PC,BO';
  p_suppliers VARCHAR2(1000) := 'TESI,GEXA';
  p_start_date DATE := sysdate-7;
  p_end_date   DATE := sysdate;
  p_status     VARCHAR2(5) := 'T';
  
  
  
  l_status     VARCHAR2(100);
  

BEGIN

  dbms_output.put_line ('starting');
  
  IF (p_status = 'T') THEN
        l_status := 'P,S';
  ELSE
        l_status := p_status;
  END IF;
  
  FOR trec IN get_transactions (p_type, p_suppliers, l_status, p_start_date, p_end_date) LOOP
  
    dbms_output.put_line (trec.ky_gw_transaction||' - '||trec.ky_status);
  
  END LOOP;


END;
/