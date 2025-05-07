-- CompanyDB Setup Script
-- Creates the database schema for a company management system

-- Drop existing tables if they exist
DROP TABLE IF EXISTS Works_On;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

-- Create Department table
CREATE TABLE Department (
    Dno INT PRIMARY KEY,
    Dname VARCHAR(100) NOT NULL,
    Manager_ssn CHAR(9),
    Manager_start_date DATE
);

-- Create Employee table
CREATE TABLE Employee (
    Ssn CHAR(9) PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    Salary DECIMAL(10, 2),
    Super_ssn CHAR(9),
    Dno INT,
    FOREIGN KEY (Super_ssn) REFERENCES Employee(Ssn) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (Dno) REFERENCES Department(Dno) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Add Manager_ssn foreign key to Department after Employee table is created
ALTER TABLE Department
ADD CONSTRAINT fk_manager_ssn
FOREIGN KEY (Manager_ssn) REFERENCES Employee(Ssn) ON DELETE SET NULL ON UPDATE CASCADE;

-- Create Project table
CREATE TABLE Project (
    Pno INT PRIMARY KEY,
    Pname VARCHAR(100) NOT NULL,
    Dno INT,
    FOREIGN KEY (Dno) REFERENCES Department(Dno) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Create Works_On junction table
CREATE TABLE Works_On (
    Essn CHAR(9),
    Pno INT,
    Hours DECIMAL(5, 2),
    PRIMARY KEY (Essn, Pno),
    FOREIGN KEY (Essn) REFERENCES Employee(Ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Pno) REFERENCES Project(Pno) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Insert sample data for Department
INSERT INTO Department (Dno, Dname) VALUES
(1, 'Research'),
(2, 'Administration'),
(3, 'Development'),
(4, 'Finance'),
(5, 'Marketing');

-- Insert sample data for Employee
INSERT INTO Employee (Ssn, Fname, Lname, Salary, Dno) VALUES
('123456789', 'John', 'Smith', 65000.00, 1),
('987654321', 'Jane', 'Doe', 72000.00, 2),
('555666777', 'David', 'Johnson', 67000.00, 3),
('111222333', 'Mary', 'Jones', 55000.00, 1),
('444555666', 'Michael', 'Brown', 59000.00, 2),
('777888999', 'Sarah', 'Davis', 61000.00, 3),
('222333444', 'Thomas', 'Wilson', 58000.00, 4),
('888999000', 'Emily', 'Taylor', 63000.00, 5);

-- Update Supervisor relationships
UPDATE Employee SET Super_ssn = '123456789' WHERE Ssn IN ('111222333', '555666777');
UPDATE Employee SET Super_ssn = '987654321' WHERE Ssn IN ('444555666', '222333444');
UPDATE Employee SET Super_ssn = '555666777' WHERE Ssn IN ('777888999', '888999000');

-- Update Department managers
UPDATE Department SET Manager_ssn = '123456789', Manager_start_date = '2020-01-15' WHERE Dno = 1;
UPDATE Department SET Manager_ssn = '987654321', Manager_start_date = '2019-06-20' WHERE Dno = 2;
UPDATE Department SET Manager_ssn = '555666777', Manager_start_date = '2021-03-10' WHERE Dno = 3;
UPDATE Department SET Manager_ssn = '222333444', Manager_start_date = '2022-02-05' WHERE Dno = 4;
UPDATE Department SET Manager_ssn = '888999000', Manager_start_date = '2021-09-30' WHERE Dno = 5;

-- Insert sample data for Project
INSERT INTO Project (Pno, Pname, Dno) VALUES
(1, 'ProductX', 1),
(2, 'ProductY', 1),
(3, 'ProductZ', 3),
(10, 'Computerization', 2),
(20, 'Reorganization', 4),
(30, 'Newbenefits', 5);

-- Insert sample data for Works_On
INSERT INTO Works_On (Essn, Pno, Hours) VALUES
('123456789', 1, 32.5),
('123456789', 2, 7.5),
('555666777', 1, 20.0),
('555666777', 3, 20.0),
('111222333', 1, 10.0),
('111222333', 2, 10.0),
('444555666', 10, 35.0),
('777888999', 3, 40.0),
('222333444', 20, 15.0),
('888999000', 30, 30.0);

-- Display success message
SELECT 'CompanyDB setup completed successfully!' AS 'Setup Status'; 