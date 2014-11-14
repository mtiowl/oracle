-- PVIEW
DROP INDEX mti_test_indx;
CREATE INDEX mti_test_indx ON email_list (supplier, addedon);

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'email_list');
END;
/


-- Owned by PPLSCIS
CREATE INDEX mti_test_indx_2 ON cis_collections_queue (ky_supplier
                                                      ,ky_enroll
                                                      ,cd_queue_status
                                                      ,ky_utility_name);
BEGIN
    dbms_stats.gather_table_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE');
    dbms_stats.gather_index_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE_IDX_2');
    dbms_stats.gather_index_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE_IDX_3');
    dbms_stats.gather_index_stats('PPLSCIS', 'MTI_TEST_INDX_2');
END;
/


--2nd part of UNION
SELECT el.recipient, el.kyvalue
      ,CASE
          WHEN cq.qy_days_overdue BETWEEN 3 AND 9 THEN
              CASE       -- Only some markets will send out collections after 3 days
                 WHEN cq.ky_utility_name IN ('SOCAL', 'SDGE') THEN 'Collections3'
                 ELSE 'NONE'
                 END
          WHEN cq.qy_days_overdue BETWEEN 10 AND 19 THEN 'Collections10'
          WHEN cq.qy_days_overdue >= 20 THEN 'Collections20'
          ELSE 'NONE'
        END TEMPLATE
  FROM email_list el
      ,cis_collections_queue cq
  WHERE el.supplier = 'XOOM'
    AND el.supplier = cq.ky_supplier
    AND cq.ky_enroll = el.kyvalue
    --AND TEMPLATE = el.templatename
    AND (el.addedon is null OR el.addedon >=SYSDATE - cq.qy_days_overdue)
/

--1st part of UNION
SELECT --cust.tx_cntc2_email_ad emailaddress
       --,cust.ky_er_ref_id ernumber
      cust.tx_email
      ,cust.ky_enroll
      ,CASE
          WHEN a.qy_days_overdue BETWEEN 3 AND 9 THEN
              CASE       -- Only some markets will send out collections after 3 days
                 WHEN a.ky_utility_name IN ('SOCAL', 'SDGE') THEN 'Collections3'
                 ELSE 'NONE'
                 END
          WHEN a.qy_days_overdue BETWEEN 10 AND 19 THEN 'Collections10'
          WHEN a.qy_days_overdue >= 20 THEN 'Collections20'
          ELSE 'NONE'
        END TEMPLATE
       --,cust.ky_supplier_id supplier
       --,SYSDATE added
       --,a.qy_days_overdue overdue
   FROM cis_collections_queue a
       --,customer_er cust
       --,CSS_ER_XREF_CUST_INFO cust
       ,account cust
   WHERE a.ky_supplier = 'XOOM'
     --AND a.ky_enroll = cust.ky_er_ref_id
     --AND a.ky_enroll = cust.ky_old_acctno
     --AND a.ky_supplier =  cust.ky_supplier_id
     AND a.ky_enroll = cust.ky_enroll
     AND a.ky_supplier = cust.ky_supplier
     AND a.cd_queue_status <> 'DN'
     --and a.ky_enroll = 2613383
	   and a.ky_utility_name in ('PGE',
					'SOCAL',
					'SDGE',
					'CPL',
					'WTU',
					'CPE',
					'ONCOR',
					'TNMP',
					'NICOR',
					'COMED',
					'NORTHSHORE',
					'PEOPLES',
					'MECO',
					'NANT',
					'BOSTED',
					'CAMB',
					'COMCAMB',
					'WMECO')
/



SELECT --cust.tx_cntc2_email_ad emailaddress
       --,cust.ky_er_ref_id ernumber
      cust.tx_email
      ,cust.ky_enroll
      ,CASE
          WHEN a.qy_days_overdue BETWEEN 3 AND 9 THEN
              CASE       -- Only some markets will send out collections after 3 days
                 WHEN a.ky_utility_name IN ('SOCAL', 'SDGE') THEN 'Collections3'
                 ELSE 'NONE'
                 END
          WHEN a.qy_days_overdue BETWEEN 10 AND 19 THEN 'Collections10'
          WHEN a.qy_days_overdue >= 20 THEN 'Collections20'
          ELSE 'NONE'
        END TEMPLATE
       --,cust.ky_supplier_id supplier
       --,SYSDATE added
       --,a.qy_days_overdue overdue
   FROM cis_collections_queue a
       --,customer_er cust
       --,CSS_ER_XREF_CUST_INFO cust
       ,account cust
   WHERE a.ky_supplier = 'XOOM'
     --AND a.ky_enroll = cust.ky_er_ref_id
     --AND a.ky_enroll = cust.ky_old_acctno
     --AND a.ky_supplier =  cust.ky_supplier_id
     AND a.ky_enroll = cust.ky_enroll
     AND a.ky_supplier = cust.ky_supplier
     AND a.cd_queue_status <> 'DN'
     --and a.ky_enroll = 2613383
	   and a.ky_utility_name in ('PGE',
					'SOCAL',
					'SDGE',
					'CPL',
					'WTU',
					'CPE',
					'ONCOR',
					'TNMP',
					'NICOR',
					'COMED',
					'NORTHSHORE',
					'PEOPLES',
					'MECO',
					'NANT',
					'BOSTED',
					'CAMB',
					'COMCAMB',
					'WMECO')
MINUS
SELECT el.recipient, to_number(el.kyvalue), el.templatename
  FROM email_list el
  WHERE (el.addedon is null OR el.addedon >=SYSDATE - 5)
    AND supplier = 'XOOM'
/