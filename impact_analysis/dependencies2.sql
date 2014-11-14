select referenced_name changed_object
      ,referenced_owner changed_object_owner
      ,referenced_type  changed_object_type
      ,owner impacted_object_owner
      ,name impacted_object
      ,type impacted_object_type
      ,dependency_type
      ,referenced_link_name
  from dba_dependencies
  WHERE referenced_owner NOT IN ('SYS', 'SYSTEM')
    --AND referenced_name = 'BILL_ACCT'
    --AND referenced_name = 'PXML_MESSAGE'
    AND referenced_link_name is not null 
    AND referenced_type = 'PACKAGE'
    AND referenced_name = 'ERS_CUSTOMER'
  ORDER BY changed_object
    ;

select *
  from dba_dependencies
  WHERE referenced_owner NOT IN ('SYS', 'SYSTEM')
    --AND referenced_name = 'PXML_MESSAGE'
    AND referenced_link_name is not null
    --AND referenced_name = 'PCPM_SETTLEMENT_SUPPORT'