CREATE OR REPLACE PACKAGE SV_ACCOUNT_EXTRACT
IS

-- NOTE: The procedure SS_HandleEnhancedAutoLinking requires that the following lines
-- be run in the SELFSERV@PSOLD database

--CREATE or replace PUBLIC SYNONYM SYN_SS_ENHANCED_AUTOLINK_LOG FOR SS_ENHANCED_AUTOLINK_LOG;
--GRANT SELECT, INSERT, UPDATE, DELETE ON SYN_SS_ENHANCED_AUTOLINK_LOG TO PUBLIC;

/*************************************************************
* Name: SV_Account_Extract
*
* Description: Called by batch process nightly to send new CSS account information
*              to the portal.  Some functions are used by other packages.
*
* Author: TKS
* Date:   July 24, 2001
* Revision History:  TKS -- Portal Releases Prior to 2.5 (changes weren't documented)
*                    DRBreininger     ITEM 1005         3/10/2003 (Rls 3.0)
*                    TKS -- ITEM 1111 3/12/2003  (Rls 3.0)
*                    TKS -- May 04, 2003 -- Portal Release 4.0
*                    DRB -- October 08, 2003 Variable LPC changes
* ##D#10/26/04  #T#5454  #P#LBP  #C# Keep voided accounts from going to the Portal.
* ##D#01/24/05  #T#5637  #P#LBP  #C# send bill account and pct. tax exempt to the Portal
*   10/14/09   T21343  C. O'Neill do not let apl got to ss
**************************************************************/
   gSysDate      DT_CONST_BATCH_DTL.dt_gregorian%TYPE :=  SV_Common_Proc.GetBatchDate();
   gDateFormat   CHAR(10)   := 'YYYY-MM-DD';
   gCommitCount  NUMBER    := 200;   
   gPremiseAd    CHAR(1)    := 'P';
   gMailingAd    CHAR(1)    := 'M';
   gRltn         CHAR(2)    := '01';
   gPUActStat    CHAR(2)    := '01';
   gPUPendAct    CHAR(2)    := '02';
   gPUInactStat  CHAR(2)    := '03';
   gActStat      CHAR(2)    := '02';
   gSadActStat   CHAR(2)    := '03';
   gYes          CHAR(1)    := 'Y';
   gNo   CHAR(1)    := 'N';
   gSpace  CHAR(1)    := ' ';
   gOne   NUMBER(1)      := 1;
   gTwo   NUMBER(1)      := 2;
   gThree  NUMBER(1)      := 3;
   gFour  NUMBER(1)      := 4;
   gFive  NUMBER(1)      := 5;
   gSix   NUMBER(1)      := 6;
   gClient2      CHAR(5):= 'AESNE';
   gFirstMo      CHAR(4) := '-01';
   gZero         CHAR(1) := '0';
   gAffinity     CHAR(2) := '05';
   gMeterNoType  CHAR(4) := '0017';
   gBill         CHAR(4) := 'BILL';
   gDuns         CHAR(4) := '0020';
   gNotApplicable CHAR(3):= 'n/a';
   gUpdated      CHAR(1) := 'y';
   gNotUpdated   CHAR(1) := 'n';
   gGasSpt       CHAR(4) := '0100';
   gElecSpt      CHAR(4) := '0200';
   gGas          CHAR(2) := 'GA';
   gElec         CHAR(2) := 'EL';
   gTcom         CHAR(2) := 'TE';
   gBillOld      CHAR(8) := 'BILL-OLD';
   gLatePmtPct   NUMBER(5,2) := 1.5;
   gHighDate     CHAR(10) := '9999-12-31';
   gAccountExtract    CHAR(2)  := 'AE';
   gAESuccessful      VARCHAR2(26) := 'Account Extract Successful';
   gEPLUS        CHAR(5) := 'EPLUS';
   gVoid         CHAR(2) := '07';
   gPortalOneBill CHAR(1) := '1';
   gPortalTwoBill CHAR(1) := '2';
   gky_supplier2 css_sv_update.ky_supplier%TYPE;
   process_log_error  EXCEPTION;
   abend_error        EXCEPTION;
   void_error         EXCEPTION;
   CREATE_USER_FAILED EXCEPTION;
   
   MISSING_GROUP_ID_MSG         CONSTANT VARCHAR2(1024) := 'MISSING_GROUP_ID';
   MISSING_EMAIL_MSG            CONSTANT VARCHAR2(1024) := 'MISSING_EMAIL';
   MISSING_ZIP_CODE_MSG         CONSTANT VARCHAR2(1024) := 'MISSING_ZIP_CODE';
   MISSING_PHONE_NBR_MSG        CONSTANT VARCHAR2(1024) := 'MISSING_PHONE_NBR';
   MISSING_PHONE_AREA_CODE_MSG  CONSTANT VARCHAR2(1024) := 'MISSING_AREA_CODE';
   MISSING_FIRST_NAME_MSG       CONSTANT VARCHAR2(1024) := 'MISSING_FIRST_NAME';
   MISSING_LAST_NAME_MSG        CONSTANT VARCHAR2(1024) := 'MISSING_LAST_NAME';
   FAILED_CREATE_USERID_MSG     CONSTANT VARCHAR2(1024) := 'FAILED_CREATE_USERID';
   FAILD_CREATE_PASSWORD_MSG    CONSTANT VARCHAR2(1024) := 'FAILED_CREATE_PASSWORD';
   CREATE_USER_FAILED_MSG       CONSTANT VARCHAR2(1024) := 'CREATE_USER_FAILED';
   AUTOLINK_FAILED_MSG          CONSTANT VARCHAR2(1024) := 'AUTOLINK_FAILED';
   REGISTRATION_SUCCESS_MSG     CONSTANT VARCHAR2(1024) := 'REGISTRATION_SUCCESS';

   TYPE css_bill_acct_rec_type IS RECORD (ky_ba  BILL_ACCT.ky_ba%TYPE,
              ky_prem_no    BILL_ACCT.ky_prem_no%TYPE,
              ky_old_acctno BILL_ACCT.ky_old_acctno%TYPE,
              ky_ad  BILL_ACCT.ky_ad%TYPE,
              cd_ad_type BILL_ACCT.cd_ad_type%TYPE,
              cd_ba_stat BILL_ACCT.cd_ba_stat%TYPE,
              fl_ele_trnsfr BILL_ACCT.fl_ele_trnsfr%TYPE,
              fl_sum_bill BILL_ACCT.fl_sum_bill%TYPE,
              dt_eff BUS_DIR_NO_INSTMT.dt_eff%TYPE,
              no_due_days SUPPLIER_ACCOUNT.no_due_days%TYPE,
              dt_rdg_to TOTAL_USAGE_HDR.dt_rdg_to%TYPE,
              qy_lpc_pc SUPPLIER_ACCOUNT.qy_lpc_pc%TYPE,
              fl_lpc_eligible BILL_ACCT.fl_lpc_eligible%TYPE,
              tx_bp_mesg SUPPLIER_ACCOUNT.tx_bp_mesg%TYPE);

   TYPE css_cust_address_rec_type IS RECORD (ad_ln_1 VARCHAR2(56),
             ad_ln_2 VARCHAR2(56),
             ad_city SAD.ad_serv_city%TYPE,
             ad_serv_st SAD.ad_serv_st%TYPE,
             ad_serv_zip SAD.ad_serv_zip%TYPE,
             nm_compressed SAD.nm_compressed%TYPE,
             nm_do_business_as BA_CUST_CR_INFO.nm_do_business_as%TYPE,
             nm_cust_1 CUSTOMER.nm_cust_1%TYPE);

   TYPE css_price_usage_rec_type IS RECORD (id_ba_esco PRICE_USAGE.id_ba_esco%TYPE,
            edc_code EDC_NAME.code%TYPE, tx_edc_tar_sch PRICE_USAGE.tx_edc_tar_sch%TYPE,
            dt_last_esco_set PRICE_USAGE.dt_last_esco_set%TYPE,
            at_capacity_oblg PRICE_USAGE.at_capacity_oblg%TYPE,
            at_trans_oblg PRICE_USAGE.at_trans_oblg%TYPE,
            id_lmp_bus_no PRICE_USAGE.id_lmp_bus_no%TYPE,
            tx_edc_profile_grp PRICE_USAGE.tx_edc_profile_grp%TYPE,
            cd_serv_supp PRICE_USAGE.cd_serv_supp%TYPE,
            fl_tar_one_bill PRICE_USAGE.fl_tar_one_bill%TYPE);

   TYPE css_tax_exception_rec_type IS RECORD(pc_tax_excep TAX_EXCEPTION.pc_tax_excep%TYPE);

   TYPE css_customer_rec_type IS RECORD (nm_cust_2 CUSTOMER.nm_cust_2%TYPE,
                                         nm_cust_1 CUSTOMER.nm_cust_1%TYPE);

    CURSOR NewAccounts(p_ky_supplier css_sv_update.ky_supplier%TYPE)
   IS
      SELECT ky_ba,css_tbl_name,ky_supplier AS ky_supplier_id, fl_updated,
        ky_css_sv_update 
        FROM css_sv_update c
        WHERE fl_updated = 'n'
        AND sv_tbl_name = gNotApplicable
