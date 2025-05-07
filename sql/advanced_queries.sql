-- CompanyDB Advanced Queries
-- Complex but practical SQL queries for database analysis

-- 1. Employee project involvement analysis with recursive CTE
-- Shows complete employee hierarchy with total projects and hours at each level
WITH RECURSIVE EmployeeHierarchy AS (
    -- Base case: top-level employees (no supervisor)
    SELECT 
        e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS FullName,
        e.Super_ssn, 0 AS Level, e.Dno
    FROM EMPLOYEE e
    WHERE e.Super_ssn IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with supervisors
    SELECT 
        e.Ssn, CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname),
        e.Super_ssn, eh.Level + 1, e.Dno
    FROM EMPLOYEE e
    JOIN EmployeeHierarchy eh ON e.Super_ssn = eh.Ssn
)
SELECT 
    eh.Level,
    CONCAT(REPEAT('    ', eh.Level), eh.FullName) AS 'Employee Hierarchy',
    d.Dname AS 'Department',
    COUNT(DISTINCT w.Pno) AS 'Projects',
    COALESCE(SUM(w.Hours), 0) AS 'Total Hours'
FROM EmployeeHierarchy eh
LEFT JOIN WORKS_ON w ON eh.Ssn = w.Essn
LEFT JOIN DEPARTMENT d ON eh.Dno = d.Dnumber
GROUP BY eh.Ssn, eh.Level, eh.FullName, d.Dname
ORDER BY eh.Level, eh.FullName;

-- 2. Departmental productivity analysis using window functions
SELECT 
    d.Dname AS 'Department',
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    SUM(w.Hours) AS 'Total Hours',
    ROUND(AVG(SUM(w.Hours)) OVER (PARTITION BY d.Dnumber), 2) AS 'Dept Avg Hours',
    ROUND(SUM(w.Hours) / AVG(SUM(w.Hours)) OVER (PARTITION BY d.Dnumber) * 100, 2) AS 'Productivity %',
    RANK() OVER (PARTITION BY d.Dnumber ORDER BY SUM(w.Hours) DESC) AS 'Dept Rank'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
GROUP BY d.Dnumber, d.Dname, e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY d.Dname, SUM(w.Hours) DESC;

-- 3. Project resource allocation efficiency analysis
SELECT 
    p.Pnumber, p.Pname AS 'Project',
    COUNT(DISTINCT w.Essn) AS 'Team Size',
    SUM(w.Hours) AS 'Total Hours',
    ROUND(SUM(w.Hours) / COUNT(DISTINCT w.Essn), 2) AS 'Hours Per Employee',
    ROUND(
        (SUM(w.Hours) / COUNT(DISTINCT w.Essn)) / 
        (SELECT AVG(Hours) FROM WORKS_ON) * 100, 
    2) AS 'Efficiency %'
FROM PROJECT p
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY p.Pnumber, p.Pname
HAVING COUNT(DISTINCT w.Essn) > 0
ORDER BY (SUM(w.Hours) / COUNT(DISTINCT w.Essn)) DESC;

