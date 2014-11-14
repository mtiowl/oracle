set serveroutput on size 1000000

DECLARE

  CURSOR get_pkg IS
  SELECT DISTINCT object_name, pls_type
    FROM all_arguments
    WHERE package_name = upper('api_prospect');

  CURSOR get_args (p_object_name VARCHAR2) IS
    SELECT argument_name, data_type, in_out, default_value
      FROM all_arguments
      WHERE object_name = p_object_name;
    
BEGIN

  FOR prec IN get_pkg LOOP
  
     dbms_output.put_line (prec.object_name||'  '||prec.pls_type);
     dbms_output.put_line ('------------------------------------------------');
  
     FOR arec IN get_args (prec.object_name) LOOP
     
        dbms_output.put_line ('   '||RPAD(arec.argument_name, 30)|| RPAD(arec.data_type, 15)|| RPAD(arec.in_out, 10)|| RPAD(substr(arec.default_value,1, 50), 50) );
     
     END LOOP;
     
  END LOOP;


END;
/