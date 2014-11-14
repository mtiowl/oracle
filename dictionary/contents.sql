      select '@cols        - Table column details' "Available Utility SQL Scripts" from dual
union select '@contents    - list of available scripts'                            from dual
union select '@i           - index details'                                        from dual
union select '@ic          - list index candidates for rebuild and/or compression' from dual
union select '@name        - list current database'                                from dual
union select '@privs       - list user''s system privileges and roles'             from dual
union select '@sessions    - list current sessions by logon time'                  from dual
union select '@snapshots   - list available hourly performance snapshots'          from dual
union select '@sql_binds   - list SQL recent bind values'                          from dual
union select '@sql_by_hour - hourly preformance details report'                    from dual
union select '@sqlstats    - Statistics for SQL'                                   from dual
union select '@sqlstatsl   - Statistics, text, execution plan for SQL'             from dual
union select '@t           - table details'                                        from dual
union select '@tbs         - list tablespaces'                                     from dual
union select '@tblsp       - tablespace details'                                   from dual
union select '@user        - attributes of one user'                               from dual
union select '@v           - validate - find best index compression'               from dual
order by 1;
