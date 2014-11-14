SET SERVEROUTPUT ON SIZE 1000000

spool gather_iu_driver.out


DECLARE

   CURSOR get_stream_headers (p_ky_pnd_seq_trans cpm_pnd_tran_hdr.ky_pnd_seq_trans%type) IS
      SELECT sh.*
        FROM CUSTPRO.str_idxpricngbrkdn_hdr ih
            ,CUSTPRO.str_stream_header sh
        WHERE ih.ky_pnd_seq_trans = p_ky_pnd_seq_trans
          AND sh.tranptr = ih.tranptr 
          AND sh.colname LIKE 'ER%_STAT';


  --  This mimics the call made from the Gather IU button in MS Access

  l_error_rec   PCPM.error_rec;
  l_ky_pnd_seq_trans NUMBER;

BEGIN

   --  ************************************************************************
   --     Status 45 transaction found by M. Rich
   --     MACY'S CORPORATE SERVICES INC 1-VC9KL
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11608914;

   --  ************************************************************************
   --     11331072	WAL-MART STORES INC 1-S7WFG
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11331072;
   
   --  ************************************************************************
   --    11333023  WAL-MART STORES INC 1-ALJ5U
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11333023;
   
   --  ************************************************************************
   --   11557993	GMRI INC 1-1ZKIFA	  February , 2011
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11557993;
   
   --  ************************************************************************
   --  11599496   T-MOBILE USA INC 1-2BLNB4   March    , 2011
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11599496;
   
   --  ************************************************************************
   --  11331296   ACCOR NORTH AMERICA CORP 1-A5FV6
   --     COMED w/Ragged and value in PTH.ts_idr_start
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11331296;

   --UPDATE cpm_pnd_tran_hdr
   --  SET ts_idr_start = trunc(ts_idr_start)
   --     ,ts_idr_end   = trunc(ts_idr_end)
   --  WHERE ts_idr_start IS NOT NULL
   --    AND ts_idr_end IS NOT NULL
   --    AND ky_pnd_seq_trans IN (10858359,10705903,11027145,10767085,10925381,11092054) ;
                           

   
   --  ************************************************************************
   --     No worklists but it still in 45
   --  12599453  PETSMART INC 1-2E93XZ
   --  12287653	 7-ELEVEN INC 1-20MIEA     01-JUN-11
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12599453;
   --l_ky_pnd_seq_trans := 12287653;
   
   
   --  ************************************************************************
   --  12599440  SEARS ROEBUCK AND CO INC 1-1WOYI3
   --  11333490	COSTCO WHOLESALE CORPORATION 1-1R1L30
   --     No worklists and dt_last_usage_gathered is NULL
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12599440;
   --l_ky_pnd_seq_trans := 11333490;
   
   --  ************************************************************************
   --         No worklists but has dt_last_usage_gathered
   --  11331198  T-MOBILE USA INC 1-281LCH (November, 2010)
   --
   --    STAY AWAY!!! Has 441 sub accounts!!!
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11331198;
   
   
   
   --  ************************************************************************
   --       FINALED sub account
   --  12459035   CB HOLDING CORPORATION 1-232Y4R
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12459035;
   
   --UPDATE cpm_pnd_tran_hdr
   --  set cd_tran_status = '45'
   --  where ky_pnd_seq_trans IN (l_ky_pnd_seq_trans);

   --UPDATE cpm_settlement_sub_accounts
   --  set qy_percent_of_usage = 0
   --  where ky_pnd_seq_trans = l_ky_pnd_seq_trans;



   --  ************************************************************************
   --  PEPCO "Ragged"  AVENUE ASSOCIATES LIMITED PARTNERSHIP 1-15VXSA
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11558774;
   
   --  ************************************************************************
   -- ACCOR NORTH AMERICA CORP 1-A5FV6  October, 2010
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12596750;
   
   --  ************************************************************************
   --  11331395  POLYMER ENGINEERED PRODUCTS, INC. 1-2AL3EL
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11331395;
   
      --  ************************************************************************
   --    !!!!!!!     NOTE   !!!!!!!!!
   --        This is the transaction that has a bill ending on the same
   --        day as the settlement period and the ts_calc_end date is being
   --        adjusted to 29-JUN-2011....causing the last day of usage
   --        to never be picked up
   --    !!!!!!!  
   --      
   --     45 Status, usage not 100% but no worklists are created
   -- 12287653   7-ELEVEN INC 1-20MIEA  June, 2011   
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12287653;
     
   --l_ky_pnd_seq_trans := 12599514;
   
   
   --  ************************************************************************
   --    PACTIV CORPORATION 1-1PU7NH   May, 2011
   --    Issue #12
   --    Test Case #2
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 12074546;
   
   --  ************************************************************************
   --    HARLEM CONSOLIDATED SCHOOL DISTRICT 122 1-17HG7R   January , 2011
   --    Issue #20
   --    Test Case #17
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11590109;
   
   --  ************************************************************************
   --   Avalonbay (Ragged) Test Case #17
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11334579;
   
   --  ************************************************************************
   --   Production Problem (31-Aug-2011)
   --   SEPHORA USA, LLC 1-1V3OI4    March, 2011
   --   
   --   SETTLE_KH dissapeared AFTER transation went to 55
   --  ************************************************************************
   --l_ky_pnd_seq_trans := 11599464;
   
    
    
     l_ky_pnd_seq_trans := 12074573;  --TYCO may, 2011
    --l_ky_pnd_seq_trans := 12478575; -- TYCO July, 2011
    --l_ky_pnd_seq_trans := 12289037; --June, 2011
    

   --  ************************************************************************
   --   Production Problem (31-Aug-2011)
   --   MASTERS MACHINE COMPANY 1-278Q4L    Feb, 2011
   --   
   --   SETTLE_KH dissapeared
   --  ************************************************************************    
  --l_ky_pnd_seq_trans := 11558598;
     
   --  ************************************************************************
   --   Production Problem (31-Aug-2011)
   --   ST. LAURENCE CHURCH 1-2GJXFE   March, 2011
   --   
   --   SETTLE_KH dissapeared
   --  ************************************************************************         
     --l_ky_pnd_seq_trans := 11716380;

   -- *************************************************************************
   --  ProdTest issue: not getting partial usage for finaled accounts
   --
   --  12575921 - SUNOVION PHARMACEUTICALS INC 1-1L7VXA   July, 2011
   --  12074573 - TYCO INTERNATIONAL MANAGEMENT COMPANY 1-26ZCZL   May, 2011
   -- *************************************************************************
   
   
   
   
   
   
   -- *************************************************************************
   --   Testing on 08-SEP-2011
   --
   -- *************************************************************************
   --l_ky_pnd_seq_trans := 12287814;  11 subs
   --l_ky_pnd_seq_trans := 11716380;  finaled account
   --l_ky_pnd_seq_trans := 12422521; -- 101 subs
   
   --l_ky_pnd_seq_trans := 12884832; -- Meredith's issue
   
   --l_ky_pnd_seq_trans := 12364569;  -- USPS
  
   --l_ky_pnd_seq_trans := 12345670; -- Catholic Diocese  01-FEB-11
   --l_ky_pnd_seq_trans := 12344856; --Catholic Dicese 01-DEC-2010
   
   -- **************************************************************************
   --  the following transactions have extra stream table values for a ky_enroll
   --  that is no longer active in Aggregation.
   --  Testing the PURGE_STREAM_VALUES procedure  26-SEP-2011
   -- **************************************************************************
   --l_ky_pnd_seq_trans := 12663714;   --125 COURT STREET LLC 1-2IPA89  01-AUG-2011
   --l_ky_pnd_seq_trans := 12629424;   --COMCAST CABLE COMMUNICATIONS INC 1-2IU5VD   01-AUG-2011
   
   -- **************************************************************************
   --  the following transactions are NOT terminated in CSS but have been
   --  terminated in Aggregation.     26-SEP-2011
   -- **************************************************************************
   --l_ky_pnd_seq_trans := 11889203;   --BILLINGSLEY PROPERTY SERVICES 1-95L9H   01-APR-2011
   
   
   
   --l_ky_pnd_seq_trans := 13191148;

   l_ky_pnd_seq_trans := 12411916;
   
   pcpm_settlement_usage_mti.m_debugging := TRUE;
   pcpm_settlement_support.m_debugging := FALSE;
   pcpm_settlement_validate.m_debugging := FALSE;
   pcpm_settlement_support.m_data_dump := FALSE;
   pcpm_calc_support.m_debugging := FALSE;
   pcpm_context_support.g_debugging := FALSE;
   
  
   pcpm_settlement_usage.gather_usage(l_ky_pnd_seq_trans);


   
END;
/
spool off