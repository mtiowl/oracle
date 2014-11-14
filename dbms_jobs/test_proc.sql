create table mti_test_table
  (message varchar2(100)
  )
/

create or replace procedure mti_test as
l_count NUMBER;
BEGIN
  delete mti_test_table;
  select 1
   INTO l_count
   FROM dual;
  insert into mti_test_table VALUES ('done');
  commit;
  dbms_output.put_line ('DONE');
END;
/
