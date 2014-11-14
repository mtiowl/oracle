set serveroutput on size 1000000

DECLARE

        -- PSOLPT --->  
        p_ky_enroll                 NUMBER := 2265979;
        --p_ky_enroll                 NUMBER := 1533177;
        p_fl_past_due               VARCHAR2(10);
        p_days_past_due             NUMBER;
        p_amt_past_due              NUMBER;
        p_dt_last_bill_due          DATE;
        p_dt_last_bill              DATE;
        p_id_user_guid              CHAR(36) := '8ea562b5-ea16-42f8-bb24-2265dab53a2a';
        
        l_ky_enroll                 NUMBER := p_ky_enroll;
        l_ky_ba                     NUMBER;

        l_ky_supplier_name          VARCHAR2(20);
        l_ky_supplier_no            NUMBER;

        l_min_bus_days_overdue      NUMBER;
        l_min_amt_overdue           NUMBER;

        l_date_last_bill            DATE;
        l_date_last_bill_due        DATE;
        l_current_bill_amt          NUMBER;
        l_remaining_balance         NUMBER;

        l_date_past_due_effective   DATE;

        
        
        
        PROCEDURE get_collections_rules (
        p_supplier_no           IN      NUMBER,
        p_min_bus_days_overdue      OUT NUMBER,
        p_min_amt_overdue           OUT NUMBER)   IS
    BEGIN
        --DBMS_OUTPUT.put_line('Supplier No : '||p_supplier_no);
        SELECT
            qy_business_days_overdue,
            qy_minimum_overdue_amt
        INTO
            p_min_bus_days_overdue,
            p_min_amt_overdue
        FROM
            PPLSCIS.CIS_COLLECTIONS_CONFIG
        WHERE
            KY_SUPPLIER_NO = p_supplier_no;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20099,
                'Supplier does not have collections rules configired.');
    END get_collections_rules;
        
        /*****************************************************************/
        PROCEDURE get_latest_billing_info
        IS
        BEGIN

            BEGIN

                -- Get the latest bill on the account
                SELECT
                    SUM(AT_DB),
                    SUM(AT_REMN_DB),
                    TO_DATE(DT_BILL, 'YYYY-MM-DD')
                INTO
                    l_current_bill_amt,
                    l_remaining_balance,
                    l_date_last_bill
                FROM
                    DB_ACTIVITY@CL2X
                WHERE
                    KY_BA = l_ky_ba AND
                    DT_BILL = (
                        SELECT
                            MIN(DT_BILL)
                        FROM
                            DB_ACTIVITY@CL2X
                        WHERE
                            KY_BA = l_ky_ba)
                GROUP BY
                    TO_DATE(DT_BILL, 'YYYY-MM-DD');

            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ('when others 0001'||sqlerrm);
                    l_current_bill_amt := 0;
                    l_remaining_balance := 0;
                    l_date_last_bill := NULL;
                    /*RAISE_APPLICATION_ERROR(
                        -20098,
                        'Unable to find any bills for this account.');*/
            END;

BEGIN

                -- Get the date the bill was due
                SELECT
                    DT_BILL_DUE
                INTO
                    l_date_last_bill_due
                FROM
                    BILL_HDR
                WHERE
                    KY_ENROLL = p_ky_enroll AND
                    DT_BILL = (
                        SELECT
                            MAX(DT_BILL)
                        FROM
                            BILL_HDR
                        WHERE
                            KY_ENROLL = p_ky_enroll);
                    /*KY_ENROLL = p_ky_enroll AND
                    DT_BILL = l_date_last_bill AND
                    ROWNUM = 1;*/

            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ('when others 002');
                    l_date_last_bill_due := NULL;