-- 4. Employee skill distribution across projects using GROUP_CONCAT
-- Note: This simulates skills based on project names (since we don't have a skills table)
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    COUNT(DISTINCT w.Pno) AS 'Number of Projects',
    GROUP_CONCAT(DISTINCT p.Pname ORDER BY p.Pname SEPARATOR ', ') AS 'Projects',
    GROUP_CONCAT(DISTINCT p.Plocation ORDER BY p.Plocation SEPARATOR ', ') AS 'Locations'
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN PROJECT p ON w.Pno = p.Pnumber
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY COUNT(DISTINCT w.Pno) DESC;

-- 5. Multi-level aggregation: Department, location, and project summary
SELECT 
    d.Dname AS 'Department',
    dl.Dlocation AS 'Location',
    COUNT(DISTINCT p.Pnumber) AS 'Projects',
    COUNT(DISTINCT e.Ssn) AS 'Employees',
    SUM(w.Hours) AS 'Total Hours'
FROM DEPARTMENT d
LEFT JOIN DEPT_LOCATIONS dl ON d.Dnumber = dl.Dnumber
LEFT JOIN PROJECT p ON d.Dnumber = p.Dnum
LEFT JOIN WORKS_ON w ON p.Pnumber = w.Pno
LEFT JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dnumber, d.Dname, dl.Dlocation WITH ROLLUP
HAVING GROUPING(d.Dname) = 0 -- Filter out the grand total row
ORDER BY d.Dname, dl.Dlocation;

-- 6. Employee absence from projects (division query)
-- Find employees who don't work on any project located in 'Houston'
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    d.Dname AS 'Department'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
WHERE NOT EXISTS (
    SELECT 1 
    FROM PROJECT p
    WHERE p.Plocation = 'Houston'
    AND EXISTS (
        SELECT 1 
        FROM WORKS_ON w
        WHERE w.Essn = e.Ssn AND w.Pno = p.Pnumber
    )
)
ORDER BY d.Dname, e.Lname, e.Fname;

-- 7. Dynamic pivot: Hours worked by employee across projects
-- This emulates a PIVOT operation (not supported directly in MySQL)
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    SUM(CASE WHEN p.Pname = 'ProductX' THEN w.Hours ELSE 0 END) AS 'ProductX',
    SUM(CASE WHEN p.Pname = 'ProductY' THEN w.Hours ELSE 0 END) AS 'ProductY',
    SUM(CASE WHEN p.Pname = 'ProductZ' THEN w.Hours ELSE 0 END) AS 'ProductZ',
    SUM(CASE WHEN p.Pname = 'Computerization' THEN w.Hours ELSE 0 END) AS 'Computerization',
    SUM(CASE WHEN p.Pname = 'Reorganization' THEN w.Hours ELSE 0 END) AS 'Reorganization',
    SUM(CASE WHEN p.Pname = 'Newbenefits' THEN w.Hours ELSE 0 END) AS 'Newbenefits',
    SUM(w.Hours) AS 'Total Hours'
FROM EMPLOYEE e
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
LEFT JOIN PROJECT p ON w.Pno = p.Pnumber
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname
ORDER BY SUM(w.Hours) DESC;

-- 8. Complex subquery: Find employees who work on all projects that James Borg's direct reports work on
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee'
FROM EMPLOYEE e
WHERE NOT EXISTS (
    -- For all projects worked on by Borg's direct reports
    SELECT DISTINCT w.Pno
    FROM WORKS_ON w
    JOIN EMPLOYEE subordinate ON w.Essn = subordinate.Ssn
    WHERE subordinate.Super_ssn = (SELECT Ssn FROM EMPLOYEE WHERE Fname = 'James' AND Lname = 'Borg')
    
    -- Check if there's any project not worked on by the current employee
    AND NOT EXISTS (
        SELECT 1
        FROM WORKS_ON w2
        WHERE w2.Essn = e.Ssn AND w2.Pno = w.Pno
    )
)
-- Exclude James Borg himself and his direct reports
AND e.Ssn != (SELECT Ssn FROM EMPLOYEE WHERE Fname = 'James' AND Lname = 'Borg')
AND e.Super_ssn != (SELECT Ssn FROM EMPLOYEE WHERE Fname = 'James' AND Lname = 'Borg');

-- 9. Project efficiency with salary cost analysis
SELECT 
    p.Pnumber, p.Pname AS 'Project Name',
    SUM(w.Hours) AS 'Total Hours',
    COUNT(DISTINCT w.Essn) AS 'Employees Assigned',
    ROUND(SUM(e.Salary * w.Hours / 40), 2) AS 'Estimated Labor Cost',
    ROUND(SUM(e.Salary * w.Hours / 40) / SUM(w.Hours), 2) AS 'Cost Per Hour'
FROM PROJECT p
JOIN WORKS_ON w ON p.Pnumber = w.Pno
JOIN EMPLOYEE e ON w.Essn = e.Ssn
GROUP BY p.Pnumber, p.Pname
ORDER BY (SUM(e.Salary * w.Hours / 40) / SUM(w.Hours)) ASC;

-- 10. Organizational network analysis: Find most connected employees
-- Based on combined direct reports, project colleagues, and same-department colleagues
WITH 
ProjectColleagues AS (
    -- Employees who work on the same projects
    SELECT 
        e1.Ssn AS Employee1,
        e2.Ssn AS Employee2
    FROM EMPLOYEE e1
    JOIN WORKS_ON w1 ON e1.Ssn = w1.Essn
    JOIN WORKS_ON w2 ON w1.Pno = w2.Pno
    JOIN EMPLOYEE e2 ON w2.Essn = e2.Ssn
    WHERE e1.Ssn < e2.Ssn -- Avoid duplicates
),
DepartmentColleagues AS (
    -- Employees in the same department
    SELECT 
        e1.Ssn AS Employee1,
        e2.Ssn AS Employee2
    FROM EMPLOYEE e1
    JOIN EMPLOYEE e2 ON e1.Dno = e2.Dno
    WHERE e1.Ssn < e2.Ssn -- Avoid duplicates
),
SupervisorRelationships AS (
    -- Direct supervisor-subordinate relationships
    SELECT 
        Super_ssn AS Employee1,
        Ssn AS Employee2
    FROM EMPLOYEE
    WHERE Super_ssn IS NOT NULL
)
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    d.Dname AS 'Department',
    COUNT(DISTINCT 
        CASE WHEN sr.Employee1 = e.Ssn THEN sr.Employee2
             WHEN sr.Employee2 = e.Ssn THEN sr.Employee1
             ELSE NULL 
        END
    ) AS 'Direct Reports',
    COUNT(DISTINCT 
        CASE WHEN pc.Employee1 = e.Ssn THEN pc.Employee2
             WHEN pc.Employee2 = e.Ssn THEN pc.Employee1
             ELSE NULL 
        END
    ) AS 'Project Colleagues',
    COUNT(DISTINCT 
        CASE WHEN dc.Employee1 = e.Ssn THEN dc.Employee2
             WHEN dc.Employee2 = e.Ssn THEN dc.Employee1
             ELSE NULL 
        END
    ) AS 'Department Colleagues',
    COUNT(DISTINCT 
        CASE WHEN pc.Employee1 = e.Ssn THEN pc.Employee2
             WHEN pc.Employee2 = e.Ssn THEN pc.Employee1
             WHEN dc.Employee1 = e.Ssn THEN dc.Employee2
             WHEN dc.Employee2 = e.Ssn THEN dc.Employee1
             WHEN sr.Employee1 = e.Ssn THEN sr.Employee2
             WHEN sr.Employee2 = e.Ssn THEN sr.Employee1
             ELSE NULL 
        END
    ) AS 'Total Connections'
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
LEFT JOIN SupervisorRelationships sr ON e.Ssn = sr.Employee1 OR e.Ssn = sr.Employee2
LEFT JOIN ProjectColleagues pc ON e.Ssn = pc.Employee1 OR e.Ssn = pc.Employee2
LEFT JOIN DepartmentColleagues dc ON e.Ssn = dc.Employee1 OR e.Ssn = dc.Employee2
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname, d.Dname
ORDER BY COUNT(DISTINCT 
    CASE WHEN pc.Employee1 = e.Ssn THEN pc.Employee2
         WHEN pc.Employee2 = e.Ssn THEN pc.Employee1
         WHEN dc.Employee1 = e.Ssn THEN dc.Employee2
         WHEN dc.Employee2 = e.Ssn THEN dc.Employee1
         WHEN sr.Employee1 = e.Ssn THEN sr.Employee2
         WHEN sr.Employee2 = e.Ssn THEN sr.Employee1
         ELSE NULL 
    END
) DESC;

-- 11. Temporal analysis: Management tenure relationship to team size
SELECT 
    d.Dname AS 'Department',
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Manager',
    d.Mgr_start_date,
    TIMESTAMPDIFF(YEAR, d.Mgr_start_date, CURDATE()) AS 'Years as Manager',
    COUNT(emp.Ssn) AS 'Team Size',
    COUNT(DISTINCT p.Pnumber) AS 'Projects Managed'
FROM DEPARTMENT d
JOIN EMPLOYEE e ON d.Mgr_ssn = e.Ssn
LEFT JOIN EMPLOYEE emp ON emp.Dno = d.Dnumber
LEFT JOIN PROJECT p ON p.Dnum = d.Dnumber
GROUP BY d.Dnumber, d.Dname, e.Ssn, e.Fname, e.Minit, e.Lname, d.Mgr_start_date
ORDER BY TIMESTAMPDIFF(YEAR, d.Mgr_start_date, CURDATE()) DESC;

-- 12. Full outer join simulation (MySQL doesn't support FULL OUTER JOIN)
-- Find all departments and projects, showing relationships even when they don't match
SELECT 
    d.Dnumber, d.Dname,
    p.Pnumber, p.Pname
FROM DEPARTMENT d
LEFT JOIN PROJECT p ON d.Dnumber = p.Dnum

UNION

SELECT 
    d.Dnumber, d.Dname,
    p.Pnumber, p.Pname
FROM PROJECT p
LEFT JOIN DEPARTMENT d ON p.Dnum = d.Dnumber
WHERE d.Dnumber IS NULL;

-- 13. Multi-dimensional analysis with filtering: Age groups, gender, and project involvement
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) < 30 THEN 'Under 30'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 30 AND 40 THEN '30-40'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 41 AND 50 THEN '41-50'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Over 60'
    END AS 'Age Group',
    e.Sex AS 'Gender',
    COUNT(DISTINCT e.Ssn) AS 'Number of Employees',
    ROUND(AVG(e.Salary), 2) AS 'Average Salary',
    ROUND(AVG(proj_count.project_count), 2) AS 'Avg Projects Per Employee'
FROM EMPLOYEE e
LEFT JOIN (
    SELECT w.Essn, COUNT(DISTINCT w.Pno) AS project_count
    FROM WORKS_ON w
    GROUP BY w.Essn
) proj_count ON e.Ssn = proj_count.Essn
GROUP BY 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) < 30 THEN 'Under 30'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 30 AND 40 THEN '30-40'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 41 AND 50 THEN '41-50'
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Over 60'
    END,
    e.Sex
