-- CompanyDB PL/SQL and JOIN Examples
-- Common PL/SQL procedures and JOIN query examples

-- =================================================================
-- PART 1: PL/SQL PROCEDURES AND FUNCTIONS
-- =================================================================

-- 1. PL/SQL Procedure: Add new employee
DELIMITER //
CREATE PROCEDURE AddNewEmployee(
    IN p_fname VARCHAR(50),
    IN p_minit CHAR(1),
    IN p_lname VARCHAR(50),
    IN p_ssn CHAR(9),
    IN p_bdate DATE,
    IN p_address VARCHAR(100),
    IN p_sex CHAR(1),
    IN p_salary DECIMAL(10,2),
    IN p_super_ssn CHAR(9),
    IN p_dno INT
)
BEGIN
    -- Validate department number
    DECLARE dept_exists INT;
    SELECT COUNT(*) INTO dept_exists FROM DEPARTMENT WHERE Dnumber = p_dno;
    
    -- Validate supervisor SSN if provided
    DECLARE super_exists INT DEFAULT 1;
    IF p_super_ssn IS NOT NULL THEN
        SELECT COUNT(*) INTO super_exists FROM EMPLOYEE WHERE Ssn = p_super_ssn;
    END IF;
    
    -- Insert new employee if validations pass
    IF dept_exists > 0 AND super_exists > 0 THEN
        INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno)
        VALUES (p_fname, p_minit, p_lname, p_ssn, p_bdate, p_address, p_sex, p_salary, p_super_ssn, p_dno);
        SELECT CONCAT('Employee ', p_fname, ' ', p_lname, ' added successfully') AS Result;
    ELSE
        IF dept_exists = 0 THEN
            SELECT CONCAT('Error: Department number ', p_dno, ' does not exist') AS Result;
        ELSE
            SELECT CONCAT('Error: Supervisor with SSN ', p_super_ssn, ' does not exist') AS Result;
        END IF;
    END IF;
END //
DELIMITER ;

-- 2. PL/SQL Procedure: Assign employee to project
DELIMITER //
CREATE PROCEDURE AssignEmployeeToProject(
    IN p_essn CHAR(9),
    IN p_pno INT,
    IN p_hours DECIMAL(5,2)
)
BEGIN
    -- Validate employee SSN
    DECLARE emp_exists INT;
    SELECT COUNT(*) INTO emp_exists FROM EMPLOYEE WHERE Ssn = p_essn;
    
    -- Validate project number
    DECLARE proj_exists INT;
    SELECT COUNT(*) INTO proj_exists FROM PROJECT WHERE Pnumber = p_pno;
    
    -- Check if assignment already exists
    DECLARE assignment_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO assignment_exists FROM WORKS_ON WHERE Essn = p_essn AND Pno = p_pno;
    
    -- Insert or update assignment if validations pass
    IF emp_exists > 0 AND proj_exists > 0 THEN
        IF assignment_exists > 0 THEN
            UPDATE WORKS_ON SET Hours = p_hours WHERE Essn = p_essn AND Pno = p_pno;
            SELECT 'Assignment updated successfully' AS Result;
        ELSE
            INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES (p_essn, p_pno, p_hours);
            SELECT 'Assignment created successfully' AS Result;
        END IF;
    ELSE
        IF emp_exists = 0 THEN
            SELECT CONCAT('Error: Employee with SSN ', p_essn, ' does not exist') AS Result;
        ELSE
            SELECT CONCAT('Error: Project number ', p_pno, ' does not exist') AS Result;
        END IF;
    END IF;
END //
DELIMITER ;

