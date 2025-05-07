-- CompanyDB Sample Queries
-- Based on the database schema for a company management system

-- Query 1: List the full name of all employees who are directly supervised by James E. Borg
-- Find the full name of all employees whose Super_ssn is James E. Borg's Ssn
SELECT CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
JOIN Employee s ON e.Super_ssn = s.Ssn
WHERE s.Fname = 'John' AND s.Lname = 'Smith';

-- Query 2: Set the Fname of Francis Lemon who has Ssn = 123456789
UPDATE Employee
SET Fname = 'Francis', Lname = 'Lemon'
WHERE Ssn = '123456789';

-- Query 3: Select from Employee where Salary > $30,000
SELECT *
FROM Employee
WHERE Salary > 30000;

-- Query 4: Find the full name of all employees who work in the Software department
SELECT CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
JOIN Department d ON e.Dno = d.Dno
WHERE d.Dname = 'Research';

-- Query 5: Retrieve the number of employees in each department with department name
SELECT d.Dname AS 'Department Name', COUNT(e.Ssn) AS 'Number of Employees'
FROM Department d
LEFT JOIN Employee e ON d.Dno = e.Dno
GROUP BY d.Dno, d.Dname
ORDER BY COUNT(e.Ssn) DESC;

-- Query 6: Delete the Department with Dno=5
-- Note: This will only work if there are no employees assigned to this department
-- or if the foreign key constraint allows cascading deletes
DELETE FROM Department
WHERE Dno = 5;

-- Query 7: Find all employees who work on ProjectX (Pno=1)
SELECT CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
JOIN Works_On w ON e.Ssn = w.Essn
JOIN Project p ON w.Pno = p.Pno
WHERE p.Pname = 'ProductX';

-- Query 8: Find employees who work on more than one project
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name', COUNT(w.Pno) AS 'Number of Projects'
FROM Employee e
JOIN Works_On w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Lname
HAVING COUNT(w.Pno) > 1;

-- Query 9: Find the department with the highest average salary
SELECT d.Dno, d.Dname AS 'Department Name', AVG(e.Salary) AS 'Average Salary'
FROM Department d
JOIN Employee e ON d.Dno = e.Dno
GROUP BY d.Dno, d.Dname
ORDER BY AVG(e.Salary) DESC
LIMIT 1;

-- Query 10: Find employees who work on all projects controlled by department number 1
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
WHERE NOT EXISTS (
    SELECT p.Pno
    FROM Project p
    WHERE p.Dno = 1
    AND NOT EXISTS (
        SELECT *
        FROM Works_On w
        WHERE w.Essn = e.Ssn AND w.Pno = p.Pno
    )
);

-- Query 11: Calculate total hours each employee works across all projects
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name', 
       SUM(w.Hours) AS 'Total Hours', 
       COUNT(w.Pno) AS 'Number of Projects'
FROM Employee e
JOIN Works_On w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Lname
ORDER BY SUM(w.Hours) DESC;

-- Query 12: Find managers who are supervising more than 2 employees
SELECT m.Ssn, CONCAT(m.Fname, ' ', m.Lname) AS 'Manager Name', 
       COUNT(e.Ssn) AS 'Number of Employees Supervised'
FROM Employee m
JOIN Employee e ON m.Ssn = e.Super_ssn
GROUP BY m.Ssn, m.Fname, m.Lname
HAVING COUNT(e.Ssn) > 2;

-- Query 13: Find projects with the most employees working on them
SELECT p.Pno, p.Pname AS 'Project Name', COUNT(w.Essn) AS 'Number of Employees'
FROM Project p
JOIN Works_On w ON p.Pno = w.Pno
GROUP BY p.Pno, p.Pname
ORDER BY COUNT(w.Essn) DESC;

-- Query 14: Find the average working hours for each project
SELECT p.Pno, p.Pname AS 'Project Name', AVG(w.Hours) AS 'Average Hours'
FROM Project p
JOIN Works_On w ON p.Pno = w.Pno
GROUP BY p.Pno, p.Pname
ORDER BY AVG(w.Hours) DESC;

-- Query 15: Find employees who have a salary higher than their department's average
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name', 
       e.Salary, d.Dname AS 'Department Name',
       (SELECT AVG(e2.Salary) FROM Employee e2 WHERE e2.Dno = e.Dno) AS 'Department Average'
FROM Employee e
JOIN Department d ON e.Dno = d.Dno
WHERE e.Salary > (
    SELECT AVG(e2.Salary)
    FROM Employee e2
    WHERE e2.Dno = e.Dno
);

-- Query 16: Find departments that do not have any projects
SELECT d.Dno, d.Dname AS 'Department Name'
FROM Department d
WHERE NOT EXISTS (
    SELECT 1
    FROM Project p
    WHERE p.Dno = d.Dno
);

-- Query 17: Find employees who work on all projects in their department
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
WHERE NOT EXISTS (
    SELECT p.Pno
    FROM Project p
    WHERE p.Dno = e.Dno
    AND NOT EXISTS (
        SELECT 1
        FROM Works_On w
        WHERE w.Essn = e.Ssn AND w.Pno = p.Pno
    )
);

-- Query 18: Find employees who work in the same department as their supervisor
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name', 
       s.Ssn, CONCAT(s.Fname, ' ', s.Lname) AS 'Supervisor Name',
       d.Dname AS 'Department Name'
FROM Employee e
JOIN Employee s ON e.Super_ssn = s.Ssn
JOIN Department d ON e.Dno = d.Dno
WHERE e.Dno = s.Dno;

-- Query 19: Find employees who do not work on any project
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Lname) AS 'Employee Name'
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM Works_On w
    WHERE w.Essn = e.Ssn
);

-- Query 20: Find departments with the most projects
SELECT d.Dno, d.Dname AS 'Department Name', COUNT(p.Pno) AS 'Number of Projects'
FROM Department d
LEFT JOIN Project p ON d.Dno = p.Dno
GROUP BY d.Dno, d.Dname
ORDER BY COUNT(p.Pno) DESC; 