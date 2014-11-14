with 
pjmaccts as
    (select 
        a.id_ba_esco
        , a.ky_ba
        , a.ky_old_acctno
        , a.ky_supplier_id
        , a.serv_state
        , a.css_name
        , a.css_status
        , a.css_bill_option
    from 
        PVIEW.css_er_xref_cust_info a
    where 
        a.ky_supplier_id = 'TESI' 
        and a.serv_state in('DC','DE','IL','MD','NJ','OH','PA')),
----------------------------------------------------------------------------------------
pjmbills as
    (select  
        b.ky_pnd_seq_trans
        , b.ky_enroll
        , b.id_ba_esco
        , b.dt_period_start
        , b.dt_period_end
        , b.cd_purpose
        , b.cd_tran_status
        , b.cd_bill_type
        , b.cd_bill_calc_method
        , b.dt_billed_by_css
    from 
        CUSTPRO.cpm_pnd_tran_hdr b
    where 
        b.ky_supplier = 'TESI' 
        and b.id_edc_duns in('006920284DC' 	--PEPCO-DC
        										, '006971618DE' --CONECT-DE
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
        and (b.dt_period_start between '01-JUN-2012' AND '30-JUN-2012' 
             or b.dt_period_end between '01-JUN-2012' AND '30-JUN-2012'  
             or b.dt_period_start <= '01-JUN-2012' and b.dt_period_end >= '30-JUN-2012')  
        and b.cd_tran_status = '75' 
        and b.cd_purpose = '00'
        and b.dt_billed_by_css > '31-MAY-2012'
        and b.ky_enroll in (select ky_old_acctno from pjmaccts)),
----------------------------------------------------------------------------------------
pjmcancels as
    (select  
        b.ky_pnd_seq_trans
        , b.ky_enroll
        , b.id_ba_esco
        , b.dt_period_start
        , b.dt_period_end
        , b.cd_purpose
        , b.cd_tran_status
        , b.cd_bill_type
        , b.cd_bill_calc_method
        , b.dt_billed_by_css
    from
        CUSTPRO.cpm_pnd_tran_hdr b
    where
        b.ky_supplier = 'TESI'
        and b.id_edc_duns in('006920284DC' 	--PEPCO-DC
        										, '006971618DE' --CONECT-DE
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
        and (b.dt_period_start between '01-JUN-2012' AND '30-JUN-2012' 
             or b.dt_period_end between '01-JUN-2012' AND '30-JUN-2012'
             or b.dt_period_start <= '01-JUN-2012' and b.dt_period_end >= '30-JUN-2012')
        and b.cd_tran_status = '75'
        and b.cd_purpose = '01'
        and b.dt_billed_by_css > '31-MAY-2012'
        and b.ky_enroll in (select ky_enroll from pjmbills)),
----------------------------------------------------------------------------------------
ucaptrans as
    (select 
        c.ky_pnd_seq_trans
        , c.cd_edi_code
        , c.qy_prnt_prty
        , c.tx_tariff_desc
        , c.at_chg
        , c.tx_uom
        , c.at_qty
        , c.at_rate
    from 
        CUSTPRO.cpm_pnd_edc_egs_charges c
    where 
        c.cd_edi_code = 'UCAP2'),
----------------------------------------------------------------------------------------
products as
    (select
        d.ky_profhdr_seq
        , d.dt_eff_from
        , d.dt_eff_to
        , d.ky_pa_seq
        , d.ky_enroll
        , e.tx_elem_value
        , f.ky_mkt_attribute_hdr
        , f.dt_market_date_from
        , f.dt_market_date_to
        , f.qy_value
    from 
        CUSTPRO.cpm_product_account d
        , CUSTPRO.cpm_bill_determinant e
        , CUSTPRO.mkt_attribute_value_range f
        , CUSTPRO.mkt_attribute_alias g
    where
        d.ky_enroll in(select 
        									pjmbills.ky_enroll
        							 from 
        							 		pjmbills
        							 		, ucaptrans
        							 where 
        							 		pjmbills.ky_pnd_seq_trans = ucaptrans.ky_pnd_seq_trans
        							 		and pjmbills.dt_period_start between d.dt_eff_from and d.dt_eff_to)
    and d.ky_profhdr_seq = 1000055
    and d.ky_pa_seq = e.ky_pa_seq
    and e.ky_profdtl_seq = 3
    and e.tx_elem_value = g.cd_name
    and g.ky_supplier = 'TESI'
    and g.ky_mkt_attribute_hdr = f.ky_mkt_attribute_hdr
    and f.dt_eff_to = '31-DEC-9999'
    and f.dt_market_date_from = '01-JUN-2012'
    and f.dt_market_date_to = '30-JUN-2012')
----------------------------------------------------------------------------------------
select 
    pjmaccts.css_name "customername"
    , pjmaccts.id_ba_esco "utilityacct"
    , pjmaccts.ky_ba "billacct"
    , pjmaccts.ky_old_acctno "ernumber"
    , pjmaccts.css_status "acctstatus"
    , pjmaccts.css_bill_option "billopt"
    , products.ky_profhdr_seq "hdrseq"
    , products.ky_pa_seq "paseq"
    , products.dt_eff_from "prodfrom"
    , products.dt_eff_to "prodto"
    , products.tx_elem_value "index"
    , products.qy_value "caprate"
    , pjmbills.ky_pnd_seq_trans "billtrans"
    , pjmbills.dt_period_start "billstart"
    , pjmbills.dt_period_end "billend"
    , pjmbills.cd_purpose "billpurpose"
    , pjmbills.dt_billed_by_css "billdate"
    , pjmbills.cd_tran_status "billstatus"
    , pjmbills.cd_bill_type "billtype"
    , pjmbills.cd_bill_calc_method "billmethod"
    , pjmcancels.ky_pnd_seq_trans "canceltrans"
    , pjmcancels.dt_period_start "cancelstart"
    , pjmcancels.dt_period_end "cancelend"
    , pjmcancels.cd_purpose "cancelpurpose"
    , pjmcancels.dt_billed_by_css "canceldate"
    , ucaptrans.cd_edi_code "edicode"
    , ucaptrans.qy_prnt_prty "printorder"
    , ucaptrans.tx_tariff_desc "chargedesc"
    , ucaptrans.at_chg "chargeamt"
from
    pjmaccts
    inner join products on pjmaccts.ky_old_acctno = products.ky_enroll
    inner join pjmbills on pjmaccts.ky_old_acctno = pjmbills.ky_enroll
    inner join ucaptrans on pjmbills.ky_pnd_seq_trans = ucaptrans.ky_pnd_seq_trans
    left join pjmcancels on (pjmbills.ky_enroll = pjmcancels.ky_enroll
    												 and pjmbills.dt_period_start = pjmcancels.dt_period_start
    												 and pjmbills.dt_period_end = pjmcancels.dt_period_end
    												 and pjmcancels.dt_billed_by_css > pjmbills.dt_billed_by_css)
order by
    pjmaccts.css_name
    , pjmaccts.id_ba_esco
    , pjmbills.dt_period_start
    , pjmbills.dt_billed_by_css
    , ucaptrans.qy_prnt_prty