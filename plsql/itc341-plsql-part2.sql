-- itc341 plsql part2 note
set echo on linesize 100 pagesize 60 serveroutput on
-- 4. package: a bundle of multiple procedures
desc user_procedures
SQL> col object_name for a15
SQL> select object_name, object_type from user_procedures;

OBJECT_NAME     OBJECT_TYPE
--------------- -------------
GET_EMP_FNAME   FUNCTION
GET_EMP_FNAMEV2 PROCEDURE
EMP_NUM_INSERT  TRIGGER
select 'drop function ' || object_name || ';' from user_procedures where object_type = 'FUNCTION';
select 'drop procedure ' || object_name || ';' from user_procedures where object_type = 'PROCEDURE';
-- get_emp_fname (ssn): 
-- get_emp_num (): 
create [or replace] package <package_name> as 
	procedure <proc_name_1> (parameter in datatype);
	procedure <proc_name_2>	...;
	...
end;
/
-- package declaration
create or replace package emp_package as 
	procedure get_emp_fname (input in employee.ssn%type);
	procedure get_emp_num;
end;
/
-- package body implementation
create or replace package body emp_package as 
	procedure get_emp_fname (input in employee.ssn%type) as ename employee.fname%type;
	BEGIN
		ename := '';
		select fname into ename from employee where ssn = input;
		dbms_output.put_line(ename);	
	end;
	
	procedure get_emp_num as empnum number;
	BEGIN
		select count(*) into empnum from employee;
		dbms_output.put_line(empnum);
	end;	
end;
/

exec emp_package.get_emp_num;

-- 5. if-statement
-- check if the number is even or odd
-- in java:
-- int var = 5;
-- if(var % 2 == 1)	System.out.println("Odd")
-- else System.out.println("Even");
declare
	var number(2) := 5;
begin
	if(mod(var, 2) = 1)	then
		dbms_output.put_line('Odd');
	else
		dbms_output.put_line('Even');
	end if;
end;
/
-- if-else if
if <condition_expr> then
	...
elsif	<condition_expr> then
	...
else
	...
end if;

-- 6. LOOP
-- for(int i = 0; i < 5; i++)
-- 		System.out.print(i + " ");
-- loop -- end loops
-- to control the flow => 1. if-exit 2. if-exit when
-- 1: if-exit
declare
	i number(1) := 0;
begin
	loop
		dbms_output.put(i || ' ');
		i := i + 1;
		if i >= 5 then
			exit;
		end if;
	end loop;
	dbms_output.new_line();
end;
/
-- 2: exit-when 
declare
	i number(1) := 0;
begin
	loop
		dbms_output.put(i || ' ');
		i := i + 1;		
		exit when i >= 5;
	end loop;
	dbms_output.new_line();
end;
/
-- 3. nested loop
for(int i = 0; i < 5; i++)
	for(int j = 0; j < 5; j++)
		System.out.println("[" + i + "," + j + "]");
-- PL/SQL
declare
	i number(1) := 0;
	j number(1) := 0;
begin
	loop	-- loop of iterator i
		j := 0;
		loop
			exit when j >= 5;
			dbms_output.put_line('[' || i || ',' || j || ']');
			j := j + 1;
		end loop;
		i := i + 1;
		exit when i >= 5;
	end loop;
end;
/

-- 7. CURSOR
-- how to recreate a table in the DB?
-- we will create a procedure to recreate employee table 
-- according to its current structure.