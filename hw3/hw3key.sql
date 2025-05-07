-- 1. Retrieve the names of all employees in department 5 who work more than 10 hours per week on the 'ProductX' project.
select fname || ' ' || minit || ' ' || lname as fullname
	from employee
		where dno = 5 and ssn in (
			select essn
				from project, works_on
					where pno = pnumber and pname = 'ProductX' and hours > 10);
					
-- 2. List the names of all employees who have a dependent with the same first name as themselves.
select fname || ' ' || minit || ' ' || lname as Name 
	FROM employee, dependent
		where ssn = essn and fname = Dependent_name;
		
-- 3. Find the names of all employees who are directly supervised by 'Franklin Wong'.
select fname || ' ' || minit || ' ' || lname as Name
	from employee
		where superssn in (
			select ssn from ( 
			select fname || ' ' || lname as Name , ssn from employee) 
		where Name = 'Franklin Wong');
		
-- 4. For each project, list the project name and the total hours per week (by all employees) spent on that project.
select pname, totalHour
	from project, (select pno, sum(Hours) as totalHour from works_on group by pno) t
		where pno = pnumber;
		
-- 5. Retrieve the names of all employees who work on every project.
select fname || ' ' || minit || ' ' || lname as Name
	from employee, (select essn, count(*) as NUM from works_on group by essn) t
		where ssn = essn and t.Num = (select count(*) as pcount from project);
		
-- 6. Retrieve the names of all employees who don't work on any project.
select fname || ' ' || minit || ' ' || lname as Name
	from employee 
		where ssn not in (select distinct essn from works_on);
		
-- 7.	For each department, retrieve the department name and the average salary of all employees working in that department.
select dname, AVGSAL
	from department, (select dno, avg(salary) as AVGSAL from employee group by dno)
		where dnumber = dno;
		
-- 8.	Retrieve the average salary of all female employees.
select avg(salary) as AVGSAL 
	from (select salary from employee where sex = 'F');
	
-- 9. 	Retrieve the maximum and minimum salary of all employees.
select max(salary), min(salary)
	from employee;
	
-- 10. 	List the last names of all department managers who have no dependents.
select fname || ' ' || minit || ' ' || lname as Name
	from employee
		where ssn in (
			select superssn 
				from department	
					where superssn not in (select distinct essn from dependent)
		);