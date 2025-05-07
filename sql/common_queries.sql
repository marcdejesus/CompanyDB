-- CompanyDB Common Queries
-- Practical, everyday queries for the company database

-- 1. Basic employee information with department name
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       e.Salary, d.Dname AS 'Department'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
ORDER BY d.Dname, e.Lname, e.Fname;

-- 2. Employee contact list with manager information
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       e.Address, e.Dno,
       CONCAT(m.Fname, ' ', m.Minit, '. ', m.Lname) AS 'Manager'
FROM EMPLOYEE e
LEFT JOIN EMPLOYEE m ON e.Super_ssn = m.Ssn
ORDER BY e.Dno, e.Lname;

-- 3. Project status report with count of assigned employees
SELECT p.Pnumber, p.Pname, p.Plocation,
       COUNT(w.Essn) AS 'Assigned Employees',
       SUM(w.Hours) AS 'Total Hours'
FROM PROJECT p
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY p.Pnumber, p.Pname, p.Plocation
ORDER BY p.Pnumber;

-- 4. Employee assignment report showing projects and hours for each employee
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       p.Pname AS 'Project', w.Hours
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN PROJECT p ON w.Pno = p.Pnumber
ORDER BY e.Lname, e.Fname, p.Pname;

-- 5. Department summary with manager and employee count
SELECT d.Dnumber, d.Dname,
       CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Manager',
       COUNT(emp.Ssn) AS 'Number of Employees',
       d.Mgr_start_date AS 'Manager Since'
FROM DEPARTMENT d
LEFT JOIN EMPLOYEE e ON d.Mgr_ssn = e.Ssn
LEFT JOIN EMPLOYEE emp ON emp.Dno = d.Dnumber
GROUP BY d.Dnumber, d.Dname, e.Fname, e.Minit, e.Lname, d.Mgr_start_date
ORDER BY d.Dnumber;

-- 6. Family information - employees and their dependents
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       d.Dependent_name, d.Relationship, d.Bdate AS 'Birth Date'
FROM EMPLOYEE e
LEFT JOIN DEPENDENT d ON e.Ssn = d.Essn
ORDER BY e.Lname, e.Fname, d.Dependent_name;

-- 7. Salary statistics by department
SELECT d.Dname AS 'Department',
       MIN(e.Salary) AS 'Minimum Salary',
       MAX(e.Salary) AS 'Maximum Salary',
       AVG(e.Salary) AS 'Average Salary',
       SUM(e.Salary) AS 'Total Salary Budget'
FROM DEPARTMENT d
JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dname
ORDER BY AVG(e.Salary) DESC;

-- 8. Project workload distribution
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       COUNT(w.Pno) AS 'Number of Projects',
       SUM(w.Hours) AS 'Total Hours',
       ROUND(SUM(w.Hours)/COUNT(w.Pno), 2) AS 'Average Hours per Project'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY SUM(w.Hours) DESC;

-- 9. Find employees with no assignments
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       d.Dname AS 'Department'
FROM EMPLOYEE e
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
WHERE w.Essn IS NULL
ORDER BY d.Dname, e.Lname, e.Fname;

-- 10. Department location report with employee counts
SELECT dl.Dlocation AS 'Location',
       d.Dname AS 'Department',
       COUNT(e.Ssn) AS 'Employee Count'
FROM DEPT_LOCATIONS dl
JOIN DEPARTMENT d ON dl.Dnumber = d.Dnumber
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY dl.Dlocation, d.Dname
ORDER BY dl.Dlocation, d.Dname;

-- 11. Find employees who are working on projects outside their department
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       d.Dname AS 'Employee Department',
       p.Pname AS 'Project',
       dp.Dname AS 'Project Department'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN PROJECT p ON w.Pno = p.Pnumber
JOIN DEPARTMENT dp ON p.Dnum = dp.Dnumber
WHERE e.Dno != p.Dnum
ORDER BY e.Lname, e.Fname, p.Pname;

-- 12. Employee birthday list (for HR)
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       e.Bdate AS 'Birth Date',
       TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) AS 'Age',
       d.Dname AS 'Department'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
ORDER BY MONTH(e.Bdate), DAY(e.Bdate);

