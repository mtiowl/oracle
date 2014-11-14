REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
       SELECT tx_filename, 
       tx_status, 
       tx_validation_type, 
       tx_errors, 
       sqlldr_seq_id, 
       ky_mkt_attribute_hdr 
       FROM   
            (SELECT A.file_id     AS TX_FILENAME, 
               CASE 
                 --duplicate:   
                 WHEN ( A.start_time = B.start_time AND A.stop_time = B.stop_time AND A.price_value = B.price_value ) THEN 'failed' 
                 --same dates , same curvename, different price values  
                 WHEN ( A.start_time = B.start_time AND A.stop_time = B.stop_time AND A.price_value <> B.price_value )THEN 'failed' 
                 --overlap start_time  
                 WHEN ( A.start_time BETWEEN B.start_time AND B.stop_time ) THEN 'failed' 
                 --overlap stop time                  
                 WHEN ( A.stop_time BETWEEN B.start_time AND B.stop_time ) THEN 'failed' 
               ELSE 'passed   '
               END           AS TX_STATUS, 
               CASE 
                 WHEN (( A.start_time = B.start_time AND A.stop_time = B.stop_time AND A.price_value = B.price_value )
                         OR 
                        (A.start_time = B.start_time  AND A.stop_time = B.stop_time AND A.price_value <> B.price_value )
                         OR 
                       (A.start_time BETWEEN B.start_time AND B.stop_time )
                         OR 
                        (A.stop_time BETWEEN B.start_time AND B.stop_time )) 
               THEN 'curve_overlap'
                 --ELSE 'no_curve_overlap' 
               END           AS TX_VALIDATION_TYPE, 
               CASE 
                 --duplicate:   
                 WHEN ( A.start_time = B.start_time AND A.stop_time = B.stop_time AND A.price_value = B.price_value ) THEN A.curve_code  || ' is a duplicate.'||'[compared to seq:'||b.sequence_id||']' 
                 --same dates , same curvename, different price values  
                 WHEN ( A.start_time = B.start_time AND A.stop_time = B.stop_time AND A.price_value <> B.price_value )THEN A.curve_code || ' has same curve name , same dates and different price value.'||'[compared to seq:'||b.sequence_id||']' 
                 --overlap start_time  
                 WHEN ( A.start_time BETWEEN B.start_time AND B.stop_time ) THEN A.curve_code || ' has a start_time overlap.' ||'[compared to seq:'||b.sequence_id||']'
                 --overlap stop time                  
                 WHEN ( A.stop_time BETWEEN B.start_time AND B.stop_time ) THEN A.curve_code || ' has a stop_time overlap.' ||'[compared to seq:'||b.sequence_id||']'
               --ELSE 'COMPLETED'  
               END           AS TX_ERRORS, 
               A.sequence_id AS SQLLDR_SEQ_ID, 
               NULL          AS KY_MKT_ATTRIBUTE_HDR 
        FROM   CURVE_DATA_SQLLOADER A, 
               CURVE_DATA_SQLLOADER B 
        WHERE  A.curve_code = B.curve_code 
               AND A.sequence_id <> B.sequence_id 
               AND A.file_id = B.file_id 
        ORDER  BY A.sequence_id)X 
        WHERE  X.tx_errors IS NOT NULL 
/

@utlxpls.sql
