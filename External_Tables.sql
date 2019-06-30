File: C:\oracle_logs\text.txt

1,"AAA",100
2,"BBB",200
3,"CCC",300

 

 
CREATE OR REPLACE DIRECTORY EXTERNAL_DIR AS 'C:\oracle_logs\';

CREATE TABLE ext_table_txt (
    id        NUMBER,
    empname   VARCHAR2(20),
    rate      NUMBER
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY EXTERNAL_DIR ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' (
            id,
            empname,
            rate
        )
    ) LOCATION ('text.txt' )
);


select * from ext_table_txt;



CREATE TABLE ext_table_csv (
    id        NUMBER,
    empname   VARCHAR2(20),
    rate      NUMBER
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY EXTERNAL_DIR ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' (
            id,
            empname,
            rate
        )
    ) LOCATION ('text_csv.csv' )
);


select * from ext_table_csv;


CREATE TABLE countries_ext (
  country_code      VARCHAR2(5),
  country_name      VARCHAR2(50),
  country_language  VARCHAR2(50)
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY EXTERNAL_DIR
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE 
	FIELDS TERMINATED BY ',' MISSING FIELD VALUES ARE NULL
    (
      country_code      CHAR(5),
      country_name      CHAR(50),
      country_language  CHAR(50)
    )
  )
  LOCATION ('Countries1.txt','Countries2.txt')
)
PARALLEL 5
REJECT LIMIT UNLIMITED;

select * from countries_ext;

By default, a log of load operations is created in the same directory as the load files, but this can be changed using the LOGFILE parameter.
Any rows that fail to load are written to a bad file. By default, the bad file is created in the same directory as the load files, but this can be changed using the BADFILE parameter.




CREATE OR REPLACE DIRECTORY bdump AS '/u01/app/oracle/admin/SID/bdump/';

DROP TABLE alert_log;

CREATE TABLE alert_log (
  line  VARCHAR2(4000)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY bdump
  ACCESS PARAMETERS
  (
    RECORDS DELIMITED BY NEWLINE
    BADFILE bdump:'read_alert_%a_%p.bad'
    LOGFILE bdump:'read_alert_%a_%p.log'
    FIELDS TERMINATED BY '~'
    MISSING FIELD VALUES ARE NULL
    (
      line  CHAR(4000)
    )
  )
  LOCATION ('alert_SID.log')
)
PARALLEL 1
REJECT LIMIT UNLIMITED
/

SET LINESIZE 1000
SELECT * FROM alert_log;

/* Creating a dump file in pat */
CREATE TABLE emp_xt
  ORGANIZATION EXTERNAL
   (
     TYPE ORACLE_DATAPUMP
     DEFAULT DIRECTORY EXTERNAL_DIR
     LOCATION ('emp_xt.dmp')
   )
   AS SELECT * FROM emp;
   
   
   DROP TABLE emp_xt;

CREATE TABLE emp_xt (
  EMPNO     NUMBER(4),
  ENAME     VARCHAR2(10),
  JOB       VARCHAR2(9),
  MGR       NUMBER(4),
  HIREDATE  DATE,
  SAL       NUMBER(7,2),
  COMM      NUMBER(7,2),
  DEPTNO    NUMBER(2))
  ORGANIZATION EXTERNAL (
     TYPE ORACLE_DATAPUMP
     DEFAULT DIRECTORY test_dir
     LOCATION ('emp_xt.dmp')
  );

SELECT * FROM emp_xt;