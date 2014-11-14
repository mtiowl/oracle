SELECT  hdr.KY_CALL_LOG_ID ID
       ,'CIS_CL_HEADER' source
       ,hdr.TS_ADDED
       ,hdr.FL_CRITICAL_COMMENT
       ,hdr.CD_FOLLOW_UP_STATUS
       ,ct.TX_CALL_TYPE
       ,P_CIS_CALL_LOG.get_call_rep_name(hdr.ID_USER_GUID) AS NOTATED_BY
       ,hdr.KY_NOTATE_TYPE
       ,(CASE
          WHEN dbms_lob.getlength(msg.TX_CALL_LOG_MSG) > 100 THEN
                 dbms_lob.substr(msg.TX_CALL_LOG_MSG,100,1)||'...'
          ELSE
                 dbms_lob.substr(msg.TX_CALL_LOG_MSG,100,1)
         END) cal_log_msg
    FROM CIS_CL_HEADER  hdr
        ,CIS_CL_MESSAGES msg
        ,CIS_CL_CALL_TYPES ct
    WHERE msg.KY_CALL_LOG_ID = hdr.KY_CALL_LOG_ID
      AND ct.KY_CALL_LOG_ID = hdr.KY_CALL_LOG_ID
      AND (hdr.CD_STATUS IS NULL OR hdr.CD_STATUS <> 'D')
      AND hdr.KY_ENROLL = 1566339
UNION
SELECT  ky_customer_contact id
       ,'CUSTOMER_CONTACT' source
       ,A.DT_CONTACT
       , A.FL_CRITICAL_CONTACT
       ,null cd_follow_up_status
       ,(SELECT C.TX_DECODE
           FROM CODE C
           WHERE C.KY_TABLE LIKE 'CONTACT%'
             AND C.KY_CODE = A.KY_CONTACT_TYPE) AS KY_CONTACT_TYPE
       ,(SELECT C.TX_DECODE
           FROM CODE C
           WHERE C.KY_TABLE LIKE 'CALL_REP'
             AND C.KY_CODE = A.KY_CALL_REP) AS KY_CALL_REP
       ,null ky_notate_type
       ,(CASE
          WHEN length(a.tx_remarks) > 100 THEN
               substr(a.tx_remarks,1,100)||'...'
          ELSE
                a.tx_remarks
         END) cal_log_msg
  FROM CUSTOMER_CONTACT A
  WHERE a.KY_ENROLL = 1566339
ORDER BY ts_added DESC
/

