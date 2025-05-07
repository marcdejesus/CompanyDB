# DEPARTMENT table
INSERT INTO DEPARTMENT (Dname, Dnumber, Mgr_ssn, Mgr_start_date) VALUES 
('Research', 5, '333445555', '1988-05-22'),
('Administration', 4, '987654321', '1995-01-01'),
('Headquarters', 1, '888665555', '1981-06-19');

# EMPLOYEE table
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES 
('John', '', '', '123456789', '1965-01-09', '731 Fondren, Houston, TX', 'M', 30000, '333445555', 5),
('Franklin', '', '', '333445555', '1955-12-08', '638 Voss, Houston, TX', 'M', 40000, '888665555', 5),
('Alicia', '', '', '999887777', '1968-01-19', '3321 Castle, Spring, TX', 'F', NULL, '987654321', 4),
('Jennifer', 'W', 'Wallace', '987654321', '1941-06-20', '291 Berry, Bellaire, TX', 'F', NULL, '888665555', 4),
('Ramesh', 'N', 'Narayan', '666884444', '1962-09-15', '975 Fire Oak, Humble, TX', 'M', NULL, '333445555', 5),
('Joyce', 'E', 'English', '458453453', '1972-07-31', '5631 Rice, Houston, TX', 'F', NULL, '333445555', 5),
('Ahmad', '', '', '987987987', '1969-03-29', '980 Dallas, Houston, TX', 'M', NULL, '987654321', 4),
('James', '', '', '888665555', '1937-11-10', '450 Stone, Houston, TX', 'M', 55000, NULL, 1);

# PROJECT table
INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES 
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

# WORKS_ON table
INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES 
('123456789', 1, 32.5),
('123456789', 2, 7.5),
('666884444', 3, 40.0),
('453453453', 1, 20.0),
('333445555', 2, 20.0),
('333445555', 10, 10.0),
('333445555', 20, 10.0),
('987654321', 30, 30.0),
('888665555', 30, 20.0);

# DEPENDENT table
INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship) VALUES 
('333445555', 'Theodore', 'M', '1983-10-25', 'Son'),
('333445555', 'Joy', 'F', '1986-04-05', 'Daughter'),
('333445555', 'Abner', 'M', '1958-05-03', 'Spouse'),
('987654321', 'Michael', 'M', '1942-02-28', 'Spouse'),
('123456789', 'Alciba', 'F', '1988-01-04', 'Daughter'),
('123456789', 'Elizabeth', 'F', '1967-05-05', 'Spouse');

