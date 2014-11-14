SET SERVEROUTPUT ON SIZE 1000000
spool is_acct_past_due.out

DECLARE

   l_guid            char(36);
   l_past_due_flag   VARCHAR2(10);
   l_last_bill_date  DATE;
   l_last_bill_due   DATE;
   l_amount_past_due NUMBER;
   l_days_past_due   NUMBER;

BEGIN

   --l_guid := '123';
   --l_guid := '1603fd4d-f484-419c-bdc0-d02019e4f821';
   l_guid := '8ea562b5-ea16-42f8-bb24-2265dab53a2a';


   PVIEW.P_CIS_COLLECTIONS.IS_ACCOUNT_PAST_DUE (P_ID_USER_GUID => l_guid
                                               ,P_KY_ENROLL => 2265979  --1566339
                                               ,P_FL_PAST_DUE => l_past_due_flag   --out
                                               ,P_DT_LAST_BILL => l_last_bill_date --out
                                               ,P_DT_LAST_BILL_DUE => l_last_bill_due --out
                                               ,P_DAYS_PAST_DUE => l_days_past_due --out
                                               ,P_AMT_PAST_DUE => l_amount_past_due); --out
                                               
   dbms_output.put_line('<---------------------->');
   dbms_output.put_line('past due flag: '||l_past_due_flag);
   dbms_output.put_line('last bill date: '||l_last_bill_date);
   dbms_output.put_line('last bill due: '||l_last_bill_due);
   dbms_output.put_line('days past due: '||l_days_past_due);
   dbms_output.put_line('amt past due: '||l_amount_past_due);

END;
/
spool off



