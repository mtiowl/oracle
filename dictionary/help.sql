      select '@cols tablename                  - Table column details' "Available Utility SQL Scripts" from dual
union select '@contents                        - List of commands'                                     from dual
union select '@i owner indexname               - index details'                                        from dual
union select '@ic                              - list index candidates for rebuild and/or compression' from dual
union select '@name                            - list current database'                                from dual
union select '@privs username                  - list user''s system privileges and roles'             from dual
union select '@sessions                        - list current sessions by logon time'                  from dual
union select '@snapshots                       - list available hourly performance snapshots'          from dual
union select '@sql_binds sqlid                 - list SQL recent bind values'                          from dual
union select '@sql_by_hour start stop topcount - hourly preformance details report'                    from dual
union select '@sqlstats  sqlid                 - Statistics for SQL'                                   from dual
union select '@sqlstatsl sqlid                 - Statistics, text, execution plan for SQL'             from dual
union select '@t owner tablename               - table details'                                        from dual
union select '@tbs                             - list tablespaces'                                     from dual
union select '@tblsp tblspname                 - tablespace details'                                   from dual
union select '@user username                   - attributes of one user'                               from dual
union select '@v owner indexname               - validate - find best index compression'               from dual
order by 1;
 