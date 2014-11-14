col seg_name format a10 HEADING "Rollback|Segment"
col opt  HEADING "Optimal|size (KB)"
col curext HEADING "Current|Extents"
col curblk HEADING "Current|Blocks"
col avgs HEADING "Avg Shrink|Amount (KB)"
col currsize HEADING "Current|Size (KB)"

SELECT rn.Name seg_name, rs.OPTSIZE/1024 opt, rs.RSSize/1024 currsize, extents, CUREXT, CURBLK
      , rs.Gets "Gets",
       rs.waits "Waits", (rs.Waits/rs.Gets)*100 "% Waits",
       rs.Shrinks "# Shrinks", round(rs.aveshrink/1024) avgs, rs.Extends "# Extends", rs.wraps
FROM   sys.v_$rollName rn, sys.v_$rollStat rs
WHERE  rn.usn = rs.usn
/
