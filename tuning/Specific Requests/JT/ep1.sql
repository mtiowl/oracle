REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

--EXPLAIN PLAN
--  SET STATEMENT_ID = 'MTI'
--  INTO plan_table
--  FOR
--SELECT pv.ky_enroll
--  from pview.account     pv
--      ,cpm_agg_member    am
--      ,cpm_agg_header    ah
--      ,cpm_cd_agg_type   at
--      ,cpm_cd_member_type mt
--  where pv.ky_enroll = am.ky_enroll
--    and am.ky_cpm_agg_header = ah.ky_cpm_agg_header
--    and at.cd_agg_type = ah.cd_agg_type
--    and at.ky_supplier = ah.ky_supplier
--    and mt.cd_member_type(+) = am.cd_member_type 
--    and mt.ky_supplier(+) = ah.ky_supplier
--    and ah.ky_supplier = 'TESI'
--    AND at.fl_active != 'N'

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR SELECT e.ky_event,
             e.id_event_seq,
             e.cd_publisher,
             e.cd_event,
             e.tx_event_data
        FROM events               e,
             event_notifications  en
       WHERE e.ky_event = en.ky_event
         AND UPPER(en.cd_subscriber) = 'ACCUBYL'
         AND cd_event in ('IB814A', 'IBECR')
         AND NVL(e.FL_PASS_PREPROCESSING, 'Y') = 'Y'
         AND dt_retrieved is null
         -- T33026 Begin
         AND (
              NOT EXISTS ( -- No matching ER event
                          SELECT 1
                            FROM event_notifications  n
                           WHERE n.ky_event             = e.ky_event
                             AND UPPER(n.cd_subscriber) = 'ER'
                         )
              OR EXISTS ( -- A matching ER event that was successfully processed
                         SELECT 1
                           FROM event_notifications  n
                               ,events  e2
                               ,bt_common_header  h
                               ,cc_transaction_checkpoints  c
                          WHERE e2.ky_event                 = e.ky_event
                            AND e2.ky_event                 = n.ky_event
                            AND UPPER(n.cd_subscriber)      = 'ER'
                            AND to_number(e2.tx_event_data) = h.ky_row_seq_trans
                            AND h.ky_row_seq_trans          = c.ky_row_seq_trans
                            AND c.cd_control                = 'ERIB814'
                            AND c.cd_trans_status           = '0400'
                            AND NOT EXISTS ( -- look for failed or unprocessed customer_import records
                                            SELECT 1
                                            FROM customer_import@ersp
                                            WHERE ky_row_seq_trans = h.ky_row_seq_trans
                                              AND nvl(fl_process, 'X') <> 'Y'
                                           )
                        )
             )
         -- T33026 End
       ORDER BY e.ky_event
/

@utlxpls.sql