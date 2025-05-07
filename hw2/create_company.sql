-- Creates the database schema for the COMPANY database.
-- create_company.sql
-- Qiyu Sun
-- ITC 341 Sep. 22, 2023
set echo on linesize 150 pagesize 100

drop table EMPLOYEE cascade constraints;
create table Employee (
	fname varchar2(15),
	minit varchar2(1),
	lname varchar2(15),
	ssn char(9),
	bdate date,
 	address varchar2(50),
	sex varchar2(1) CHECK(Sex = 'M' or Sex = 'F'),
	salary number CHECK(salary between 20000 and 100000),
	superssn char(9),
	dno number DEFAULT 0,
	constraint EMPPK primary key(ssn)
);

drop table DEPARTMENT cascade constraints;
create table Department(
	dname varchar2(15) NOT NULL,
	dnumber number,
	mgrssn char(9) DEFAULT '000000000',
	mgrstartdate date,
	constraint DEPTPK primary key(dnumber),
	constraint DEPTMGRFK foreign key(mgrssn) references Employee(ssn) ON DELETE SET NULL
);

drop table DEPT_LOCATIONS cascade constraints;
create table DEPT_LOCATIONS(
	Dnumber number,
	Dlocation varchar2(20),
	constraint DEPT primary key (Dnumber, Dlocation),
	constraint DEPT_LOCATIONS_Dnumber foreign key (Dnumber) references DEPARTMENT(Dnumber)
);

drop table PROJECT cascade constraints;
create table PROJECT(
	Pname varchar2(15),
	Pnumber number constraint PROJECT_Pnumber primary key,
	Plocation varchar2(15),
	Dnum number,
	constraint PROJECT_Dnum foreign key (Dnum) references DEPARTMENT(Dnumber)
);

drop table WORKS_ON cascade constraints;
create table WORKS_ON(
	Essn char(9),
	Pno number,
	Hours number(5,2),
	constraint WORKS_ON_Essn foreign key (Essn) references EMPLOYEE(Ssn),
	constraint WORKS_ON_Pno foreign key (Pno) references PROJECT(Pnumber)
);

drop table DEPENDENT cascade constraints;
create table DEPENDENT(
	Essn char(9),
	Dependent_name varchar2(10),
	Sex varchar(1),
	Bdate date,
	Relationship varchar2(10),
	constraint DEPENDENT_Name primary key (Essn, Dependent_name),
	constraint DEPENDENT_Essn foreign key (Essn) references EMPLOYEE(Ssn)
);

purge recyclebin;
commit;
--ADD after insert
--alter table EMPLOYEE add constraint EMPLOYEE_Dno foreign key (Dno) references DEPARTMENT(Dnumber) on delete set null;
--You will have to disable constraints if you forget 'on delete set null'.
--Purge recyclebin when deleting tables