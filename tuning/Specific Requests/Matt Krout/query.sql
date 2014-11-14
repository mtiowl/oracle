SELECT GW.KY_GW_TRANSACTION
 FROM PGOODWRENCH.GW_AUDIT GW, '||
                                  '  ACCOUNT A, BILL_ACCOUNT BA '||
                                ' WHERE A.KY_ENROLL = GW.KY_ENROLL '||
                                ' AND GW.KY_ENROLL = BA.KY_ENROLL ';

AND GW.KY_STATUS IN(
AND GW.KY_STATUS =  --maditory
 AND GW.DT_REQUEST <=
 and GW.DT_REQUEST >=
 AND A.KY_SUPPLIER IN(  --manditory
 AND A.KY_ENROLL = 
 AND BA.TX_BILLING_NUMBER =
 ( (AND A.TX_UTILITY_ACCOUNT =  AND A.KY_UTILITY_NAME =)
  OR A.KY_UTILITY_NAME =)
  
ORDER BY A.KY_ENROLL, GW.DT_REQUEST 
                                
                                
                                
                                
select status, supplier_name....
  from t1, t2, t3
  where inner joins
  order
  
  
  
  
SELECT GW.KY_GW_TRANSACTION
 FROM PGOODWRENCH.GW_AUDIT GW
     ,ACCOUNT A
     ,BILL_ACCOUNT BA
  WHERE A.KY_ENROLL = GW.KY_ENROLL
    AND GW.KY_ENROLL = BA.KY_ENROLL
--
    AND GW.KY_STATUS IN (p_statuses)
    AND GW.KY_STATUS =  --maditory
    AND GW.DT_REQUEST <=
    and GW.DT_REQUEST >=
    AND A.KY_SUPPLIER IN(  --manditory
    AND A.KY_ENROLL = 
    AND BA.TX_BILLING_NUMBER =
    AND (   (A.TX_UTILITY_ACCOUNT =  AND A.KY_UTILITY_NAME =)
          OR A.KY_UTILITY_NAME =
        )
ORDER BY A.KY_ENROLL, GW.DT_REQUEST 