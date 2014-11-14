set autotrace on
set timing on

SELECT *
  FROM cpm_pnd_tran_hdr
  WHERE cd_bill_type = 'Z'
    AND ky_supplier = 'X';

set timing off
set autotrace off