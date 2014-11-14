with Resolutions as(
select count(a.KY_CALL_LOG_ID) as resolvedCalls, trunc(A.TS_ADDED) as DT_ADDED, 
         case a.ts_added
            when a.ts_modified then 'FIRST'
            else 'SECOND'
         end
         as closed, 
         b.id_user_id 
 from PPLSCIS.CIS_CL_HEADER a, PPLSCIS.CIS_USER_XREF b
where A.TS_ADDED > '1-jan-2012'
and B.ID_USER_GUID = A.ID_USER_GUID
and A.ID_USER_GUID in(
    select q.id_user_guid
    from PPLSCIS.CIS_USER_ROLES q
    where q.KY_ROLE_ID in
          (select ky_role_id
            from PPLSCIS.CIS_ROLES
            where ky_role_Name in('PPLS_CARE', 'PPLS_CARE_LEAD','PPLS_CARE_SUPERVISOR')
          )
    )
    group by trunc(A.TS_ADDED), b.id_user_id, 
        case a.ts_added
            when a.ts_modified then 'FIRST'
            else 'SECOND'
         end
)

select distinct res.dt_added, res.id_user_id, 
    nvl((
        select sum(r.resolvedcalls) from resolutions r where r.id_user_id = res.id_user_id and r.dt_added = res.dt_added and r.closed = 'FIRST'
    ),0) as FirstResolved,
    nvl((
    select sum(r.resolvedcalls) from resolutions r where r.id_user_id = res.id_user_id and r.dt_added = res.dt_added and r.closed = 'SECOND'
    )
    ,0) as FollowupRequired, 
    nvl(
        (select sum(r.resolvedcalls) from resolutions r where r.id_user_id = res.id_user_id and r.dt_added = res.dt_added),0)
    as allCalls,
    round(nvl((
        select sum(r.resolvedcalls) from resolutions r where r.id_user_id = res.id_user_id and r.dt_added = res.dt_added and r.closed = 'FIRST'
    ),0) / nvl((select sum(r.resolvedcalls) from resolutions r where r.id_user_id = res.id_user_id and r.dt_added = res.dt_added),0)* 100,2) as firstResRate
from Resolutions res

