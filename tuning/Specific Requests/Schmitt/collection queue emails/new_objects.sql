set serveroutput on size 1000000

drop type collections_queue_email_list;
drop type collection_queue_email;

create or replace type collection_queue_email as object 
     (ky_enroll      NUMBER(10)
     ,ky_supplier    VARCHAR2(100)
     ,email_address  VARCHAR2(500)
     ,days_overdue   NUMBER
     ,template_name  VARCHAR2(500)
     )
/ 
show errors

-- create the nested table
create or replace type collections_queue_email_list as table of collection_queue_email
/
show errors