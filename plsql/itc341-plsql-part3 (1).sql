-- summary of frequently visited system tables
-- 1. table info
user_tables -- for common user
dba_tables -- SYS, col-owner
user_tab_cols	-- table + column info
select table_name, tablespace_name, status from user_tables;
TABLE_NAME      TABLESPACE_NAME STATUS
--------------- --------------- --------
EMPLOYEE        USERS           VALID
DEPARTMENT      USERS           VALID
WORKS_ON        USERS           VALID
DEPENDENT       USERS           VALID
DEPT_LOCATIONS  USERS           VALID
EMP_NUM         USERS           VALID
PROJECT         USERS           VALID

select table_name, column_name, data_type, data_length from user_tab_cols;
TABLE_NAME      COLUMN_NAME     DATA_TYPE       DATA_LENGTH
--------------- --------------- --------------- -----------
DEPARTMENT      MGRSSN          CHAR                      9
DEPARTMENT      DNUMBER         NUMBER                   22
DEPARTMENT      DNAME           VARCHAR2                 15
DEPARTMENT      MGRSTARTDATE    DATE                      7
DEPENDENT       ESSN            CHAR                      9
DEPENDENT       DEPENDENT_NAME  VARCHAR2                 10
DEPENDENT       RELATIONSHIP    VARCHAR2                 10
DEPENDENT       SEX             VARCHAR2                  1
DEPENDENT       BDATE           DATE                      7
DEPT_LOCATIONS  DNUMBER         NUMBER                   22
DEPT_LOCATIONS  DLOCATION       VARCHAR2                 20
EMPLOYEE        LNAME           VARCHAR2                 15
EMPLOYEE        MINIT           VARCHAR2                  1
EMPLOYEE        FNAME           VARCHAR2                 15
EMPLOYEE        SSN             CHAR                      9
EMPLOYEE        DNO             NUMBER                   22
EMPLOYEE        SUPERSSN        CHAR                      9
EMPLOYEE        SALARY          NUMBER                   22
EMPLOYEE        SEX             VARCHAR2                  1
EMPLOYEE        ADDRESS         VARCHAR2                 50
EMPLOYEE        BDATE           DATE                      7
EMP_NUM         NUM             NUMBER                   22
PROJECT         DNUM            NUMBER                   22
PROJECT         PLOCATION       VARCHAR2                 15
PROJECT         PNUMBER         NUMBER                   22
PROJECT         PNAME           VARCHAR2                 15
WORKS_ON        PNO             NUMBER                   22
WORKS_ON        ESSN            CHAR                      9
WORKS_ON        HOURS           NUMBER                   22

-- 2. user-defined objects
user_constraints
user_triggers
user_procedures
user_objects

select constraint_name, constraint_type, table_name, search_condition, status from user_constraints;
CONSTRAINT_NAME           C TABLE_NAME      SEARCH_CONDITION                    STATUS
------------------------- - --------------- ----------------------------------- --------
WORKS_ON_ESSN             R WORKS_ON                                            ENABLED
DEPENDENT_ESSN            R DEPENDENT                                           ENABLED
DEPTMGRFK                 R DEPARTMENT                                          ENABLED
EMPLOYEE_SUPERSSN         R EMPLOYEE                                            ENABLED
DEPT_LOCATIONS_DNUMBER    R DEPT_LOCATIONS                                      ENABLED
PROJECT_DNUM              R PROJECT                                             ENABLED
EMPLOYEE_DNO              R EMPLOYEE                                            ENABLED
WORKS_ON_PNO              R WORKS_ON                                            ENABLED
DEPENDENT_NAME            P DEPENDENT                                           ENABLED
SYS_C00142282             C EMPLOYEE        Sex = 'M' or Sex = 'F'              ENABLED
SYS_C00142283             C EMPLOYEE        salary between 20000 and 100000     ENABLED
EMPPK                     P EMPLOYEE                                            ENABLED
SYS_C00142285             C DEPARTMENT      "DNAME" IS NOT NULL                 DISABLED
DEPTPK                    P DEPARTMENT                                          ENABLED
DEPT                      P DEPT_LOCATIONS                                      ENABLED
PROJECT_PNUMBER           P PROJECT                                             ENABLED
-- about constraints:
-- 1: type: P->primary key, R->foreign key, C->check
-- 2: name: constraints w/o an explicit name are named by a serial number
-- 3: search condition: the actual clause you used in table creation
-- 4: status: alter table <table_name> enable/disable constraint <constraint_name> ;
-- alter table department disable constraint sys_c00142285;