ORDER BY 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) < 30 THEN 1
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 30 AND 40 THEN 2
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 41 AND 50 THEN 3
        WHEN TIMESTAMPDIFF(YEAR, e.Bdate, CURDATE()) BETWEEN 51 AND 60 THEN 4
        ELSE 5
    END,
    e.Sex;

-- 14. Self-join analysis: Find potential mentoring relationships
-- Based on department, experience (age), and project overlap
SELECT 
    CONCAT(senior.Fname, ' ', senior.Minit, '. ', senior.Lname) AS 'Potential Mentor',
    TIMESTAMPDIFF(YEAR, senior.Bdate, CURDATE()) AS 'Mentor Age',
    CONCAT(junior.Fname, ' ', junior.Minit, '. ', junior.Lname) AS 'Potential Mentee',
    TIMESTAMPDIFF(YEAR, junior.Bdate, CURDATE()) AS 'Mentee Age',
    d.Dname AS 'Department',
    COUNT(DISTINCT project_overlap.Pno) AS 'Common Projects'
FROM EMPLOYEE senior
JOIN EMPLOYEE junior ON senior.Dno = junior.Dno
JOIN DEPARTMENT d ON senior.Dno = d.Dnumber
JOIN (
    -- Projects that both senior and junior work on
    SELECT w1.Essn AS senior_ssn, w2.Essn AS junior_ssn, w1.Pno
    FROM WORKS_ON w1
    JOIN WORKS_ON w2 ON w1.Pno = w2.Pno
) project_overlap ON senior.Ssn = project_overlap.senior_ssn AND junior.Ssn = project_overlap.junior_ssn
WHERE 
    TIMESTAMPDIFF(YEAR, senior.Bdate, junior.Bdate) >= 10 -- At least 10 years age difference
    AND senior.Ssn != junior.Ssn -- Not the same person
