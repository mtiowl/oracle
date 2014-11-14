
-- Find the objects that have the buffer busy wait event
SELECT row_wait_obj#
  FROM V$SESSION
 WHERE EVENT = 'buffer busy waits'
/


--Use the row_wait_obj# from above for OBJECT_ID or DATA_OBJECT_ID
SELECT owner, object_id, data_object_id, object_name, object_type
  FROM DBA_OBJECTS
 WHERE (    data_object_id IN (60924, 62772, 117185, 60153, 62783, 80809) 
         OR object_id IN (60924, 62772, 117185, 60153, 62783, 80809) 
       )
/