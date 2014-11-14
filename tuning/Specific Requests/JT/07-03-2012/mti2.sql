select pjmaccts.css_name "customername"
      ,pjmaccts.id_ba_esco "utilityacct"
      ,pjmaccts.ky_ba "billacct"
      ,pjmaccts.ky_old_acctno "ernumber"
      ,pjmaccts.css_status "acctstatus"
      ,pjmaccts.css_bill_option "billopt"
      ,pa.ky_profhdr_seq "hdrseq"
      ,pa.ky_pa_seq "paseq"
      ,pa.dt_eff_from "prodfrom"
      ,pa.dt_eff_to "prodto"
      ,bd.tx_elem_value "index"
      ,vr.qy_value "caprate"
      --,CASE
      --    WHEN pjmbills.cd_purpose = '00' THEN 'Bill'
      --    WHEN pjmbills.cd_purpose = '01' THEN 'Cancel'
      -- END transaction_type
      ,pjmbills.ky_pnd_seq_trans "billtrans"
      ,pjmbills.dt_period_start "billstart"
      ,pjmbills.dt_period_end "billend"
      ,pjmbills.cd_purpose "billpurpose"
      ,pjmbills.dt_billed_by_css "billdate"
      ,pjmbills.cd_tran_status "billstatus"
      ,pjmbills.cd_bill_type "billtype"
      ,pjmbills.cd_bill_calc_method "billmethod"
      ,pjmcancels.ky_pnd_seq_trans "canceltrans"
      ,pjmcancels.dt_period_start "cancelstart"
      ,pjmcancels.dt_period_end "cancelend"
      ,pjmcancels.cd_purpose "cancelpurpose"
      ,pjmcancels.dt_billed_by_css "canceldate"
      ,ucaptrans.cd_edi_code "edicode"
      ,ucaptrans.qy_prnt_prty "printorder"
      ,ucaptrans.tx_tariff_desc "chargedesc"
      ,ucaptrans.at_chg "chargeamt"
FROM css_er_xref_cust_info      pjmaccts
    ,custpro.cpm_pnd_tran_hdr   pjmbills
    ,custpro.cpm_pnd_tran_hdr   pjmcancels
    -- Products
    ,CUSTPRO.cpm_product_account pa
    ,CUSTPRO.cpm_bill_determinant bd
    ,CUSTPRO.mkt_attribute_value_range vr
    ,CUSTPRO.mkt_attribute_alias att_alias
    --ucaptrans
    ,CUSTPRO.cpm_pnd_edc_egs_charges ucaptrans
WHERE pjmaccts.ky_old_acctno = pjmbills.ky_enroll
  AND pjmaccts.serv_state in('DC','DE','IL','MD','NJ','OH','PA')
  AND pjmaccts.ky_supplier_id = 'TESI'
  AND pjmaccts.ky_supplier_id = pjmbills.ky_supplier
  -- Bills
  AND pjmbills.ky_supplier = 'TESI'
  AND pjmbills.cd_tran_status = '75' 
  AND pjmbills.cd_purpose = '00'
  AND pjmbills.id_edc_duns in('006920284DC' 	--PEPCO-DC
        			 							 ,'006971618DE' --CONECT-DE
        										 ,'006929509' 		--COMED
        										 ,'043381565EDC' --APS-MD
        										 ,'156171464'		--BGE
        										 ,'006971618MD'	--CONECT-MD
        										 ,'006920284'		--PEPCO
        										 ,'006971618NJ'	--CONECT-NJ
        										 ,'006973358'		--JCPL
        										 ,'006973812'		--PSEG
        										 ,'617976758'		--ROCKLAND
        										 ,'007900293'		--CEI
        										 ,'006998371'		--OHIOEDISON
        										 ,'007904626'		--TOLEDOED
        										 ,'007911050EDC'	--APS(PA)
        										 ,'007915606'		--DQE
        										 ,'007916836'		--METED
        										 ,'007914468'		--PECO
        										 ,'008967614'		--PENE
        										 ,'007912736'		--PENNP
        										 ,'007909427AC'	--PPL
        										 ,'099427866'		--UGI
        										 )
   AND (  pjmbills.dt_period_start between '01-JUN-2012' AND '30-JUN-2012' 
        or pjmbills.dt_period_end  between '01-JUN-2012' AND '30-JUN-2012'  
        or (pjmbills.dt_period_start <= '01-JUN-2012' and pjmbills.dt_period_end >= '30-JUN-2012')
       )  
   AND pjmbills.dt_billed_by_css > '31-MAY-2012'
   -- CANCELS
   AND pjmcancels.ky_supplier = pjmbills.ky_supplier
   AND pjmcancels.id_edc_duns = pjmbills.id_edc_duns
   AND pjmbills.dt_period_start = pjmcancels.dt_period_start
   AND pjmbills.dt_period_end = pjmcancels.dt_period_end
   AND pjmcancels.dt_billed_by_css > pjmbills.dt_billed_by_css
   AND (   pjmcancels.dt_period_start between '01-JUN-2012' AND '30-JUN-2012' 
        or pjmcancels.dt_period_end between '01-JUN-2012' AND '30-JUN-2012'
        or (pjmcancels.dt_period_start <= '01-JUN-2012' and pjmcancels.dt_period_end >= '30-JUN-2012')
       )
   AND pjmcancels.cd_tran_status = '75'
   AND pjmcancels.cd_purpose = '01'
   AND pjmcancels.dt_billed_by_css > '31-MAY-2012'
        --and pjmbills.ky_enroll in (select ky_old_acctno from pjmaccts)
   AND pa.ky_enroll = pjmbills.ky_enroll
   AND att_alias.ky_supplier = pjmbills.ky_supplier
   AND pa.ky_profhdr_seq = 1000055
   AND pa.ky_pa_seq = bd.ky_pa_seq
   AND bd.ky_profdtl_seq = 3
   AND bd.tx_elem_value = att_alias.cd_name
   AND att_alias.ky_mkt_attribute_hdr = vr.ky_mkt_attribute_hdr
   AND vr.dt_eff_to = '31-DEC-9999'
   AND vr.dt_market_date_from = '01-JUN-2012'
   AND vr.dt_market_date_to = '30-JUN-2012'
   --ucaptrans
   AND pjmbills.ky_pnd_seq_trans = ucaptrans.ky_pnd_seq_trans
   AND ucaptrans.cd_edi_code = 'UCAP2'
/