/*
AND ky_ba IN (
534460001,
2290421002,
2992430003,
3751940005,
4862490000,
5089910006,
6333901005,
9328970000
)
*/
        AND (ky_supplier = p_ky_supplier
             OR ky_supplier= gky_supplier2);
             --and ky_ba = '5020655006'
        /*AND c.ky_ba IN (5036264002,7610774007,9900294009,4558115007,7126625006)*/
        --FOR UPDATE ;

   new_accounts_rec NewAccounts%ROWTYPE;

--PROCEDURE ProcessNewAccounts(p_cd_rtn OUT NUMBER);
PROCEDURE ProcessNewAccounts(p_ky_supplier css_sv_update.ky_supplier%TYPE,
                             p_cd_rtn OUT NUMBER);
PROCEDURE ProcessMeters (p_ky_prem_no  IN BILL_ACCT.KY_PREM_NO%TYPE,
                         p_ky_enroll   IN PVIEW.METER.ky_enroll@PSOL%TYPE,
                         p_ky_supplier IN PVIEW.METER.ky_supplier@PSOL%TYPE,
                         p_ky_utility_rate_class IN PVIEW.METER.ky_utility_rate_class@PSOL%TYPE,
                         p_id_lmp_bus_no IN PRICE_USAGE.id_lmp_bus_no%TYPE,
                         p_profile_grp   IN PRICE_USAGE.tx_edc_profile_grp%TYPE,
                         p_meter_cycle   IN MAD.tx_meter_cycle%TYPE,
                         p_error_code  OUT NUMBER);
