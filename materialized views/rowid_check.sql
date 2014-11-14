-- ******************************************************************************
--  Export/Import (or Data Pump) does not preserve ROWIDs.
--  This can be a problem when using Materialized View Logs that contain ROWIDs
--
--  Alternative is to use Transportable Tablespaces when copying data to another
--  database.
-- ******************************************************************************


connect custpro@psolt11
-- Selecting from MVIEW Log that was "copied" using Export/Import (source PSOLPT)
--
select *
  from mlog$_cpm_acct_attribute;
  

-- Using the rowid to lookup the record
-- This will not find the record
--
select ky_enroll
  from cpm_acct_attribute
  where rowid = 'AAAKqfACBAAAlPbABJ';


--After connecting to PSOLPT...
--The following will find the reocrd
--
connect custpro@psolpt

select ky_enroll
  from cpm_acct_attribute
  where rowid = 'AAAKqfACBAAAlPbABJ';