select trigger_name, trigger_type, table_name, column_name, status from user_triggers;
TRIGGER_NAME         TRIGGER_TYPE     TABLE_NAME      COLUMN_NAME     STATUS
-------------------- ---------------- --------------- --------------- --------
EMP_NUM_INSERT       BEFORE STATEMENT EMPLOYEE                        DISABLED

alter trigger <trigger_name> disable/enable;

select object_name, procedure_name, object_type from user_procedures;
OBJECT_NAME          PROCEDURE_NAME       OBJECT_TYPE
-------------------- -------------------- -------------
EMP_PACKAGE          GET_EMP_FNAME        PACKAGE
EMP_PACKAGE          GET_EMP_NUM          PACKAGE
EMP_NUM_INSERT                            TRIGGER
EMP_PACKAGE                               PACKAGE

select object_name, object_type, status from user_objects order by object_type;
OBJECT_NAME          OBJECT_TYPE             STATUS
-------------------- ----------------------- -------
GET_EMP_NAME         FUNCTION                INVALID
EMPPK                INDEX                   VALID
PROJECT_PNUMBER      INDEX                   VALID
DEPENDENT_NAME       INDEX                   VALID
DEPT                 INDEX                   VALID
DEPTPK               INDEX                   VALID
EMP_PACKAGE          PACKAGE                 VALID
EMP_PACKAGE          PACKAGE BODY            VALID
DEPENDENT            TABLE                   VALID
WORKS_ON             TABLE                   VALID
PROJECT              TABLE                   VALID
DEPARTMENT           TABLE                   VALID
EMPLOYEE             TABLE                   VALID
DEPT_LOCATIONS       TABLE                   VALID
EMP_NUM              TABLE                   VALID
EMP_NUM_INSERT       TRIGGER                 VALID
-- to find a function => user_objects is better
-- to find a procedure => user_procedures (PROCEDURE_NAME is not null and OBJECT_TYPE = 'package')
-- indexes: primary keys are assigned w/ an index automatically to enhance the performance of queries
-- if you have a column that is frequently visited, 
-- put it close to the column w/ an index (usually pk column)


-- pl/sql: CURSOR -> current set of rows
-- chr(9) -> \t
-- chr(13) || chr(10) -> \n
-- make it into a procedure => tname in user_tab_columns.table_name%type

-- to generate pure sql script
set pages 0 linesize 6000 echo off feed off verify off trimsp on
set long 1000000 serveroutput on size 1000000 format wrapped
spool U:\sql\load-cmd.sql
declare
	cursor emp_info is select column_name, data_type, data_length from user_tab_columns where table_name = 'EMPLOYEE';
	cn varchar2(8);	-- column "SUPERSSN"
	dt varchar2(8);	-- column "VARCHAR2"
	dl number(2);	-- 1 to 50
begin
	open emp_info;
	dbms_output.put_line('create table ' || 'EMPLOYEE' || '(');
	loop
		fetch emp_info into cn, dt, dl;
		exit when emp_info%notfound;
		-- rownum = count(*) - 1
		if cn = 'DNO' then
			dbms_output.put_line(chr(9) || cn || ' ' || dt); 
		elsif dt = 'DATE' or dt = 'NUMBER' then
			dbms_output.put_line(chr(9) || cn || ' ' || dt || ',');
		else
			dbms_output.put_line(chr(9) || cn || ' ' || dt || '(' || dl || '),');
		end if;	
	end loop;
	dbms_output.put_line(');');
	close emp_info;
end;
/
spool off

-- appendix -> generate the script to drop all tables
set pages 0 linesize 6000 echo off feed off verify off trimsp on
set long 1000000 serveroutput on size 1000000 format wrapped

spool U:\sql\drop-tables.sql

select 'drop table ' || table_name || ' cascade constraints;' from user_tables;

spool off