-- 13. Find the oldest and youngest employee in each department
SELECT d.Dname AS 'Department',
       (SELECT CONCAT(e1.Fname, ' ', e1.Minit, '. ', e1.Lname)
        FROM EMPLOYEE e1
        WHERE e1.Dno = d.Dnumber
        ORDER BY e1.Bdate ASC
        LIMIT 1) AS 'Oldest Employee',
       (SELECT CONCAT(e2.Fname, ' ', e2.Minit, '. ', e2.Lname)
        FROM EMPLOYEE e2
        WHERE e2.Dno = d.Dnumber
        ORDER BY e2.Bdate DESC
        LIMIT 1) AS 'Youngest Employee'
FROM DEPARTMENT d;

-- 14. Employee direct reports count (span of control)
SELECT CONCAT(m.Fname, ' ', m.Minit, '. ', m.Lname) AS 'Manager',
       COUNT(e.Ssn) AS 'Number of Direct Reports'
FROM EMPLOYEE m
LEFT JOIN EMPLOYEE e ON m.Ssn = e.Super_ssn
GROUP BY m.Ssn, m.Fname, m.Minit, m.Lname
ORDER BY COUNT(e.Ssn) DESC;

-- 15. Project workload by department
SELECT d.Dname AS 'Department',
       SUM(w.Hours) AS 'Total Project Hours',
       COUNT(DISTINCT p.Pnumber) AS 'Number of Projects'
FROM DEPARTMENT d
LEFT JOIN PROJECT p ON d.Dnumber = p.Dnum
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY d.Dnumber, d.Dname
ORDER BY SUM(w.Hours) DESC;

-- 16. Find potential resource conflicts (employees assigned to multiple projects)
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       SUM(w.Hours) AS 'Total Weekly Hours'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
HAVING SUM(w.Hours) > 40
ORDER BY SUM(w.Hours) DESC;

-- 17. Employee-to-employee relationships
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       CONCAT(s.Fname, ' ', s.Minit, '. ', s.Lname) AS 'Supervisor',
       CONCAT(m.Fname, ' ', m.Minit, '. ', m.Lname) AS 'Department Manager'
FROM EMPLOYEE e
LEFT JOIN EMPLOYEE s ON e.Super_ssn = s.Ssn
LEFT JOIN DEPARTMENT d ON e.Dno = d.Dnumber
LEFT JOIN EMPLOYEE m ON d.Mgr_ssn = m.Ssn
ORDER BY e.Dno, e.Lname, e.Fname;

-- 18. Department gender diversity report
SELECT d.Dname AS 'Department',
       SUM(CASE WHEN e.Sex = 'M' THEN 1 ELSE 0 END) AS 'Male Employees',
       SUM(CASE WHEN e.Sex = 'F' THEN 1 ELSE 0 END) AS 'Female Employees',
       COUNT(e.Ssn) AS 'Total Employees',
       ROUND(SUM(CASE WHEN e.Sex = 'F' THEN 1 ELSE 0 END) / COUNT(e.Ssn) * 100, 2) AS 'Female %'
FROM DEPARTMENT d
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname
ORDER BY d.Dname;

-- 19. Recent project assignments (simulate with fake dates)
-- Note: WORKS_ON doesn't have start dates in our schema, so this is for demonstration
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       p.Pname AS 'Project',
       w.Hours
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN PROJECT p ON w.Pno = p.Pnumber
ORDER BY e.Lname, e.Fname, p.Pname;

-- 20. Full company hierarchy (using Common Table Expression)
WITH RECURSIVE EmployeeHierarchy AS (
    -- Base case: employees with no supervisor (top of hierarchy)
    SELECT e.Ssn, e.Fname, e.Minit, e.Lname, e.Super_ssn, 0 AS Level
    FROM EMPLOYEE e
    WHERE e.Super_ssn IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with supervisors
    SELECT e.Ssn, e.Fname, e.Minit, e.Lname, e.Super_ssn, eh.Level + 1
    FROM EMPLOYEE e
    JOIN EmployeeHierarchy eh ON e.Super_ssn = eh.Ssn
)
SELECT 
    CONCAT(REPEAT('    ', Level), CONCAT(eh.Fname, ' ', eh.Minit, '. ', eh.Lname)) AS 'Company Hierarchy',
    Level AS 'Level'
FROM EmployeeHierarchy eh
ORDER BY Level, eh.Lname, eh.Fname; 