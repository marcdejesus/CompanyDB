-- Drop Tables If They Exist

DROP TABLE IF EXISTS WORKS_ON;
DROP TABLE IF EXISTS DEPENDENT;
DROP TABLE IF EXISTS DEPT_LOCATIONS;
DROP TABLE IF EXISTS PROJECT;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS DEPARTMENT;


-- Schema Definition

-- DEPARTMENT Table
CREATE TABLE DEPARTMENT (
    Dname VARCHAR(50),
    Dnumber INT PRIMARY KEY,
    Mgr_ssn CHAR(9),
    Mgr_start_date DATE
);

-- EMPLOYEE Table
CREATE TABLE EMPLOYEE (
    Fname VARCHAR(50),
    Minit CHAR(1),
    Lname VARCHAR(50),
    Ssn CHAR(9) PRIMARY KEY,
    Bdate DATE,
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    Super_ssn CHAR(9),
    Dno INT,
    FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber)
);

-- PROJECT Table
CREATE TABLE PROJECT (
    Pname VARCHAR(50),
    Pnumber INT PRIMARY KEY,
    Plocation VARCHAR(50),
    Dnum INT,
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

-- WORKS_ON Table
CREATE TABLE WORKS_ON (
    Essn CHAR(9),
    Pno INT,
    Hours DECIMAL(5,2),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
    FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber)
);

-- DEPENDENT Table
CREATE TABLE DEPENDENT (
    Essn CHAR(9),
    Dependent_name VARCHAR(50),
    Sex CHAR(1),
    Bdate DATE,
    Relationship VARCHAR(50),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn)
);

-- DEPT_LOCATIONS Table
CREATE TABLE DEPT_LOCATIONS (
    Dnumber INT,
    Dlocation VARCHAR(50),
    FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber)
);


-- Data Insertion

-- DEPARTMENT
INSERT INTO DEPARTMENT (Dname, Dnumber, Mgr_ssn, Mgr_start_date) VALUES 
('Research', 5, '333445555', '1988-05-22'),
('Administration', 4, '987654321', '1995-01-01'),
('Headquarters', 1, '888665555', '1981-06-19');

-- EMPLOYEE
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES 
('John', 'B', 'Smith', '123456789', '1965-01-09', '731 Fondren, Houston, TX', 'M', 30000, '333445555', 5),
('Franklin', 'T', 'Wong', '333445555', '1955-12-08', '638 Voss, Houston, TX', 'M', 40000, '888665555', 5),
('Alicia', 'J', 'Zelaya', '999887777', '1968-01-19', '3321 Castle, Spring, TX', 'F', 25000, '987654321', 4),
('Jennifer', 'S', 'Wallace', '987654321', '1941-06-20', '291 Berry, Bellaire, TX', 'F', 43000, '888665555', 4),
('Ramesh', 'K', 'Narayan', '666884444', '1962-09-15', '975 Fire Oak, Humble, TX', 'M', 38000, '333445555', 5),
('Joyce', 'A', 'English', '458453453', '1972-07-31', '5631 Rice, Houston, TX', 'F', 25000, '333445555', 5),
('Ahmad', 'V', 'Jabbar', '987987987', '1969-03-29', '980 Dallas, Houston, TX', 'M', 25000, '987654321', 4),
('James', 'E', 'Borg', '888665555', '1937-11-10', '450 Stone, Houston, TX', 'M', 55000, NULL, 1);

-- PROJECT
INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES 
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

-- WORKS_ON
INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES 
('123456789', 1, 32.5),
('123456789', 2, 7.5),
('666884444', 3, 40.0),
('458453453', 1, 20.0),
('333445555', 2, 20.0),
('333445555', 10, 10.0),
('333445555', 20, 10.0),
('987654321', 30, 30.0),
('888665555', 30, 20.0);

-- DEPENDENT
INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship) VALUES 
('333445555', 'Theodore', 'M', '1983-10-25', 'Son'),
('333445555', 'Joy', 'F', '1986-04-05', 'Daughter'),
('333445555', 'Abner', 'M', '1958-05-03', 'Spouse'),
('987654321', 'Michael', 'M', '1942-02-28', 'Spouse'),
('123456789', 'Alciba', 'F', '1988-01-04', 'Daughter'),
('123456789', 'Elizabeth', 'F', '1967-05-05', 'Spouse');

-- DEPT_LOCATIONS
INSERT INTO DEPT_LOCATIONS (Dnumber, Dlocation) VALUES 
(5, 'Bellaire'),
(4, 'Stafford'),
(1, 'Houston'),
(5, 'Sugarland'),
(5, 'Houston');
