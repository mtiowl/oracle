select trunc(end_interval_time) snap_date, count(*) snaps, 
       min(snap_id) MIN_ID, max(snap_id) max_id,
       '   '||to_char(min(end_interval_time),'HH24:MI') min_time,
       to_char(max(end_interval_time),'HH24:MI')||'   ' max_time,
       trunc(sysdate)-trunc(end_interval_time) age_days
  from dba_hist_snapshot
 group by trunc(end_interval_time)
 order by 1;

