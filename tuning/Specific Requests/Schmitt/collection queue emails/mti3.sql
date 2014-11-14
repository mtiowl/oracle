set serveroutput on size 1000000

DECLARE

  CURSOR get_collections_queue IS
    SELECT cust.ky_enroll
          ,cust.ky_supplier
          ,cust.tx_email
          ,a.qy_days_overdue
          ,CASE
              WHEN a.qy_days_overdue BETWEEN 3 AND 9 THEN
                  CASE       -- Only some markets will send out collections after 3 days
                     WHEN a.ky_utility_name IN ('SOCAL', 'SDGE') THEN 'Collections3'
                     ELSE 'NONE'
                     END
              WHEN a.qy_days_overdue BETWEEN 10 AND 19 THEN 'Collections10'
              WHEN a.qy_days_overdue >= 20 THEN 'Collections20'
              ELSE 'NONE'
            END TEMPLATE
     FROM cis_collections_queue a
         ,account cust
     WHERE a.ky_supplier = 'XOOM'
       AND a.ky_enroll = cust.ky_enroll
       AND a.ky_supplier = cust.ky_supplier
       AND a.cd_queue_status <> 'DN'
	     and a.ky_utility_name in ('PGE',
					'SOCAL',
					'SDGE',
					'CPL',
					'WTU',
					'CPE',
					'ONCOR',
					'TNMP',
					'NICOR',
					'COMED',
					'NORTHSHORE',
					'PEOPLES',
					'MECO',
					'NANT',
					'BOSTED',
					'CAMB',
					'COMCAMB',
					'WMECO');


  l_collections_queue_list collections_queue_email_list;
  l_sent_email_list        collections_queue_email_list;
  l_temp_kyvalue           email_list.kyvalue%type;
  
  TYPE myarray IS TABLE OF get_collections_queue%ROWTYPE;
  cur_array myarray;
  
  i         NUMBER;
  l_start   DATE;
  l_step_1  DATE;
  l_step_2  DATE;
  l_step_3  DATE;

BEGIN

    l_start := sysdate;
    -- ************************************************************************
    --   Step #1 - Get a list of email addresses that need a collections email
    -- ************************************************************************
    l_collections_queue_list  := collections_queue_email_list();
    OPEN get_collections_queue;
    i := 1;
    FETCH get_collections_queue BULK COLLECT INTO cur_array;
    dbms_output.put_line ('temp array collected '||cur_array.count||' records');
    
    -- Copying to an array that is delcared in the database
    -- This will allow us to do a SELECT...MINUS (step #3)
    FOR i IN 1..cur_array.count LOOP
       l_collections_queue_list.extend;
       l_collections_queue_list(l_collections_queue_list.count) := collection_queue_email(cur_array(i).ky_enroll 
                                                                                         ,cur_array(i).ky_supplier
                                                                                         ,cur_array(i).tx_email
                                                                                         ,cur_array(i).qy_days_overdue
                                                                                         ,cur_array(i).template);
    END LOOP;
    CLOSE get_collections_queue;
    
    dbms_output.put_line ('collected '||l_collections_queue_list.count||' records');
    l_step_1 := sysdate;

    -- ************************************************************************************
    --   Step #2 - Get a list of email addresses that already had a collections email sent
    --             In other words, it's not time to send another....yet.
    -- ************************************************************************************
    l_sent_email_list := collections_queue_email_list();
    SELECT collection_queue_email (el.kyvalue, el.supplier, el.recipient, 0, el.templatename)
       BULK COLLECT INTO l_sent_email_list
       FROM email_list el
           ,TABLE ( CAST (l_collections_queue_list As collections_queue_email_list )) cq
       WHERE (el.addedon is null OR el.addedon <= SYSDATE - cq.days_overdue)
         AND el.kyvalue = cq.ky_enroll
         AND el.supplier = cq.ky_supplier
         AND el.templatename = cq.template_name;
            
    dbms_output.put_line ('already sent '||l_sent_email_list.count||' records');
    
    l_step_2 := sysdate;
    
    -- ****************************************************************************
    --       Step #3 - Filter out the email addresses that we don't want to send
    -- ****************************************************************************
    i := 0;
    FOR r IN (SELECT cq.ky_enroll
                    ,cq.ky_supplier
                    ,cq.email_address
                    ,cq.template_name
                FROM TABLE ( CAST (l_collections_queue_list As collections_queue_email_list )) cq
              MINUS
              SELECT sl.ky_enroll
                    ,sl.ky_supplier
                    ,sl.email_address
                    ,sl.template_name
                FROM TABLE ( CAST (l_sent_email_list As collections_queue_email_list )) sl ) LOOP
                
                
       i := i + 1;
    END LOOP;
    
    dbms_output.put_line ('Need to send '||i||' records');
    l_step_3 := sysdate;
    
    dbms_output.put_line ('.');
    dbms_output.put_line ('Peformance Metrics');
    dbms_output.put_line ('-------------------');
    dbms_output.put_line ('Step #1: '||to_char(l_step_1 - l_start));
    dbms_output.put_line ('Step #1: '||to_char(l_step_2 - l_step_1));
    dbms_output.put_line ('Step #1: '||to_char(l_step_3 - l_step_2));
    
END;
/