PROCEDURE ProcessSimplePrice (p_ky_ba IN BILL_ACCT.ky_ba%TYPE, p_ky_enroll IN PVIEW.BILL_ACCOUNT.ky_enroll@PSOL%TYPE,
                              p_ky_supplier IN PVIEW.BILL_ACCOUNT.ky_supplier@PSOL%TYPE);
PROCEDURE ProcessRateReadySimplePrice(p_ky_ba IN BILL_ACCT.ky_ba%TYPE, p_ky_enroll IN PVIEW.BILL_ACCOUNT.ky_enroll@PSOL%TYPE,
                                        p_ky_supplier IN PVIEW.BILL_ACCOUNT.ky_supplier@PSOL%TYPE);
PROCEDURE GetBillAcctInfo (p_ky_ba IN NUMBER, p_css_bill_acct IN OUT css_bill_acct_rec_type);
PROCEDURE GetCustAddressesInfo (p_ky_ba in NUMBER, p_ky_ad IN NUMBER, p_cd_ad_ln IN NUMBER, p_cd_ad_type IN VARCHAR2,
           p_cust_address IN OUT css_cust_address_rec_type);
PROCEDURE GetPUInfo (p_ky_ba IN NUMBER, p_price_usage_info IN OUT css_price_usage_rec_type);
PROCEDURE GetTCEnd (p_ky_ba IN NUMBER, p_dt_contract_end IN OUT DATE);
PROCEDURE GetAffinity (p_ky_ba IN NUMBER, p_affinity_1 IN OUT PVIEW.BILL_ACCOUNT.ky_affinity@PSOL%TYPE,
                                          p_affinity_2 IN OUT PVIEW.BILL_ACCOUNT.ky_affinity@PSOL%TYPE);
PROCEDURE GetServicePtInfo (p_ky_ba in NUMBER, p_cd_spt_type IN OUT PVIEW.ACCOUNT.ky_account_type@PSOL%TYPE);
PROCEDURE GetMadInfo (p_ky_ba in NUMBER, p_mad_rec IN OUT MAD%ROWTYPE);
PROCEDURE GetCTPBillCycle(p_ky_ba IN NUMBER, p_id_ba_esco IN VARCHAR,
                          p_ky_enroll IN NUMBER, p_bill_cycle IN OUT VARCHAR);
PROCEDURE CreateDummyEnrollRec(p_account_rec IN PVIEW.ACCOUNT@PSOL%ROWTYPE, ws_ky_ba IN BILL_ACCT.KY_BA%TYPE,
                               p_error_code OUT NUMBER);
PROCEDURE CallInsertUpdateAccount (p_account_rec IN PVIEW.ACCOUNT@PSOL%ROWTYPE, p_count IN NUMBER,
                             p_error_code OUT NUMBER);
PROCEDURE CallInsertBillAccount (p_bill_account_rec IN PVIEW.BILL_ACCOUNT@PSOL%ROWTYPE,
                                 p_error_code OUT NUMBER);