-- 3. PL/SQL Function: Calculate total project hours for a department
DELIMITER //
CREATE FUNCTION GetDepartmentProjectHours(p_dno INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_hours DECIMAL(10,2);
    
    SELECT COALESCE(SUM(w.Hours), 0) INTO total_hours
    FROM DEPARTMENT d
    JOIN PROJECT p ON d.Dnumber = p.Dnum
    JOIN WORKS_ON w ON p.Pnumber = w.Pno
    WHERE d.Dnumber = p_dno;
    
    RETURN total_hours;
END //
DELIMITER ;

-- 4. PL/SQL Procedure: Give salary raise to department employees
DELIMITER //
CREATE PROCEDURE GiveDepartmentRaise(
    IN p_dno INT,
    IN p_raise_percentage DECIMAL(5,2)
)
BEGIN
    DECLARE dept_exists INT;
    SELECT COUNT(*) INTO dept_exists FROM DEPARTMENT WHERE Dnumber = p_dno;
    
    IF dept_exists > 0 THEN
        UPDATE EMPLOYEE
        SET Salary = Salary * (1 + (p_raise_percentage / 100))
        WHERE Dno = p_dno;
        
        SELECT COUNT(*) AS 'Employees Updated',
               CONCAT(p_raise_percentage, '%') AS 'Raise Given',
               (SELECT Dname FROM DEPARTMENT WHERE Dnumber = p_dno) AS 'Department'
        FROM EMPLOYEE
        WHERE Dno = p_dno;
    ELSE
        SELECT CONCAT('Error: Department number ', p_dno, ' does not exist') AS Result;
    END IF;
END //
DELIMITER ;

-- 5. PL/SQL Function: Get employee's manager name
DELIMITER //
CREATE FUNCTION GetEmployeeManagerName(p_ssn CHAR(9)) 
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE manager_name VARCHAR(100);
    
    SELECT CONCAT(m.Fname, ' ', m.Minit, '. ', m.Lname) INTO manager_name
    FROM EMPLOYEE e
    JOIN EMPLOYEE m ON e.Super_ssn = m.Ssn
    WHERE e.Ssn = p_ssn;
    
    IF manager_name IS NULL THEN
        RETURN 'No manager assigned';
    ELSE
        RETURN manager_name;
    END IF;
END //
DELIMITER ;

-- 6. PL/SQL Procedure: Create project summary report
DELIMITER //
CREATE PROCEDURE CreateProjectSummaryReport()
BEGIN
    SELECT 
        p.Pnumber,
        p.Pname,
        d.Dname AS 'Department',
        COUNT(DISTINCT w.Essn) AS 'Number of Employees',
        SUM(w.Hours) AS 'Total Hours',
        CONCAT(m.Fname, ' ', m.Minit, '. ', m.Lname) AS 'Department Manager'
    FROM PROJECT p
    JOIN DEPARTMENT d ON p.Dnum = d.Dnumber
    LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
    LEFT JOIN EMPLOYEE m ON d.Mgr_ssn = m.Ssn
    GROUP BY p.Pnumber, p.Pname, d.Dname, m.Fname, m.Minit, m.Lname
    ORDER BY d.Dname, p.Pname;
END //
DELIMITER ;

-- =================================================================
-- PART 2: JOIN QUERY EXAMPLES
-- =================================================================

-- 1. INNER JOIN: Employees and their departments
-- Retrieves all employees with their department information
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       e.Salary, d.Dname AS 'Department', d.Dnumber
FROM EMPLOYEE e
INNER JOIN DEPARTMENT d ON e.Dno = d.Dnumber
ORDER BY d.Dname, e.Lname;

-- 2. LEFT JOIN: All employees and their projects (including employees with no projects)
-- Retrieves all employees and shows their project assignments, if any
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       p.Pname AS 'Project', w.Hours
FROM EMPLOYEE e
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
LEFT JOIN PROJECT p ON w.Pno = p.Pnumber
ORDER BY e.Lname, e.Fname, p.Pname;

-- 3. RIGHT JOIN: All projects and their employees (including projects with no employees)
-- Retrieves all projects and shows which employees are assigned to them, if any
SELECT p.Pname AS 'Project', p.Pnumber,
       CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       w.Hours
FROM WORKS_ON w
RIGHT JOIN PROJECT p ON w.Pno = p.Pnumber
LEFT JOIN EMPLOYEE e ON w.Essn = e.Ssn
ORDER BY p.Pname, e.Lname, e.Fname;

-- 4. FULL OUTER JOIN: All employees and all projects (using UNION since MySQL doesn't support FULL OUTER JOIN)
-- Retrieves all employees and all projects, showing all associations between them
SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       p.Pnumber, p.Pname AS 'Project', w.Hours
FROM EMPLOYEE e
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
LEFT JOIN PROJECT p ON w.Pno = p.Pnumber

UNION

SELECT e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee Name',
       p.Pnumber, p.Pname AS 'Project', w.Hours
FROM PROJECT p
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
LEFT JOIN EMPLOYEE e ON w.Essn = e.Ssn
WHERE e.Ssn IS NULL
ORDER BY 'Employee Name', 'Project';

-- 5. SELF JOIN: Employee and supervisor relationship
-- Retrieves all employees and their direct supervisors
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       CONCAT(s.Fname, ' ', s.Minit, '. ', s.Lname) AS 'Supervisor'
FROM EMPLOYEE e
LEFT JOIN EMPLOYEE s ON e.Super_ssn = s.Ssn
ORDER BY s.Lname, e.Lname;

-- 6. MULTI-TABLE JOIN: Comprehensive employee-project-department relationship
-- Retrieves detailed information about employees, their projects, departments, and supervisors
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       d.Dname AS 'Department',
       CONCAT(s.Fname, ' ', s.Minit, '. ', s.Lname) AS 'Supervisor',
       p.Pname AS 'Project',
       w.Hours AS 'Hours',
       p.Plocation AS 'Location'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
LEFT JOIN EMPLOYEE s ON e.Super_ssn = s.Ssn
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
LEFT JOIN PROJECT p ON w.Pno = p.Pnumber
ORDER BY d.Dname, e.Lname, p.Pname;

-- 7. CROSS JOIN: All possible project-location combinations
-- Creates a matrix of all projects and all locations where projects exist
SELECT DISTINCT p.Pname AS 'Project', l.Dlocation AS 'Possible Location'
FROM PROJECT p
CROSS JOIN (SELECT DISTINCT Dlocation FROM DEPT_LOCATIONS) l
ORDER BY p.Pname, l.Dlocation;

-- 8. JOIN with GROUP BY: Project statistics by department
-- Calculates statistics for projects grouped by the controlling department
SELECT d.Dname AS 'Department',
       COUNT(DISTINCT p.Pnumber) AS 'Number of Projects',
       COUNT(DISTINCT w.Essn) AS 'Number of Employees',
       SUM(w.Hours) AS 'Total Hours',
       ROUND(AVG(w.Hours), 2) AS 'Average Hours per Assignment'
FROM DEPARTMENT d
LEFT JOIN PROJECT p ON d.Dnumber = p.Dnum
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY d.Dnumber, d.Dname
ORDER BY COUNT(DISTINCT p.Pnumber) DESC;

-- 9. JOIN with HAVING: Find departments where employees work a lot of hours
-- Identifies departments where the average employee works more than 25 hours
SELECT d.Dname AS 'Department',
       COUNT(DISTINCT e.Ssn) AS 'Number of Employees',
       SUM(w.Hours) AS 'Total Hours',
       ROUND(SUM(w.Hours) / COUNT(DISTINCT e.Ssn), 2) AS 'Average Hours per Employee'
FROM DEPARTMENT d
JOIN EMPLOYEE e ON d.Dnumber = e.Dno
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY d.Dnumber, d.Dname
HAVING SUM(w.Hours) / COUNT(DISTINCT e.Ssn) > 25
ORDER BY SUM(w.Hours) / COUNT(DISTINCT e.Ssn) DESC;

-- 10. JOIN with Subquery: Compare employee hours to department average
-- Compares each employee's work hours with the average for their department
SELECT CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
       d.Dname AS 'Department',
       SUM(w.Hours) AS 'Employee Hours',
       (SELECT ROUND(AVG(total_hours), 2)
        FROM (SELECT e2.Ssn, SUM(w2.Hours) AS total_hours
              FROM EMPLOYEE e2
              JOIN WORKS_ON w2 ON e2.Ssn = w2.Essn
              WHERE e2.Dno = e.Dno
              GROUP BY e2.Ssn) AS dept_hours
       ) AS 'Department Average',
       CASE
           WHEN SUM(w.Hours) > (SELECT AVG(total_hours)
                               FROM (SELECT e2.Ssn, SUM(w2.Hours) AS total_hours
                                     FROM EMPLOYEE e2
                                     JOIN WORKS_ON w2 ON e2.Ssn = w2.Essn
                                     WHERE e2.Dno = e.Dno
                                     GROUP BY e2.Ssn) AS dept_hours)
           THEN 'Above Average'
           ELSE 'Below Average'
       END AS 'Comparison'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname, d.Dname, e.Dno
ORDER BY d.Dname, SUM(w.Hours) DESC; 