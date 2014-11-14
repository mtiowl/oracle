DECLARE
 l_cur_call_log_details    SYS_REFCURSOR;
 l_cur_addl_acct_comments  SYS_REFCURSOR;
 l_cur_legacy_contacts     SYS_REFCURSOR;
BEGIN
   p_cis_call_log.get_call_log_details (p_ky_enroll => 1566339
                                       ,p_call_log_type => 'A'
                                       ,p_cur_call_log_details => l_cur_call_log_details
                                       ,p_cur_addl_acct_comments => l_cur_addl_acct_comments
                                       ,p_cur_legacy_contacts => l_cur_legacy_contacts);
END;
/