PROCEDURE CallInsertMeter (p_meter_rec IN PVIEW.METER@PSOL%ROWTYPE, p_error_code in OUT NUMBER);
PROCEDURE CallInsertEnroll (p_enroll_rec IN PVIEW.ENROLL@PSOL%ROWTYPE, p_error_code OUT NUMBER);
PROCEDURE CallInsertSimpleElectricPrice (p_sep_rec IN PVIEW.SIMPLE_ELECTRIC_PRICE@PSOL%ROWTYPE, p_error_code OUT NUMBER);
PROCEDURE GetTaxExceptionInfo (p_ky_ba in NUMBER, p_tax_exception_info IN OUT css_tax_exception_rec_type);
PROCEDURE GetCustomerInfo (p_ky_ba IN NUMBER, p_customer_info IN OUT css_customer_rec_type);
PROCEDURE CreateMeterFile(p_ky_enroll   IN PVIEW.METER_FILE.ky_enroll@PSOL%TYPE,
                          p_billing_number IN PVIEW.METER_FILE.tx_billing_number@psol%TYPE,
                          p_util_acct IN PVIEW.METER_FILE.tx_utility_account@PSOL%TYPE,
                          p_ky_supplier IN PVIEW.METER_FILE.ky_supplier@PSOL%TYPE,
                          p_ky_meter IN PVIEW.METER_FILE.ky_meter@PSOL%TYPE,
                          p_meter_equip_no IN MPT_DETAILS_TBL.ky_mtr_equip_no%TYPE,
                          p_dt_contract_start IN PVIEW.METER_FILE.dt_contract_start@PSOL%TYPE,
                          p_dt_contract_end IN PVIEW.METER_FILE.dt_contract_end@PSOL%TYPE,
                          p_error_code OUT NUMBER);
PROCEDURE ProcessMeters (p_ky_ba       IN BILL_ACCT.ky_ba%TYPE,
                         p_ky_prem_no  IN BILL_ACCT.KY_PREM_NO%TYPE,
                         p_ky_enroll   IN PVIEW.METER.ky_enroll@PSOL%TYPE,
                         p_util_acct   IN PVIEW.ACCOUNT.tx_utility_account@PSOL%TYPE,
                         p_ky_supplier IN PVIEW.METER.ky_supplier@PSOL%TYPE,
                         p_ky_utility_rate_class IN PVIEW.METER.ky_utility_rate_class@PSOL%TYPE,
                         p_id_lmp_bus_no IN PRICE_USAGE.id_lmp_bus_no%TYPE,
                         p_profile_grp   IN PRICE_USAGE.tx_edc_profile_grp%TYPE,
                         p_meter_cycle   IN MAD.tx_meter_cycle%TYPE,
                         p_dt_contract_start IN PVIEW.METER_FILE.dt_contract_start@PSOL%TYPE,
                         p_dt_contract_end   IN PVIEW.METER_FILE.dt_contract_end@PSOL%TYPE,
                         p_error_code  OUT NUMBER);
                                      
Procedure SS_HandleEnhancedAutoLinking(p_email_ad IN VARCHAR2,
                                       p_first_name IN VARCHAR2,
                                       p_last_name IN VARCHAR2,
                                       p_service_zip IN VARCHAR2,
                                       p_phone_acd IN VARCHAR2,
                                       p_phone_No IN VARCHAR2, 
                                       p_ky_supplier IN VARCHAR2,
                                       p_ky_enroll IN NUMBER);
                                  
PROCEDURE SS_EnhancedAutoLnkLogHandler(p_rec IN SYN_SS_ENHANCED_AUTOLINK_LOG@psol%ROWTYPE);
                                     
FUNCTION SS_CreateAndRegisterNewUser(p_er_cust_rec in SYN_ER_CUSTOMER%ROWTYPE,
                                     p_ky_supplier IN VARCHAR2,
                                     p_rec IN OUT SYN_SS_ENHANCED_AUTOLINK_LOG@psol%ROWTYPE)
RETURN VARCHAR2;
                                                                                             
FUNCTION SS_CreateNewUserID(p_first_name IN VARCHAR2,
                            p_last_name  IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION SS_CreateNewPassword
RETURN VARCHAR2;

FUNCTION SS_ValidateCreateParameters(p_email_ad IN VARCHAR2,
                                       p_first_name IN VARCHAR2,
                                       p_last_name IN VARCHAR2,
                                       p_service_zip IN VARCHAR2,
                                       p_phone_acd IN VARCHAR2,
                                       p_phone_No IN VARCHAR2)

RETURN VARCHAR2;


FUNCTION DoSelfServeExtract(ws_ky_supplier      VARCHAR2,
                                ws_ky_enroll        NUMBER)
                                RETURN BOOLEAN;

PROCEDURE SS_TestCreateRegisterUser;

PROCEDURE test;
END;
/