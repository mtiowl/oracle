REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT emailaddress, TEMPLATE, a.supplier, ernumber, added
  FROM (SELECT cust.tx_cntc2_email_ad emailaddress,
               CASE
                  WHEN a.qy_days_overdue BETWEEN 3 AND 9
                     THEN CASE       -- Only some markets will send out collections after 3 days
                            WHEN a.ky_utility_name IN ('SOCAL', 'SDGE')
                               THEN 'Collections3'
                            ELSE 
                                'NONE'
                         END
                  WHEN a.qy_days_overdue BETWEEN 10 AND 19
                     THEN 'Collections10'
                  WHEN a.qy_days_overdue >= 20
                     THEN 'Collections20'
                  ELSE 'NONE'
               END TEMPLATE,
               cust.ky_supplier_id supplier, cust.ky_er_ref_id ernumber,
               SYSDATE added, a.qy_days_overdue overdue
          FROM cis_collections_queue a, customer_er cust
         WHERE ky_supplier = 'XOOM'
           AND a.ky_enroll = cust.ky_er_ref_id
		   and ky_utility_name in ('PGE',
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
           AND a.cd_queue_status <> 'DN') a -- Exclude Do Not Call accounts
       LEFT OUTER JOIN
       (select recipient, kyvalue, templatename, max(addedon) addedon from pview.email_list group by recipient, kyvalue, templatename) e  -- Join Sent emails to prevent dups.
       ON (    a.emailaddress = e.recipient
           AND a.ernumber = e.kyvalue
           AND a.TEMPLATE = e.templatename
          )
 WHERE TEMPLATE <> 'NONE' -- Exclude emails
   AND (e.addedon is null or e.addedon <= SYSDATE - overdue)
/

@utlxpls.sql