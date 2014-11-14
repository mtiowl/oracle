DECLARE
  l_job_id NUMBER;
  l_next   DATE := sysdate+(10*(1/24/60/60));
BEGIN
  dbms_output.put_line ('next date '||l_next);
  dbms_job.submit(l_job_id, 'MTI_TEST;', l_next);
  dbms_output.put_line ('Job ID: '||l_job_id);
  commit;
END;
/
