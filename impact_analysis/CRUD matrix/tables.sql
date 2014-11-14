CREATE TABLE db_crud(  
    table_owner VARCHAR2(30),  
    table_name VARCHAR2(30),  
    object_owner VARCHAR2(30),  
    object_name VARCHAR2(128),  
    object_type VARCHAR2(20),  
    create_flag VARCHAR2(1),  
    read_flag VARCHAR2(1),  
    update_flag VARCHAR2(1),  
    delete_flag VARCHAR2(1))  
/  

GRANT SELECT ON db_crud TO PUBLIC 
/  


CREATE TABLE crud_run_log (  
    last_run_date DATE)  
/ 