GROUP BY senior.Ssn, junior.Ssn, senior.Fname, senior.Minit, senior.Lname, 
         junior.Fname, junior.Minit, junior.Lname, d.Dname
HAVING COUNT(DISTINCT project_overlap.Pno) > 0 -- Must have at least one project in common
ORDER BY COUNT(DISTINCT project_overlap.Pno) DESC, senior.Lname, junior.Lname;

-- 15. Family-friendly analysis: Employees with dependents and their work patterns
SELECT 
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname) AS 'Employee',
    COUNT(DISTINCT d.Dependent_name) AS 'Number of Dependents',
    SUM(w.Hours) AS 'Total Work Hours',
    COUNT(DISTINCT w.Pno) AS 'Number of Projects',
    ROUND(SUM(w.Hours) / COUNT(DISTINCT w.Pno), 2) AS 'Hours per Project',
    d.Dname AS 'Department'
FROM EMPLOYEE e
LEFT JOIN DEPENDENT dep ON e.Ssn = dep.Essn
LEFT JOIN WORKS_ON w ON e.Ssn = w.Essn
JOIN DEPARTMENT d ON e.Dno = d.Dnumber
GROUP BY e.Ssn, e.Fname, e.Minit, e.Lname, d.Dname
ORDER BY COUNT(DISTINCT dep.Dependent_name) DESC, SUM(w.Hours) DESC; 