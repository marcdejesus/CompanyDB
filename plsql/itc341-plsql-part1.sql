-- itc341 plsql part1 note
-- to change the output format in sqlplus
set echo on linesize 100 pagesize 60
column <column_name> format a10
col <col_name> for a10
-- 1. trigger
create [or replace] trigger <trigger_name>
before|after insert|update|delete on <table_name>
begin
	-- do something!
end;
/
-- let's create a table named EMP_NUM to hold the 
-- current total number of employee that we have
-- the trigger will update the EMP_NUM when there 
-- is an insert on employee
create table EMP_NUM as 
	(select count(*) as NUM from employee);
create trigger emp_num_insert
before insert on employee
begin
	update emp_num set num = num + 1;
end;
/
SQL> col trigger_name for a10
SQL> col table_name for a10
SQL> select trigger_name, trigger_type, table_name, status from user_triggers;
TRIGGER_NAME    TRIGGER_TYPE     TABLE_NAME STATUS
--------------- ---------------- ---------- --------
EMP_NUM_INSERT  BEFORE STATEMENT EMPLOYEE   ENABLED

Insert into EMPLOYEE values('ITC', 'B', '341', '235711130', to_date('1999-01-01', 'yyyy-mm-dd'), '1200 S. Franklin St, Mount Pleasant, MI 48859', 'M', 50000, null, 5);
-- if you merely see an error message that says compliation error
show errors

-- 2. functions
-- String SearchCourse(String AT, String DN){
--		String result = (select * from course where AcdemicTerm = AT and Departments = DN);
--		return result;
-- }
create [or replace] function <function_name> (<parameter_name> in datatype)
	return <result_value> datatype
is
	<var_name> datatype;
begin
	<var_name> := <literal_value>;
	-- a sql query to retrieve the corresponding result
	return <var_name>;
end;
/
-- a function to display the employee's name when given ssn
create or replace function get_emp_fname(input in employee.ssn%type)
	return employee.fname%type
is 
	output employee.fname%type;
begin
	output := '';
	select fname as FirstName into output from employee where ssn = input;
	return (output);
end;
/
-- to make a function call, use select function_call from dual;
select get_emp_fname('123456789') from dual;
select get_emp_fname('123456789') as fname from dual;

-- 3. PROCEDURE -> stored procedure
-- function = procedure = method = subprogram
-- 1. no return-is clause
-- 2. requires dbms_output to display the result
-- 3. to call a procedure, use 'exec' 
create or replace procedure get_emp_fnamev2(input in employee.ssn%type)
	as output employee.fname%type;
begin
	output := '';
	select fname into output from employee where ssn = input;
	dbms_output.put_line(output);
	exception
	when NO_DATA_FOUND THEN
		dbms_output.put_line('NO ROW SELECTED');
end;
/
-- set serveroutput on
-- required to show the result of dbms_output