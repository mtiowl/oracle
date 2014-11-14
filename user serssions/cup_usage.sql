select 	nvl(ss.USERNAME,'ORACLE PROC') username
	,ss.program
	,ss.osuser
	,ss.status
	,VALUE cpu_usage
from 	v$session ss, 
	v$sesstat se, 
	v$statname sn
where  	se.STATISTIC# = sn.STATISTIC#
and  	NAME like '%CPU used by this session%'
and  	se.SID = ss.SID
order  	by ss.status, VALUE desc
/
