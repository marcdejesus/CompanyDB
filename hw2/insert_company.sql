-- Insert values for each table of the COMPANY database.
-- insert_company.sql
-- Qiyu Sun
-- ITC 341 Sep. 22, 2023
-- Check user_tables before creation
Insert into EMPLOYEE values('John', 'B', 'Smith', '123456789', to_date('1965-01-09', 'yyyy-mm-dd'), '731 Fondren, Houston, TX', 'M', 30000, '333445555', 5);
Insert into EMPLOYEE values('Franklin', 'T', 'Wong', '333445555', to_date('1955-12-08', 'yyyy-mm-dd'), '638 Voss, Houston, TX', 'M', 40000, '888665555', 5);
Insert into EMPLOYEE values('Alicia', 'J', 'Zelaya', '999887777', to_date('1968-01-19', 'yyyy-mm-dd'), '331 Castle, Spring, TX', 'F', 25000, '987654321', 4);
Insert into EMPLOYEE values('Jennifer', 'S', 'Wallace', '987654321', to_date('1941-06-20', 'yyyy-mm-dd'), '291 Berry, Bellaire, TX', 'F', 43000, '888665555', 4);
Insert into EMPLOYEE values('Ramesh', 'K', 'Narayan', '666884444', to_date('1962-09-15', 'yyyy-mm-dd'), '975 Fire Oak, Humble, TX', 'M', 38000, '333445555', 5);
Insert into EMPLOYEE values('Joyce', 'A', 'English', '453453453', to_date('1972-07-31', 'yyyy-mm-dd'), '5631 Rice, Houston, TX', 'F', 25000, '333445555', 5);
Insert into EMPLOYEE values('Ahmad', 'V', 'Jabbar', '987987987', to_date('1969-03-29', 'yyyy-mm-dd'), '980 Dallas, Houston, TX', 'M', 25000, '987654321', 4);
Insert into EMPLOYEE values('James', 'E', 'Borg', '888665555', to_date('1937-11-10', 'yyyy-mm-dd'), '450 Stone, Houston, TX', 'M', 55000, NULL, 1);
--
insert into DEPARTMENT values('Research', 5, '333445555', to_date('1988-05-22', 'yyyy-mm-dd'));
insert into DEPARTMENT values('Administration', 4, '987654321', to_date('1995-01-01', 'yyyy-mm-dd'));
insert into DEPARTMENT values('Headquarters', 1, '888665555', to_date('1981-06-19', 'yyyy-mm-dd'));
--
insert into DEPT_LOCATIONS values(1, 'Houston');
insert into DEPT_LOCATIONS values(4, 'Stafford');
insert into DEPT_LOCATIONS values(5, 'Bellaire');
insert into DEPT_LOCATIONS values(5, 'Sugarland');
insert into DEPT_LOCATIONS values(5, 'Houston');
--
insert into PROJECT values('ProductX', 1, 'Bellaire', 5);
insert into PROJECT values('ProductY', 2, 'Sugarland', 5);
insert into PROJECT values('ProductZ', 3, 'Houston', 5);
insert into PROJECT values('Computerization', 10, 'Stafford', 4);
insert into PROJECT values('Reorganization', 20, 'Houstion', 1);
insert into PROJECT values('Newbenefits', 30, 'Stafford', 4);
--
insert into WORKS_ON values('123456789', 1, 32.5);
insert into WORKS_ON values('123456789', 2, 7.5);
insert into WORKS_ON values('666884444', 3, 40.0);
insert into WORKS_ON values('453453453', 1, 20.0);
insert into WORKS_ON values('453453453', 2, 20.0);
insert into WORKS_ON values('333445555', 2, 10.0);
insert into WORKS_ON values('333445555', 3, 10.0);
insert into WORKS_ON values('333445555', 10, 10.0);
insert into WORKS_ON values('333445555', 20, 10.0);
insert into WORKS_ON values('999887777', 30, 30.0);
insert into WORKS_ON values('999887777', 10, 10.0);
insert into WORKS_ON values('987987987', 10, 35.0);
insert into WORKS_ON values('987987987', 30, 5.0);
insert into WORKS_ON values('987654321', 30, 20.0);
insert into WORKS_ON values('987654321', 20, 15.0);
insert into WORKS_ON values('888665555', 20, NULL);
--
insert into DEPENDENT values('333445555', 'Alice', 'F', to_date('1988-04-05', 'yyyy-mm-dd'), 'Daughter');
insert into DEPENDENT values('333445555', 'Theodore', 'M', to_date('1983-10-25', 'yyyy-mm-dd'), 'Son');
insert into DEPENDENT values('333445555', 'Joy', 'F', to_date('1958-05-03', 'yyyy-mm-dd'), 'Spouse');
insert into DEPENDENT values('987654321', 'Abner', 'M', to_date('1942-02-28', 'yyyy-mm-dd'), 'Spouse');
insert into DEPENDENT values('123456789', 'Michael', 'M', to_date('1988-01-04', 'yyyy-mm-dd'), 'Son');
insert into DEPENDENT values('123456789', 'Alice', 'F', to_date('1988-12-30', 'yyyy-mm-dd'), 'Daughter');
insert into DEPENDENT values('123456789', 'Elizabeth', 'F', to_date('1967-05-05', 'yyyy-mm-dd'), 'Spouse');

alter table EMPLOYEE add constraint EMPLOYEE_Dno foreign key (Dno) references DEPARTMENT(Dnumber) on delete set null;
alter table EMPLOYEE add constraint EMPLOYEE_SUPERSSN foreign key (superssn) references EMPLOYEE(Ssn) on delete set null;