select trunc(snap_time) snap_date, count(*) snaps, 
       min(snap_id) MIN_ID, max(snap_id) max_id,
       '   '||to_char(min(snap_time),'HH24:MI') min_time,
       to_char(max(snap_time),'HH24:MI')||'   ' max_time
  from stats$snapshot
 group by trunc(snap_time)
 order by 1;

