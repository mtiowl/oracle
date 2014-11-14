set timing on

/*+ INDEX_ASC(BEH BILL_EMAIL_HISTORY_HDR_IDX1) USE_NL(BEH BH) USE_NL(BH UA) USE_NL(UA SSA) USE_NL(SSA A) */
SELECT 
            XMLELEMENT("bills", XMLATTRIBUTES(ua.tx_user_id_granted_access AS "USER"),
                XMLAGG(XMLELEMENT("bill", XMLATTRIBUTES
                    ( BEH.ky_bill,
                      BH.dt_bill,
                      BH.dt_bill_due,
                      BH.at_bill_account_balance,
                      --NVL(P_SS_ACCTINFO_WS.calc_bill_amount(BEH.ky_bill),0) AS at_bill_amt,
                      SSA.ky_ba,
                      A.TX_UTILITY_ACCOUNT AS EDC_ACCOUNT,
                      --P_SS_USERINFO_WS.get_service_address(SSA.ky_ba,'N') AS tx_service_address,
                      A.tx_customer_name
                    )
                ))
            ).getClobVal() AS "BillList"
        FROM BILL_EMAIL_HISTORY_HDR BEH,
             BILL_HDR BH,
             SS_ACCOUNT SSA,
             ACCOUNT A,
             ss_user_account_access UA
        WHERE BEH.fl_processed = 'N'
          AND BEH.ky_bill = BH.ky_bill
          AND BH.ky_enroll = UA.ky_enroll
          AND UA.ky_enroll = SSA.ky_enroll
          AND SSA.ky_enroll = A.ky_enroll
          AND BH.ky_supplier = 'TESI'
          --
          --AND beh.ky_bill = 12365538
          --and BEH.KY_BILL > 0
          --
        GROUP BY UA.tx_user_id_granted_access
/

/*+ INDEX_ASC(BEH BILL_EMAIL_HISTORY_HDR_IDX1) */ 
SELECT beh.ky_bill
        FROM BILL_EMAIL_HISTORY_HDR BEH
             ,BILL_HDR BH
             --,SS_ACCOUNT SSA
             --,ACCOUNT A
             --,ss_user_account_access UA
        WHERE BEH.fl_processed = 'N'
          AND BEH.ky_bill = BH.ky_bill
          --AND BH.ky_enroll = UA.ky_enroll
          --AND UA.ky_enroll = SSA.ky_enroll
          --AND SSA.ky_enroll = A.ky_enroll
          --AND BH.ky_supplier = 'TESI'
          --
          --AND beh.ky_bill = 12365538
          --and BEH.KY_BILL > 0
/