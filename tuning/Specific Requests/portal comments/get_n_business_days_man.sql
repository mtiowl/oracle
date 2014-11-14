set serveroutput on size 1000000
spool get_n_business_days_man.out

DECLARE  --get_n_business_days 
        p_date                  DATE := to_date('31-DEC-9999', 'DD-MON-YYYY');
        p_how_many_days         NUMBER := 3;
        p_direction             CHAR := 'F';
        
    	retDate 	DATE := TRUNC(p_date);
    	countMet	NUMBER := 0;
    	dayNumber	NUMBER;
      i         NUMBER := 0;
    
    	FUNCTION IsAHoliday(inDate IN DATE) RETURN BOOLEAN
    	IS
    		tmpCount	NUMBER;
    	BEGIN
    		SELECT
    			COUNT(*)
    		INTO
    			tmpCount
    		FROM 
    			custpro.mkt_tou_hol_daytype
    		WHERE
    			TO_CHAR(DT_HOLIDAY,'MMDDYYYY') = TO_CHAR(inDate,'MMDDYYYY');
    		
    		IF tmpCount > 0 THEN
    			RETURN TRUE;
    		ELSE
    			RETURN FALSE;
    		END IF;
    	END IsAHoliday;
    
    BEGIN
    	
      dbms_output.put_line ('p_date: '||to_char(p_date, 'DD-MON-YYYY'));
    	<<BusinessDayLoop>>
    	LOOP
    	--FOR i IN 1..6 LOOP
        i := i + 1;
        dbms_output.put_line ('<<<<<<  LOOP #  '||i||'   >>>>>>');
    		dayNumber := TO_NUMBER(TO_CHAR(retDate,'D'));
        dbms_output.put_line ('dayNumber: '||dayNumber);
    
    		IF (dayNumber = 1) OR (dayNumber = 7) THEN
    			-- If a Saturday or Sunday keep going
          dbms_output.put_line ('Weekend');
    			--NULL;
    		ELSIF IsAHoliday(retDate) THEN
    			-- If it's a holiday keep going
    			dbms_output.put_line ('holiday');
          --NULL;
    		ELSE	
    			-- Looks like it's ok.  Increment the day counter
    			countMet := countMet + 1;
    			
	    		-- If countMet equals the number of business days ago requested, we've 
        		-- met that number of legitimate days.
        		-- Hence, we're at least "n" business days in the future
        		IF countMet > p_how_many_days THEN
              dbms_output.put_line ('DONE!!!!!!');
        			EXIT BusinessDayLoop;
              
        		END IF;

    		END IF;
    		
    		IF p_direction = 'F' THEN
        		IF retDate < TO_DATE('9999-12-31','YYYY-MM-DD') THEN
        		  retDate := retdate + 1;
   		       ELSE
                dbms_output.put_line ('retDate is >= 9999-12-31...not incrementing retDate');
   		          retDate := retDate + 0;
   		       END IF;
    		
        ELSIF p_direction = 'B' THEN
        		retDate := retdate-1;
    		ELSE
                RAISE_APPLICATION_ERROR(
                    -20099,
                    'Direction not expected.');
    		END IF;
      
      dbms_output.put_line('dayNumber: '||dayNumber);
      dbms_output.put_line('countMet: '||countMet);
      dbms_output.put_line('retDate: '||to_char(retDate, 'DD-MON-YYYY'));
      dbms_output.put_line('...');
      dbms_output.put_line('...');
      dbms_output.put_line('...');
      dbms_output.put_line('...');
    	END LOOP;
    	
    	--RETURN retDate;
    
    END;   --get_n_business_days
/
spool off