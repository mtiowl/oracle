create user E40025 identified by try_th1s;
grant CONNECT to E40025;
alter user E40025 identified globally as 'CN=Irving\, Michael T,OU=PPL Services,ou=ad,cn=users,dc=ppl,dc=com';

select username, profile, authentication_type, external_name from dba_users where username = 'E40025';