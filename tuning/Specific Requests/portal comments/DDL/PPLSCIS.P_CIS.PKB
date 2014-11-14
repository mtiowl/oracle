CREATE OR REPLACE PACKAGE BODY P_CIS IS

    FUNCTION get_n_business_days (
        p_date                      IN      DATE, 
        p_how_many_days             IN      NUMBER,
        p_direction                 IN      CHAR) RETURN DATE
    IS
    
    	retDate 	DATE := TRUNC(p_date);
    	countMet	NUMBER := 0;
    	dayNumber	NUMBER;

    
    	FUNCTION IsAHoliday(inDate IN DATE) RETURN BOOLEAN  	IS
    		
            tmpCount	NUMBER;
            
    	BEGIN
      
    		SELECT COUNT(*)
    		  INTO tmpCount
    		  FROM custpro.mkt_tou_hol_daytype
    		  WHERE TO_CHAR(DT_HOLIDAY,'MMDDYYYY') = TO_CHAR(inDate,'MMDDYYYY');
    		
    		IF tmpCount > 0 THEN
    			RETURN TRUE;
    		ELSE
    			RETURN FALSE;
    		END IF;
        
    	END IsAHoliday;

    -- **********************************************************************
    --               Start of get_n_business_days
    -- **********************************************************************
    BEGIN
    	
    	IF TRUNC(p_date) <> TRUNC(to_date('31-DEC-9999', 'DD-MON-YYYY')) THEN
      
         <<BusinessDayLoop>>
       	 LOOP
     	
    		     dayNumber := TO_NUMBER(TO_CHAR(retDate,'D'));
    
    		     IF (dayNumber = 1) OR (dayNumber = 7) THEN
    			        -- If a Saturday or Sunday keep going
    			        NULL;
    		     ELSIF IsAHoliday(retDate) THEN
    			        -- If it's a holiday keep going
    		    	    NULL;
    		     ELSE	
    			       -- Looks like it's ok.  Increment the day counter
    			       countMet := countMet + 1;
    			
	    		       -- If countMet equals the number of business days ago requested, we've 
        		     -- met that number of legitimate days.
        		     -- Hence, we're at least "n" business days in the future
        		     IF countMet > p_how_many_days THEN
        			      EXIT BusinessDayLoop;
        		     END IF;

    		     END IF;  /* IF (dayNumber = 1) .... */


    		     IF p_direction = 'F' THEN
                    retDate := retdate + 1;
    		     ELSIF p_direction = 'B' THEN
        		        retDate := retdate-1;
    		     ELSE
                   RAISE_APPLICATION_ERROR(-20099,'Direction not expected.');
    		     END IF;
    		    		
    	    END LOOP BusinessDayLoop;
          
      ELSE /* p_date = 31-DEC-9999 */
         --  Since p_date is 31-EC-9999, then return 31-DEC-9999
         retDate := p_date;
         
      END IF;
    	
    	RETURN retDate;
    
    END get_n_business_days;

    FUNCTION get_n_business_days_ago (
        p_date                      IN      DATE, 
        p_how_many_days_ago         IN      NUMBER) RETURN DATE
    IS
    BEGIN
    
        RETURN get_n_business_days (
            p_date,
            p_how_many_days_ago,
            'B');
    
    END get_n_business_days_ago;

    FUNCTION get_n_business_days_ahead (
        p_date                      IN      DATE, 
        p_how_many_days_ahead       IN      NUMBER) RETURN DATE
    IS
    BEGIN
    	
    	RETURN get_n_business_days (
            p_date,
            p_how_many_days_ahead,
            'F');
    
    END get_n_business_days_ahead;
    
    PROCEDURE dotnet_get_allowed_supp_IDs (
        p_id_user_guid              IN      CHAR,
        p_allowed_supplierIDs           OUT SYS_REFCURSOR)
    IS

        allowedSuppliedList         VARCHAR2_ARRAY;
    
    BEGIN
    
        -- Retrieve the list of allowed suppliers
        allowedSuppliedList := retrieve_allowed_supplier_IDs (
            p_id_user_guid );
        
        -- Open the cursor for the contents of the return item
        OPEN
            p_allowed_supplierIDs
        FOR
            SELECT 
                COLUMN_VALUE SupplierName
            FROM
                TABLE(CAST(allowedSuppliedList AS VARCHAR2_ARRAY));
            
    END dotnet_get_allowed_supp_IDs;

    FUNCTION retrieve_allowed_supplier_IDs (
        p_id_user_guid              IN      CHAR)
    RETURN VARCHAR2_ARRAY
    IS
        allowedSuppliedList         VARCHAR2_ARRAY;
        foundBool                   BOOLEAN;
        cupRow                      CIS_USER_PROFILE%ROWTYPE;
        allowedClientNumbers        NUMBER_VARRAY;
        arrayIndex                  NUMBER := 1;
    BEGIN
    
        -- See if user has a client / supplier group
        P_CIS_USER_PROFILE.get_attribute_row(
            p_id_user_guid,USER_CLIENT_GROUP,foundBool,cupRow);
            
        -- If there is a UserClientGroup attribute, correlate it to the 
        -- CIS_SUPPLIER_GROUP table
        IF foundBool AND (LENGTH(TRIM(cupRow.TX_ITEM_VALUE)) > 0)  THEN             
        
            SELECT
                ARR_SUPPLIER_NO
            INTO
                allowedClientNumbers
            FROM
                CIS_SUPPLIER_GROUP
            WHERE
                ID_SUPPLIER_GROUP = cupRow.TX_ITEM_VALUE;
            
        -- If there IS no UserClientGroup attribute, default to the 
        -- UserClientNumber instead
        ELSE
        
            -- Look for the UserClientNumber
            P_CIS_USER_PROFILE.get_attribute_row(
                p_id_user_guid,USER_CLIENT_NUMBER,foundBool,cupRow);
                
            -- If the number could not be found, fail here
            IF NOT foundBool THEN
                RAISE_APPLICATION_ERROR(-20099,
                    'Could not find attribute '||USER_CLIENT_NUMBER||
                    ' for user '||p_id_user_guid||'.',FALSE);
            END IF;
            
            -- Set the allowed suppliers as the only one available
            allowedClientNumbers := NUMBER_VARRAY(TO_NUMBER(cupRow.TX_ITEM_VALUE));
            --DBMS_OUTPUT.put_line('Added :'||TO_NUMBER(cupRow.TX_ITEM_VALUE));
        
        END IF;
        
        -- DBMS_OUTPUT.put_line(allowedClientNumbers.COUNT);
        
        -- Retrieve the list of allowed suppliers
        SELECT 
            KY_SUPPLIER_ID
        BULK COLLECT INTO 
            allowedSuppliedList
        FROM
            CIS_SUPPLIER CS
        WHERE 
            CS.KY_SUPPLIER_NO IN --TABLE(CAST(allowedClientNumbers));
            (SELECT 
                *
             FROM
                TABLE(CAST(allowedClientNumbers AS NUMBER_VARRAY))
             );
                          
        -- Return the list
        RETURN allowedSuppliedList;
        
    END;
        
    FUNCTION get_database_instance
    RETURN VARCHAR2
    IS
        l_global_name       global_name.global_name%TYPE;
        l_dot_pos           NUMBER;
    BEGIN
    
        -- Retrieve global instance name
        SELECT global_name 
        INTO l_global_name 
        FROM global_name;

        -- Parse out DB instance name
        l_dot_pos := INSTR(l_global_name, '.');
        RETURN SUBSTR(l_global_name, 1, l_dot_pos-1);
    
    END;
    
    FUNCTION get_host_name
    RETURN VARCHAR2
    IS
        l_db_instance       VARCHAR2(100);
    BEGIN

        -- Retrieve database instance
        l_db_instance := get_database_instance;
        
        -- Determine which environment this is
        IF (l_db_instance = 'PSOLP') THEN
            RETURN PROD_HOST;
        ELSIF ((l_db_instance = 'PSOLD') OR 
               (l_db_instance = 'PSOLT')) THEN
            RETURN TEST_HOST;
        ELSE
            RAISE_APPLICATION_ERROR(-20099,
                'Database name '||l_db_instance||' not expected in this routine.');
        END IF;
    END;

    PROCEDURE get_user_supplier (
        p_id_user_guid          IN      VARCHAR2,
        p_supplier_number           OUT NUMBER,
        p_supplier_id               OUT VARCHAR2)
    IS
        tmpBool     BOOLEAN;
        attrRow     CIS_USER_PROFILE%ROWTYPE;
    BEGIN
    
        -- Get the attribute row for the requested user GUID
        P_CIS_USER_PROFILE.GET_ATTRIBUTE_ROW(
            p_id_user_guid,
            USER_CLIENT_NUMBER,
            tmpBool,
            attrRow);
            
        -- Test for success
        IF tmpBool = FALSE THEN
            RAISE_APPLICATION_ERROR(-20099,'Could not find attribute '||USER_CLIENT_NUMBER||
                                           ' for user '||p_id_user_guid||'.',FALSE);
        END IF;
        
        -- Convert the text equivalent of the value to a number
        p_supplier_number := TO_NUMBER(attrRow.TX_ITEM_VALUE);

        -- Identify which supplier the user is permitted to see
        -- If supplier ID is '0', the user is permitted to see ALL suppliers
        IF p_supplier_number = 0 THEN
            p_supplier_id := 'ALL';
        ELSE
            BEGIN
                -- Retrieve the client name from the CIS_SUPPLIER table
                SELECT KY_SUPPLIER_ID
                INTO p_supplier_id
                FROM CIS_SUPPLIER
                WHERE KY_SUPPLIER_NO = p_supplier_number;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20099,'No record on CIS supplier table for client number '||
                                            p_supplier_number||'.',TRUE);
            END;
        END IF;
    
    END;
    
    FUNCTION get_message_text (
        p_ky_application        IN      CIS_MESSAGES.KY_APPLICATION%TYPE,
        p_cd_message_type       IN      CIS_MESSAGES.CD_MESSAGE_TYPE%TYPE,
        p_ky_message            IN      CIS_MESSAGES.KY_MESSAGE%TYPE)
    RETURN VARCHAR2
    IS
        returnValue         CIS_MESSAGES.TX_MESSAGE%TYPE;
    BEGIN
        SELECT
            CM.TX_MESSAGE
        INTO
            returnValue
        FROM
            CIS_MESSAGES CM
        WHERE
            CM.ky_application = p_ky_application AND
            CM.cd_message_type = p_cd_message_type AND
            CM.ky_message = p_ky_message;
            
        RETURN returnValue;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            -- Log error message - message requested cannot be found
            P_API_CIS_ERRORS.log_local_error(
                'E','N/A',
                'P_CIS.get_message_text',
                'Unable to find message text for ky_application '||p_ky_application||
                ', cd_message_type '||p_cd_message_type||', ky_message '||p_ky_message);
                
            -- If seeking an exception message, return general exception message
            IF p_cd_message_type = 'E' THEN
                RETURN GENERAL_EX_MESSAGE;
            ELSE
                RETURN EMPTY_INFO_MESSAGE;
            END IF;
            
    END;
    
    FUNCTION does_user_have_access (
        p_id_user_guid          IN      CHAR,
        p_ky_enroll             IN      NUMBER)
        RETURN BOOLEAN
    IS
        acctSupplier            ACCOUNT.KY_SUPPLIER%TYPE;
        allowedSuppliers        VARCHAR2_ARRAY;
        
        acctRec                 ACCOUNT%ROWTYPE;
        
        FUNCTION TestForSupplier(p_supplier_id      IN      VARCHAR2)
        RETURN BOOLEAN
        IS
        BEGIN
            IF allowedSuppliers IS NOT NULL THEN
                IF allowedSuppliers.COUNT > 0 THEN
                    FOR i IN allowedSuppliers.FIRST..allowedSuppliers.LAST
                    LOOP
                        IF allowedSuppliers.EXISTS(i) THEN
                            IF allowedSuppliers(i) = p_supplier_id THEN
                                RETURN TRUE;
                            END IF;
                        END IF;
                    END LOOP;
                END IF;
            END IF;
            
            RETURN FALSE;
            
        END;
        
    BEGIN
    
        -- Retrieve the list of suppliers this user has access to
        allowedSuppliers := retrieve_allowed_supplier_IDs(p_id_user_guid);
        
        -- If PPLS found, return true
        IF TestForSupplier('PPLS') THEN
            RETURN TRUE;
        END IF;
        
        -- Look to see if the account can be found, using the list of a user's
        -- accessible suppliers are part of the criteria.
        BEGIN
            SELECT
                *
            INTO
                acctRec
            FROM
                ACCOUNT
            WHERE
                KY_ENROLL = p_ky_enroll AND
                KY_SUPPLIER IN 
                (SELECT 
                    *
                 FROM
                    TABLE(CAST(allowedSuppliers AS VARCHAR2_ARRAY))
                );
    
            IF acctRec.KY_ENROLL IS NOT NULL THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
        END;
        
    END;
    
    PROCEDURE get_portal_decodes (
        p_ky_supplier           IN      PVIEW.CODE.KY_SUPPLIER%TYPE,
        p_ky_table              IN      PVIEW.CODE.KY_TABLE%TYPE,
        p_decodes                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN
            p_decodes
        FOR
            SELECT
                KY_CODE, TX_DECODE
            FROM
                PVIEW.CODE
            WHERE
                KY_SUPPLIER = p_ky_supplier AND
                KY_TABLE = p_ky_table;
    END;
    
    PROCEDURE get_any_portal_decodes (
        p_ky_table              IN      PVIEW.CODE.KY_TABLE%TYPE,
        p_decodes                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN
            p_decodes
        FOR
            SELECT
                KY_CODE, KY_SUPPLIER, TX_DECODE
            FROM
                PVIEW.CODE
            WHERE
                KY_TABLE = p_ky_table;
    END; 
    
    PROCEDURE get_all_supplier_state_utility (
        p_supplier_state_utils          OUT  SYS_REFCURSOR)
    IS
    BEGIN
    
        PVIEW.P_CIS_COMMON_PVIEW.get_all_supplier_state_utility
            (p_supplier_state_utils);            
    
    END get_all_supplier_state_utility;
    
    PROCEDURE get_supplier_email_suffixes (
        p_supplier_email_suffixes   OUT SYS_REFCURSOR)
    IS
    BEGIN
    
        OPEN
            p_supplier_email_suffixes FOR
        SELECT 
            SUPP_NUMS.COLUMN_VALUE "KY_SUPPLIER_NO",
            SUFF.TX_EXPECTED_EMAIL_SUFFIXES
        FROM 
            cis_supplier_email_suffixes suff, 
            TABLE(suff.ARR_SUPPLIER_NO) SUPP_NUMS;
    END;    
    
    PROCEDURE get_suppliers_groups_suffixes (
        p_supplier_list             OUT SYS_REFCURSOR,
        p_supplier_email_suffixes   OUT SYS_REFCURSOR,
        p_client_groups             OUT CLOB)
    IS
    BEGIN
        
        get_portal_supplier_list(p_supplier_list);
        
        get_supplier_email_suffixes(p_supplier_email_suffixes);
                    
        SELECT
            XMLTYPE.getclobval
            (
                XMLELEMENT
                (
                    "Groups",
                    XMLAGG
                    (
                        XMLELEMENT
                        (
                            "Group",
                            XMLAttributes
                            (
                                ID_SUPPLIER_GROUP AS "GroupID",
                                TX_SUPPLIER_GROUP_DESC AS "Description"
                            ),
                            XMLForest
                            (
                                ARR_SUPPLIER_NO AS "SupplierNumbers"
                            )
                        )
                    )
                )
            )
        INTO
            p_client_groups                       
        FROM
            CIS_SUPPLIER_GROUP;
        
    END;
    
    --////////////////////////////////////////////////////////////////////////////////////////
    
    PROCEDURE get_supplier_dtl_ctp (p_supplier_detail OUT SYS_REFCURSOR)
    IS
      l_ctp_record              CTP_DUNS_CONVERTER%ROWTYPE;
      l_cursor                  SYS_REFCURSOR;
      l_record                  SUPPLIER_DETAIL_REC_2;
      l_current_record          SUPPLIER_DETAIL_REC_2;
      l_temp                    SUPPLIER_DETAIL_REC_2;
      l_table                   SUPPLIER_DETAILS_TABLE_2;
      l_count                   NUMBER := 0;
      l_record_duns             VARCHAR2(13);
      l_arg                     VARCHAR2(13);
      l_idx                     NUMBER;
      l_comma_delimited_duns    VARCHAR2(4000);
      l_cursor_table SUPPLIER_DETAIL_TABLE_1;
      l_cursor_record SUPPLIER_DETAIL_REC_1;
      
      CURSOR l_duns_cursor IS SELECT distinct A.cd_external_egs_duns
      FROM CTP_DUNS_CONVERTER A
      where A.cd_internal_egs_duns = l_record_duns;

    BEGIN
      
        -- Initialize our supplier details cursor to the record set in PVIEW. 
        PVIEW.P_CIS_COMMON_PVIEW.get_supplier_detail(l_cursor);
        
        -- Call constructor for our externally accessible table.
        l_cursor_table := SUPPLIER_DETAIL_TABLE_1(); 
        
        -- Collect all the data from the SUPPLIER_DETAILS table in PVIEW. Our intent is to supplement
        -- the data with an additional column with comma delimited equivalent external duns numbers.
        
        LOOP
           FETCH l_cursor INTO l_record;
           EXIT WHEN l_cursor%NOTFOUND;
           l_table(l_count) := l_record; -- Insert the record into the table.
           l_count := l_count + 1;
       END LOOP;
       
       CLOSE l_cursor;
     
       l_idx := l_table.FIRST;  -- Get the first row index.
       
       << display_loop >>
       WHILE l_idx IS NOT NULL LOOP
       
             -- Get the record for the current index in play.
             l_current_record := l_table(l_idx);
             
             -- Get the duns number needed by the cursor.
             l_record_duns := l_current_record.TX_DUNS_NUM_PLUS4;
             
             OPEN l_duns_cursor;
             
             l_comma_delimited_duns := ''; -- reset
             
             LOOP
                FETCH l_duns_cursor INTO l_arg;
                EXIT WHEN l_duns_cursor%NOTFOUND;
                
                -- With each pass, build up the comma delimited external duns numbers we found for the
                -- internal duns in play. 
                l_comma_delimited_duns := l_comma_delimited_duns || l_arg || ',';
                
             END LOOP;
             
             l_comma_delimited_duns := rTrim(l_comma_delimited_duns, ','); -- trim the trailing comma.
             dbms_output.put_line(l_current_record.TX_DUNS_NUM_PLUS4 || ' -> ' || l_comma_delimited_duns);
             
             CLOSE l_duns_cursor;
         
             -- Transfer the data into a externally accessible record type.
             l_cursor_record := SUPPLIER_DETAIL_REC_1 (
                                                        l_current_record.KY_SUPPLIER_ID,
                                                        l_current_record.CD_STATE,
                                                        l_current_record.CD_SERVICE,
                                                        l_current_record.CD_DUNS_GRP,
                                                        l_current_record.TX_SUPPLIER_DETAIL_DESC,
                                                        l_current_record.TX_CSS_SUP_DESC,
                                                        l_current_record.TX_DUNS_NUM_PLUS4,
                                                        l_current_record.TX_LICENSE_NUMBER,
                                                        l_current_record.TX_FEDERAL_TAX_ID,
                                                        l_current_record.TX_SUP_INTRNT_ADDR,
                                                        l_current_record.TX_SUP_EMAIL_ADDR,
                                                        l_current_record.TX_CC_INTRNT_ADDR,
                                                        l_current_record.TX_CC_EMAIL_ADDR,
                                                        l_current_record.TX_REMIT_TO_ADDR1,
                                                        l_current_record.TX_REMIT_TO_ADDR2,
                                                        l_current_record.TX_REMIT_TO_ADDR3,
                                                        l_current_record.TX_REMIT_TO_ZIP,
                                                        l_current_record.TX_SUPPLIER_MARKET_LOGO,
                                                        l_comma_delimited_duns                                     
                                        );
            -- Add the externally accessible ecord to the externally accessible (via ref cursor) table. 
            l_cursor_table.Extend;
            l_cursor_table(l_cursor_table.LAST) := l_cursor_record;
            
            -- Move on to the next supplier row by getting the next index value. 
            l_idx := l_table.NEXT(l_idx);
            
       END LOOP display_loop;
       
      -- Our data is now all in a table that is accessible via a reference cursor (for .NET). Assign our
      -- reference cursor argument to that table.
      
      open p_supplier_detail for select * from TABLE (CAST(l_cursor_table as SUPPLIER_DETAIL_TABLE_1));
      
    END;
        
   --//////////////////////////////////////////////////////////////////////////////////////////
        
    PROCEDURE get_supplier_detail (
        p_supplier_detail               OUT SYS_REFCURSOR)
    IS
    BEGIN
    
        PVIEW.P_CIS_COMMON_PVIEW.get_supplier_detail
            (p_supplier_detail);
    
    END get_supplier_detail;
    
    --/////////////////////////////////////////////////////////////////////////////////////////////
    
    procedure get_security_duns_list(p_cur out SYS_REFCURSOR)
    IS
    BEGIN
        PVIEW.P_CIS_COMMON_PVIEW.get_security_duns_list(p_cur);
    END get_security_duns_list;
   
    --/////////////////////////////////////////////////////////////////////////////////////////////
    
    PROCEDURE get_utility_detail (
        p_utility_detail                OUT SYS_REFCURSOR)
    IS
    BEGIN
    
        OPEN 
            p_utility_detail
        FOR
            SELECT
                CODE,
                DECODE,
                DUNS_NUM,
                STATE
            FROM
                ER_EDC_NAME;
    
    END get_utility_detail;

    PROCEDURE get_portal_supplier_list (
        p_supplier_list            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN 
            p_supplier_list
        FOR
            SELECT 
                a.ky_supplier_no, 
                a.ky_supplier_id, 
                a.tx_supplier_description      
        FROM 
            cis_supplier a 
        ORDER BY 
            a.ky_supplier_no;    
    END;
    
    FUNCTION get_user_guid (
        p_user_name         IN      VARCHAR2)
    RETURN CHAR
    IS
        userGuid            CHAR(36);
    BEGIN
    
        -- Look first for the user GUID; if not found, use the system GUID
        
        BEGIN
            SELECT
                ID_USER_GUID
            INTO
                userGuid
            FROM
                CIS_USER_XREF
            WHERE
                UPPER(ID_USER_ID) = UPPER(p_user_name);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT
                    ID_USER_GUID
                INTO
                    userGuid
                FROM
                    CIS_USER_XREF
                WHERE
                    UPPER(ID_USER_ID) = 'SYSTEM';
        END;
        
        RETURN userGuid;
    
    END;
    
    PROCEDURE get_supplier_info (
        p_supplier_id       IN  OUT VARCHAR2,
        p_supplier_no       IN  OUT NUMBER)
    IS
    BEGIN
    
        IF p_supplier_id IS NOT NULL THEN
        
            SELECT 
                KY_SUPPLIER_NO 
            INTO 
                p_supplier_no 
            FROM 
                CIS_SUPPLIER 
            WHERE 
                KY_SUPPLIER_ID = p_supplier_id;
                
        ELSIF p_supplier_no IS NOT NULL THEN
        
            SELECT 
                KY_SUPPLIER_ID 
            INTO 
                p_supplier_id 
            FROM 
                CIS_SUPPLIER 
            WHERE 
                KY_SUPPLIER_NO = p_supplier_no;
                
        END IF;
    
    EXCEPTION
       WHEN OTHERS THEN
          dbms_output.put_line ('ERROR: p_supplier_id = '||p_supplier_id);
          raise;
    END get_supplier_info;
    
    PROCEDURE get_sales_person_list (
        p_id_user_guid              IN      CHAR,
        p_sales_person_list             OUT SYS_REFCURSOR)
    IS
    
        allowedSuppliedList         VARCHAR2_ARRAY;
    
    BEGIN
    
        -- Retrieve the list of allowed suppliers
        allowedSuppliedList := retrieve_allowed_supplier_IDs (
            p_id_user_guid );
            
        -- Get all available sales persons for this user, based on what
        -- suppliers they are allowed to see
        PVIEW.P_CIS_CUSTOMER_INFO.get_sales_person_list_ms(
            allowedSuppliedList,
            p_sales_person_list);
    
    END;
    
    PROCEDURE get_supplier_ftp_folder (
        p_supplier_no               IN      NUMBER,
        p_supplier_name             IN      VARCHAR2,
        p_ftp_folder                    OUT VARCHAR2)
    IS
        l_supplier_no               CIS_SUPPLIER.KY_SUPPLIER_NO%TYPE;
        l_supplier_name             CIS_SUPPLIER.KY_SUPPLIER_ID%TYPE;
    BEGIN
    
        l_supplier_no := p_supplier_no;
        l_supplier_name := p_supplier_name;
    
        -- Correlate the supplier name or ID, depending on what was provided
        get_supplier_info(l_supplier_name,l_supplier_no);
    
        SELECT
            TX_FTP_FOLDER_ROOT
        INTO
            p_ftp_folder
        FROM
            CIS_SUPPLIER_CONFIG
        WHERE
            KY_SUPPLIER_NO = l_supplier_no;
    
    END get_supplier_ftp_folder;

	PROCEDURE get_PPLSCIS_files_2b_Purged
    (
			p_cur           OUT SYS_REFCURSOR,
			p_error_code    OUT NUMBER
   	)
	IS
	BEGIN
		OPEN p_cur FOR

		SELECT DISTINCT CIS_SA_FILE.*, CIS_SA_CATEGORY.tx_directory
		   FROM CIS_SA_FILE, CIS_SA_CATEGORY, PFTP.FTP_PURGE c, CIS_SUPPLIER
		  WHERE CIS_SA_CATEGORY.id_sa_category = CIS_SA_FILE.id_sa_category
			AND CIS_SA_CATEGORY.ky_category_code = c.ky_category
			AND TRUNC(CIS_SA_FILE.ts_added) + c.QY_PURGE_AFTER_DAYS < TRUNC(SYSDATE)
			AND CIS_SUPPLIER.ky_supplier_no <> 99 --DEMO supplier no
			AND CIS_SA_FILE.FL_ALLOW_DELETE = 'Y'
			AND c.FL_REGISTERED = 'Y'
			AND CIS_SUPPLIER.ky_supplier_id = c.ky_supplier
			AND CIS_SA_FILE.ky_supplier_no  = CIS_SUPPLIER.ky_supplier_no 
			
		UNION
		
        SELECT CIS_SA_FILE.*, CIS_SA_CATEGORY.tx_directory
          FROM CIS_SA_FILE, CIS_SA_CATEGORY, CIS_SUPPLIER
         WHERE trunc(CIS_SA_FILE.ts_added) + 7 < trunc(SYSDATE)
		   AND CIS_SUPPLIER.ky_supplier_no <> 99 --DEMO supplier no
		   AND CIS_SA_FILE.FL_ALLOW_DELETE = 'Y'
           AND CIS_SA_CATEGORY.ky_category_code = 'MISCELLANEOUS'
           AND UPPER(CIS_SA_FILE.TX_DESCRIPTION) IN  ('ACCESS DB','PORTAL_CLIENT_FILES')
           AND CIS_SA_CATEGORY.id_sa_category = CIS_SA_FILE.id_sa_category

	   ORDER BY 2;

	 p_error_code := SQLCODE;
	EXCEPTION
		WHEN OTHERS THEN
			p_error_code := SQLCODE;
			
	END get_PPLSCIS_files_2b_Purged;

    
    PROCEDURE get_list_of_users_for_reports
    (
        p_cur           OUT SYS_REFCURSOR
    )
    IS
    BEGIN
    
		OPEN p_cur FOR

			SELECT 
				INFO."UserId",
				INFO."First" "First Name",
				INFO."Last" "Last Name",
				CASE
					WHEN INFO."ClientNumber" = -1 THEN
						'Client Group : '||INFO."ClientGroup"
					WHEN INFO."ClientNumber" >= 0 THEN
						'Client : '||(SELECT KY_SUPPLIER_ID FROM CIS_SUPPLIER WHERE KY_SUPPLIER_NO = INFO."ClientNumber")
				END "Assignment",
				INFO."Roles" "Roles"
			FROM 
				(SELECT
					ID_USER_ID "UserId",
					PPLSCIS.CIS_GET_PROFILE_ATTRIBUTE(ID_USER_GUID,'FirstName') "First",
					PPLSCIS.CIS_GET_PROFILE_ATTRIBUTE(ID_USER_GUID,'LastName') "Last",
					TO_NUMBER(PPLSCIS.CIS_GET_PROFILE_ATTRIBUTE(ID_USER_GUID,'UserClientNumber')) "ClientNumber",
					PPLSCIS.CIS_GET_PROFILE_ATTRIBUTE(ID_USER_GUID,'UserClientGroup') "ClientGroup",
					PPLSCIS.CIS_GET_USER_ROLES(ID_USER_GUID) "Roles"
				 FROM
					PPLSCIS.CIS_USER_XREF
				 WHERE
					ID_USER_ID NOT LIKE '%TEST%') INFO
			WHERE
				"Roles" IS NOT NULL
			ORDER BY
				"Assignment",
				"UserId";


    
    END get_list_of_users_for_reports;
    
    
      
        
END P_CIS;
/
show errors