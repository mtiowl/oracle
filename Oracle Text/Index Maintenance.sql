
-- See:  http://docs.oracle.com/cd/B19306_01/text.102/b14217/ind.htm#i1008452
--       http://docs.oracle.com/cd/B14117_01/text.101/b10730/cddlpkg.htm#i998200
--       http://docs.oracle.com/cd/B19306_01/text.102/b14218/aviews.htm#i13530
--       http://docs.oracle.com/cd/B12037_01/text.101/b10730/crptpkg.htm#i996810
--       http://docs.oracle.com/cd/B19306_01/text.102/b14217/ind.htm#i1006201

-- Synchronize the Oracle Text indexes
DECLARE
  CURSOR sql1 is select distinct(pnd_index_owner||'.'||pnd_index_name) as index_name, pnd_index_name from ctxsys.ctx_pending;
 
BEGIN
   DBMS_STATS.GATHER_TABLE_STATS('pview', 'enroll') ;
   DBMS_STATS.GATHER_TABLE_STATS('pview', 'account') ;
   DBMS_STATS.GATHER_TABLE_STATS('pview', 'bill_account') ;

   FOR rec1 IN sql1 LOOP
      ctx_ddl.sync_index(rec1.index_name);
      dbms_stats.gather_index_stats (user, rec1.pnd_index_name);
   END LOOP;
END;
/






select distinct(pnd_index_owner||'.'||pnd_index_name) as index_name, pnd_index_name from ctxsys.ctx_pending;


drop table output;
create table output (result CLOB);
 
  declare
    x clob := null;
  begin
    --ctx_report.index_stats('ENROLL_CONTRACT_CTX',x);
    ctx_report.index_stats('ACCT_CUSTOMER_NAME_CTX',x);
    --CTX_REPORT.INDEX_SIZE ('ACCT_CUSTOMER_NAME_CTX',x);
    insert into output values (x);
    commit;
    dbms_lob.freetemporary(x);
  end;
/

set long 1000000

select result from output;

set serveroutput on size 1000000

DECLARE
    l_data CLOB := null;
    l_string_start NUMBER;
    l_string_end NUMBER;
    l_temp_string VARCHAR2(500);
 BEGIN
    FOR irec IN (SELECT idx_name, idx_owner FROM ctxsys.ctx_indexes WHERE idx_owner <> 'CTXSYS' AND idx_name IN  ('ACCT_DBA_CTX'
                                                                                                                 ,'ACCT_CUSTOMER_NAME_CTX'
                                                                                                                 ,'BILLACCT_BILLING_NUM_CTX'
                                                                                                                 ,'ENROLL_CONTRACT_CTX'     
                                                                                                                 ,'ENROLL_CLIENT_ACCT_CTX'  
                                                                                                                 ,'ENROLL_TRACKING_ID_CTX'  
                                                                                                                 ,'ACCT_UTILITY_CTX'        
                                                                                                                 ,'ACCT_MAIL_CITY_CTX'      
                                                                                                                 ,'ACCT_MAIL_LINE_1_CTX'    
                                                                                                                 --,'ACCT_MAIL_LINE_2_CTX'    
                                                                                                                 --,'ACCT_SERVICE_CITY_CTX' 
                                                                                                                 --,'ACCT_SERVICE_LINE_1_CTX' 
                                                                                                                 --,'ACCT_SERVICE_LINE_2_CTX'
                                                                                                                 --,'ENROLL_SECTION_CTX'
                                                                                                                 ) ) LOOP
       ctx_report.index_stats(irec.idx_owner||'.'||irec.idx_name,l_data);
       l_string_start := dbms_lob.instr(lob_loc => l_data
                                    ,pattern => 'estimated row fragmentation:'   -- what we're looking for in the strgin
                                    ,offset  => 1                                -- starting position
                                     --,nth     => l_record_count                -- nth occurance of the search pattern
                                    );
 --      dbms_output.put_line ('l_string_start: '||l_string_start);
       -- Getting the end position which is the '%'
       l_string_end := dbms_lob.instr(lob_loc => l_data
                                  ,pattern => '%'   -- what we're looking for in the strgin
                                  ,offset  => l_string_start                   -- starting position
                                     --,nth     => l_record_count                -- nth occurance of the search pattern
                                    );
       -- Getting the starting point of the ':' found in the 'estimated row fragmentation:' label
       l_string_start := dbms_lob.instr(lob_loc => l_data
                                    ,pattern => ':'   -- what we're looking for in the strgin
                                    ,offset  => l_string_start                   -- starting position
                                       --,nth     => l_record_count                -- nth occurance of the search pattern
                                     );
       -- Extracting the percetage without 'estimated row fragmentation' and without '%'
       l_temp_string := dbms_lob.substr(lob_loc => l_data||'|'
                                     ,amount  => l_string_end-l_string_start-1
                                     ,offset  => l_string_start+1
                                     );
 --      dbms_output.put_line ('l_temp_string: '||l_temp_string);
       dbms_output.put_line (irec.idx_owner||'.'||irec.idx_name||' is '||to_number(trim(l_temp_string))||'% FRAGMENTED');
       l_data := null;
   END LOOP;
--   dbms_lob.freetemporary(l_data);
 END;
/

/*
PVIEW.BILLACCT_BILLING_NUM_CTX is 65% FRAGMENTED
PVIEW.ENROLL_CONTRACT_CTX is 95% FRAGMENTED
PVIEW.ENROLL_CLIENT_ACCT_CTX is 2% FRAGMENTED
PVIEW.ENROLL_TRACKING_ID_CTX is 6% FRAGMENTED
PVIEW.ACCT_UTILITY_CTX is 41% FRAGMENTED
PVIEW.ACCT_DBA_CTX is 97% FRAGMENTED
PVIEW.ACCT_CUSTOMER_NAME_CTX is 91% FRAGMENTED
PVIEW.ACCT_MAIL_CITY_CTX is 99% FRAGMENTED
PVIEW.ACCT_MAIL_LINE_1_CTX is 97% FRAGMENTED
*/


begin 
  --ctx_ddl.optimize_index('ENROLL_CONTRACT_CTX','FAST'); 
  ctx_ddl.optimize_index('ACCT_CUSTOMER_NAME_CTX','FAST'); 
end;
/

