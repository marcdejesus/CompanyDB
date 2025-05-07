-- CompanyDB Sample Queries
-- Based on the database schema defined in setup.sql

-- Query 1: List the full name of all employees who are directly supervised by James E. Borg
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
WHERE e.Super_ssn = (
    SELECT Ssn FROM EMPLOYEE WHERE Fname = 'James' AND Lname = 'Borg'
);

-- Query 2: Find the full name and salary of all employees who work in the Research department
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', e.Salary
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
WHERE d.Dname = 'Research';

-- Query 3: Retrieve the department name and the number of employees in each department
SELECT d.Dname AS 'Department Name', COUNT(e.Ssn) AS 'Number of Employees'
FROM DEPARTMENT d
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname
ORDER BY COUNT(e.Ssn) DESC;

-- Query 4: Find all employees who work on the ProductX project
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN PROJECT p ON w.Pno = p.Pnumber
WHERE p.Pname = 'ProductX';

-- Query 5: List employees who work on more than one project
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', 
       COUNT(w.Pno) AS 'Number of Projects'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
HAVING COUNT(w.Pno) > 1;

-- Query 6: Find the total hours each employee works across all projects
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', 
       SUM(w.Hours) AS 'Total Hours'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY SUM(w.Hours) DESC;

-- Query 7: Find the department with the highest average salary
SELECT d.Dnumber, d.Dname AS 'Department Name', AVG(e.Salary) AS 'Average Salary'
FROM DEPARTMENT d
JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname
ORDER BY AVG(e.Salary) DESC
LIMIT 1;

-- Query 8: Find employees who earn more than their direct supervisors
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', 
       e.Salary AS 'Employee Salary',
       CONCAT(s.Fname, ' ', s.Minit, '. ', s.Lname) AS 'Supervisor Name',
       s.Salary AS 'Supervisor Salary'
FROM EMPLOYEE e
JOIN EMPLOYEE s ON e.Super_ssn = s.Ssn
WHERE e.Salary > s.Salary;

-- Query 9: List all employees and the number of dependents they have
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       COUNT(d.Dependent_name) AS 'Number of Dependents'
FROM EMPLOYEE e
LEFT JOIN DEPENDENT d ON e.Ssn = d.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY COUNT(d.Dependent_name) DESC;

-- Query 10: Find employees who work on all projects controlled by department number 5
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT p.Pnumber
    FROM PROJECT p
    WHERE p.Dnum = 5
    AND NOT EXISTS (
        SELECT *
        FROM WORKS_ON w
        WHERE w.Essn = e.Ssn AND w.Pno = p.Pnumber
    )
);

-- Query 11: Find projects with the most employees working on them
SELECT p.Pnumber, p.Pname AS 'Project Name', COUNT(w.Essn) AS 'Number of Employees'
FROM PROJECT p
JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY p.Pnumber, p.Pname
ORDER BY COUNT(w.Essn) DESC;

-- Query 12: Find the average working hours for each project
SELECT p.Pnumber, p.Pname AS 'Project Name', AVG(w.Hours) AS 'Average Hours'
FROM PROJECT p
JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY p.Pnumber, p.Pname
ORDER BY AVG(w.Hours) DESC;

-- Query 13: List all department locations and the number of employees in each location
SELECT dl.Dlocation AS 'Location', COUNT(DISTINCT e.Ssn) AS 'Number of Employees'
FROM DEPT_LOCATIONS dl
LEFT JOIN DEPARTMENT d ON dl.Dnumber = d.Dnumber
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY dl.Dlocation
ORDER BY COUNT(DISTINCT e.Ssn) DESC;

-- Query 14: Find employees who have a salary higher than their department's average
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', 
       e.Salary, d.Dname AS 'Department Name',
       (SELECT AVG(e2.Salary) FROM EMPLOYEE e2 WHERE e2.Dno = e.Dno) AS 'Department Average'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
WHERE e.Salary > (
    SELECT AVG(e2.Salary)
    FROM EMPLOYEE e2
    WHERE e2.Dno = e.Dno
);

-- Query 15: Find the employees who have dependents born after 1980
SELECT DISTINCT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
JOIN DEPENDENT d ON e.Ssn = d.Essn
WHERE d.Bdate > '1980-01-01'
ORDER BY e.Fname, e.Lname;

-- Query 16: Find male employees who have female dependents
SELECT DISTINCT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
JOIN DEPENDENT d ON e.Ssn = d.Essn
WHERE e.Sex = 'M' AND d.Sex = 'F';

-- Query 17: List departments that do not have any projects
SELECT d.Dnumber, d.Dname AS 'Department Name'
FROM DEPARTMENT d
WHERE NOT EXISTS (
    SELECT 1
    FROM PROJECT p
    WHERE p.Dnum = d.Dnumber
);

-- Query 18: Find employees who work on all projects located in Houston
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT p.Pnumber
    FROM PROJECT p
    WHERE p.Plocation = 'Houston'
    AND NOT EXISTS (
        SELECT 1
        FROM WORKS_ON w
        WHERE w.Essn = e.Ssn AND w.Pno = p.Pnumber
    )
);

-- Query 19: Find employees who do not work on any project
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name'
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT 1
    FROM WORKS_ON w
    WHERE w.Essn = e.Ssn
);

-- Query 20: Get the name and address of employees who work on the most projects
SELECT e.Fname, e.Minit, e.Lname, e.Address, COUNT(w.Pno) AS 'Number of Projects'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname, e.Address
HAVING COUNT(w.Pno) = (
    SELECT COUNT(w2.Pno)
    FROM WORKS_ON w2
    GROUP BY w2.Essn
    ORDER BY COUNT(w2.Pno) DESC
    LIMIT 1
);

-- Query 21: List employees born before 1960 who work on at least 2 projects
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name', e.Bdate
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
WHERE e.Bdate < '1960-01-01'
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname, e.Bdate
HAVING COUNT(DISTINCT w.Pno) >= 2;

-- Query 22: Find projects where the manager of the controlling department also works on the project
SELECT p.Pnumber, p.Pname
FROM PROJECT p
JOIN WORKS_ON w ON p.Pnumber = w.Pno
JOIN DEPARTMENT d ON p.Dnum = d.Dnumber
WHERE w.Essn = d.Mgr_ssn;

-- Query 23: Calculate the total salary expense for each department
SELECT d.Dname AS 'Department Name', SUM(e.Salary) AS 'Total Salary Expense'
FROM DEPARTMENT d
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname
ORDER BY SUM(e.Salary) DESC;

-- Query 24: Find departments with more than 2 employees
SELECT d.Dname AS 'Department Name', COUNT(e.Ssn) AS 'Number of Employees'
FROM DEPARTMENT d
JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname
HAVING COUNT(e.Ssn) > 2;

-- Query 25: Update the salary of all employees in the Research department by 10%
UPDATE EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
SET e.Salary = e.Salary * 1.10
WHERE d.Dname = 'Research'; 