SELECT name, type, referenced_owner, referenced_link_name, dependency_type
  FROM user_dependencies
  WHERE referenced_name = '&table_name'
/

SELECT name, line, text, type
  FROM all_source
  WHERE upper(text) LIKE upper('%&package_name%')
    AND RTRIM(LTRIM(upper(text))) NOT LIKE '%PACKAGE '||upper('&package_name')||'%'
    AND RTRIM(LTRIM(upper(text))) NOT LIKE '%PACKAGE BODY '||upper('&package_name')||'%'
    AND RTRIM(LTRIM(upper(text))) NOT LIKE '%END '||upper('&package_name')||'%'
/
