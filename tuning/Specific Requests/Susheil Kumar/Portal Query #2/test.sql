-- OLD
SELECT ACCOUNT.TX_SERVICE_LINE_1
  FROM
  	PVIEW.ACCOUNT
  	LEFT JOIN PVIEW.BILL_ACCOUNT BILL_ACCOUNT ON BILL_ACCOUNT.KY_ENROLL = PVIEW.ACCOUNT.KY_ENROLL
  	LEFT JOIN PVIEW.ENROLL ENROLL ON ENROLL.KY_ENROLL = PVIEW.ACCOUNT.KY_ENROLL
  	JOIN ER_CUSTOMER CUSTOMER ON CUSTOMER.KY_ER_REF_ID = PVIEW.ACCOUNT.KY_ENROLL
  WHERE
  	BILL_ACCOUNT.KY_BILLING_STATUS IN ('02') AND
  	(ENROLL.KY_SUPPLIER IN ('EPLUSGAS')) 
/

-- NEW
SELECT ACCOUNT.TX_SERVICE_LINE_1
  FROM	PVIEW.ACCOUNT
  	   ,PVIEW.BILL_ACCOUNT BILL_ACCOUNT
  	   ,PVIEW.ENROLL ENROLL 
       ,ER_CUSTOMER CUSTOMER 
  WHERE BILL_ACCOUNT.KY_ENROLL = ACCOUNT.KY_ENROLL
    AND ENROLL.KY_ENROLL = ACCOUNT.KY_ENROLL
    AND ENROLL.KY_SUPPLIER = 'EPLUSGAS'
    AND bill_account.ky_supplier = enroll.ky_supplier
    AND account.ky_supplier = enroll.ky_supplier
    AND BILL_ACCOUNT.KY_BILLING_STATUS IN ('02')
    AND CUSTOMER.KY_ER_REF_ID = ACCOUNT.KY_ENROLL
/