--Remodified on Sep. 22, 2023
--a.The first name, last name of employees who works in department 5.
select fname, lname 
	from employee 
		where dno = 5;

--b. The first name, last name of every employee and name of his/her department.
select fname, lname, dname 
	from employee e, department d 
		where e.dno = d.dnumber;

--c. The first name, last name of employees who works in the department called 'Research'
select fname, lname 
	from employee, department
		where dno = dnumber and dname = 'Research';

--d. The first name, last name of employees who works in the project called 'Computerization'.
select fname, lname 
	from employee, works_on, project
		where ssn = essn and pno = pnumber and pname = 'Computerization';

--e. The first name, last name of every employee and name of project(s) he/she is working on.
select fname, lname, pname 
	from employee, project, works_on 
		where ssn = essn and pno = pnumber;