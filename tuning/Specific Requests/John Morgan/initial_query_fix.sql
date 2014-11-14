CREATE INDEX mti_testing ON CIS_CL_HEADER(ts_added);
drop index mti_testing;



select count(*), trunc(hdr.TS_ADDED) as DT_ADDED
       ,decode (hdr.ts_added, NULL, 'FIRST', 'SECOND')
       ,hdr.ts_added
       ,b.id_user_id 
  from PPLSCIS.CIS_CL_HEADER hdr
     , PPLSCIS.CIS_USER_XREF b
     , PPLSCIS.CIS_USER_ROLES user_roles
     , PPLSCIS.CIS_ROLES roles
  where hdr.TS_ADDED > '1-jan-2012'
    and B.ID_USER_GUID = hdr.ID_USER_GUID
    and hdr.ID_USER_GUID = user_roles.id_user_guid
    and user_roles.KY_ROLE_ID = roles.ky_role_id
    and roles.ky_role_Name in('PPLS_CARE', 'PPLS_CARE_LEAD','PPLS_CARE_SUPERVISOR')
  GROUP BY trunc(hdr.TS_ADDED), decode(hdr.ts_added, NULL, 'FIRST', 'SECOND'), hdr.ts_added, b.id_user_id 
/


select trunc(hdr.TS_ADDED) as DT_ADDED
       ,decode (hdr.ts_added, NULL, 'FIRST', 'SECOND')
       ,hdr.ts_added
       ,b.id_user_id 
  from PPLSCIS.CIS_CL_HEADER hdr
     , PPLSCIS.CIS_USER_XREF b
     , PPLSCIS.CIS_USER_ROLES user_roles
     , PPLSCIS.CIS_ROLES roles
  where hdr.TS_ADDED > '1-jan-2012'
    and B.ID_USER_GUID = hdr.ID_USER_GUID
    and hdr.ID_USER_GUID = user_roles.id_user_guid
    and user_roles.KY_ROLE_ID = roles.ky_role_id
    and roles.ky_role_Name in('PPLS_CARE', 'PPLS_CARE_LEAD','PPLS_CARE_SUPERVISOR')
/



select count(*), trunc(hdr.TS_ADDED) as DT_ADDED
      ,case hdr.ts_added
            when hdr.ts_modified then 'FIRST'
            else 'SECOND'
         end
         as closed
       ,b.id_user_id 
  from PPLSCIS.CIS_CL_HEADER hdr
     , PPLSCIS.CIS_USER_XREF b
     , PPLSCIS.CIS_USER_ROLES user_roles
     , PPLSCIS.CIS_ROLES roles
  where hdr.TS_ADDED > '1-jan-2012'
    and B.ID_USER_GUID = hdr.ID_USER_GUID
    and hdr.ID_USER_GUID = user_roles.id_user_guid
    and user_roles.KY_ROLE_ID = roles.ky_role_id
    and roles.ky_role_Name in('PPLS_CARE', 'PPLS_CARE_LEAD','PPLS_CARE_SUPERVISOR')
  GROUP BY trunc(hdr.TS_ADDED), case hdr.ts_added
            when hdr.ts_modified then 'FIRST'
            else 'SECOND'
         end
         ,b.id_user_id 
/
