DROP type db_health_snapshots;
DROP TYPE db_health_snapshot_record;

create or replace TYPE db_health_snapshot_record as object
     (snashot_date    DATE
     ,snap_count      NUMBER
     ,min_id          NUMBER
     ,max_id          NUMBER
     ,min_time        VARCHAR2(6)
     ,max_time        VARCHAR2(6)
     )
/

create or replace TYPE db_health_snapshots as table of db_health_snapshot_record
/