/*                    RAISE_APPLICATION_ERROR(
                        -20099,
                        'Unable to join latest billing information on DB_ACTIVITY to BILL_HDR table.');*/
            END;

            dbms_output.put_line ('<---- msg 1 ---->');
            dbms_output.put_line ('l_current_bill_amt: '||l_current_bill_amt);
            dbms_output.put_line ('l_remaining_balance: '||l_remaining_balance);
            dbms_output.put_line ('l_date_last_bill: '||l_date_last_bill);

        END;

    BEGIN  -- THE ACTUAL BEGIN

        DECLARE
            tmpState           VARCHAR2(2);
            tmpService         VARCHAR2(20);
            tmpDuns            VARCHAR2(50);
            
        BEGIN

         --Get the basic account context
        
        dbms_output.put_line ('pplscis.p_cis_custinfo');
        PPLSCIS.P_CIS_CUSTINFO.get_basic_account_context (
            p_id_user_guid, l_ky_enroll, l_ky_ba, l_ky_supplier_name); 
        END; 
        dbms_output.put_line ('....l_ky_supplier_name: '||l_ky_supplier_name);
        
        -- Get supplier number for this supplier name
        dbms_output.put_line ('PPLSCIS.P_CIS.get_supplier_info');
        PPLSCIS.P_CIS.get_supplier_info (
            l_ky_supplier_name, l_ky_supplier_no);
        dbms_output.put_line ('....l_ky_supplier_no: '||l_ky_supplier_no);
        
        dbms_output.put_line ('get_collections_rules');
        -- Get collections rules for this account
        get_collections_rules (
            l_ky_supplier_no, l_min_bus_days_overdue, l_min_amt_overdue);
        dbms_output.put_line ('....l_min_bus_days_overdue: '||l_min_bus_days_overdue);
        dbms_output.put_line ('....l_min_amt_overdue: '||l_min_amt_overdue);
        
        
        -- Get the most recent billing activity for the account, including
        -- remaining balance and bill date
        dbms_output.put_line ('get_latest_billing_info');
        get_latest_billing_info;

        -- If the latest bill shows no overdue balance, return here
        IF (l_date_last_bill IS NULL) OR (l_date_last_bill_due IS NULL) THEN

            -- Bill is not past due
            p_fl_past_due := 'N';

            RETURN;

        END IF;

        DBMS_OUTPUT.put_line('Printing values - l_current_bill_amt = ' ||  l_current_bill_amt || ' / l_remaining_balance = ' || l_remaining_balance || ' / l_date_last_bill = ' || l_date_last_bill || ' / l_date_last_bill_due = ' || l_date_last_bill_due );

        -- Using the supplier's allowable days overdue, retrieve the date 'N'
        -- business days in the future from the date the bill is due to
        -- determine when the bill is past due
        
        --    TROUBLE CALL!!!!!!
        dbms_output.put_line ('PPLSCIS.P_CIS.get_n_business_days_ahead');
        dbms_output.put_line (' param in - l_date_last_bill_due: '||to_char(l_date_last_bill_due, 'DD-MON-YYYY'));
        dbms_output.put_line (' param in - l_min_bus_days_overdue: '||l_min_bus_days_overdue);
        
        
        l_date_past_due_effective := PPLSCIS.P_CIS.get_n_business_days_ahead (    --sysdate, 1);
            l_date_last_bill_due, l_min_bus_days_overdue);
            
        dbms_output.put_line('l_date_past_due_effective: '||l_date_past_due_effective);

        -- If today is greater than the allowed grace date, the bill is past
        -- due
        DBMS_OUTPUT.put_line('outside if statement');
        
        DBMS_OUTPUT.put_line(l_date_last_bill_due || ' - ' || l_min_amt_overdue || ' - ' || l_date_past_due_effective);
        
        IF TRUNC(SYSDATE) >= l_date_past_due_effective THEN
        DBMS_OUTPUT.put_line('Inside if statement');
            
            -- Check to see if bill is over the allowed amount
            IF l_remaining_balance >= l_min_amt_overdue THEN

                -- Bill is past due
                p_fl_past_due := 'Y';
                p_days_past_due := (TRUNC(SYSDATE) - l_date_past_due_effective);
                p_amt_past_due := l_remaining_balance;
                p_dt_last_bill_due := l_date_last_bill_due;
                p_dt_last_bill := l_date_last_bill;
                RETURN;

            END IF;

        END IF;

        -- Bill is not past due
        p_fl_past_due := 'N';

 END;
