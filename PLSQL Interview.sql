select * from V$SGA;
select * from V$INSTANCE;
select * from V$DATABASE;
select * from V$PROCESS;
select * from V$SYSAUX_OCCUPANTS;

select * from dba_users;
select * from all_users;
select * from v$statname;
select * from v$sesstat;
select * from v$session;
select * from resource_cost;
select * from dba_profiles;
select * from user_resource_limits;
select * from user_password_limits;
select * from user_TS_quotas;
select * from dba_TS_quotas;

select * from V$LOG_HISTORY;
select * from v$Datafile;

select * from v$tablespace;
select * from dba_tablespaces;
select * from dba_free_space;
select * from database_properties;

select * from all_col_privs;
select * from user_col_privs;
select * from all_Tab_privs;
select * from user_tab_privs;
select * from all_tab_privs_made;
select * from user_tab_privs_made;
select * from all_tab_privs_recd;
select * from user_tab_pris_recd;
select * from dba_roles;
select * from dba_col_privs;
select * from user_role_privs;
select * from dba_role_privs;
select * from user_sys_privs;
select * from dba_sys_privs;
select * from column_privileges;
select * from dba_Tab_privs;
select * from role_role_privs;
select * from role_sys_privs;
select * from session_privs;
select * from session_roles;

select * from v$px_process;
select * from v$px_session;
select * from v$px_process_sysstat;

select * from dba_segmemnts;
select * from dba_extents;
select * from dba_tables;
select * from dba_indexes;
select * from dba_tablespaces;
select * from dba_data_files;
select * from dba_free_space;

--Nth Salary
select * from employees e1
WHERE (N-1) = ( select count(Distinct Salary ) from employees e2
				where e2.salary > e1.salary )
				
-- Vertical to Horizontal
select substr('VENKAT',level,1) name 
	from dual
	connect by level <= length('Venkat');
		
-- Delete Duplicate rows
delete from employees A
where exists (SELECT 'x' from employees B	
				WHERE A.employee_id = B.employee_id
					AND B.row_id > A.Row_id);
					
-- Find Missing Sequence
select min_a - 1 + level 
FROM (
select min(a) min_a,
	   max(a) max_a
FROM test
)
connect by level <= max_a - min_a + 1
MINUS
select * from test;


Regular Expression Support in Oracle (REGEXP_COUNT, REGEXP_INSTR, REGEXP_REPLACE, ) 
^ --starting letter
select * from employees where REGEXP_LIKE(first_name,'^S(*)','i');
SELECT REGEXP_SUBSTR ('TechOnTheNet is a great resource', '(\S*)(\s)',,1,2)
FROM dual;
Result: 'is '
$ -- ending letter
| -- or condition
c -- case sesnitive, i -- insensitive
{m,n} m --matches m times , n - not more than n times


utl files
external tables
collections
pragma automonous transaction



--11g New Features;
Invisible INDEXES
Online table redefinition
DDL with wait lock option
adaptive cursor sharing
temporary table space enhancements
read only tables
virtual columns
result cache in sql and plsql
compound trigers
pragma inline
regexp count
listtag , nth value
continue in for loop


--12C New Features
Multitenant Architecture
advanced Identity column
Index Compression
invisible column
multiple indexes on same column
Top N Features, Limit OFfset
Long names
Mark old code as not for use
PL/SQL code with with clause
Pragma----
adaptie query optimization
inline plsql functions and procedures



--18c New Features
JSON
DBMS_SESSION.sleep
Private temporary tables
polymetric tabble function
real time material views
row limiting clause
qualified expressions
Approximate Top-N Query Processing (APPROX_RANK, APPROX_SUM, APPROX_COUNT)
inline external tables
SODA for PLSQL




--Advance queuing
CONNECT system/manager;
DROP USER aqadm CASCADE;
GRANT CONNECT, RESOURCE TO aqadm; 
CREATE USER aqadm IDENTIFIED BY aqadm;
GRANT EXECUTE ON DBMS_AQADM TO aqadm;
GRANT Aq_administrator_role TO aqadm;
DROP USER aq CASCADE;
CREATE USER aq IDENTIFIED BY aq;
GRANT CONNECT, RESOURCE TO aq; 
GRANT EXECUTE ON dbms_aq TO aq;





Creating a Queue Table and Queue of Object Type

/* Creating a message type: */
CREATE type aq.Message_typ as object (
subject     VARCHAR2(30),
text        VARCHAR2(80));   

/* Creating a object type queue table and queue: */
EXECUTE DBMS_AQADM.CREATE_QUEUE_TABLE (queue_table => 'aq.objmsgs80_qtab',queue_payload_type => 'aq.Message_typ');

EXECUTE DBMS_AQADM.CREATE_QUEUE (queue_name => 'msg_queue',queue_table => 'aq.objmsgs80_qtab');

EXECUTE DBMS_AQADM.START_QUEUE (queue_name => 'msg_queue');