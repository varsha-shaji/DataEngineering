CREATE DATABASE company_db;

USE company_db;

CREATE TABLE emp(
	emp_id INT PRIMARY KEY,
	name VARCHAR(50),
	department VARCHAR(50),
	salary DECIMAL(10,2),
	hire_date DATE,
	dept_id INT
);


INSERT INTO emp(emp_id,name,department,salary,hire_date,dept_id)
VALUES(1,'John','IT',35000,'2018-03-06',1),
(2,'Ann','SALES',30000,'2020-02-01',2),
(3,'Sara','SALES',20000,'2025-01-01',2),
(4,'Tom','MARKETTING',50000,'2009-02-07',4),
(5,'Anna','HR',55000,'2022-07-12',3);


select * from employee;
select CURRENT_TIMESTAMP;
select UPPER(name) from employee;
select LEN(name) from employee;
select COUNT(*) from employee;
select AVG(salary) from employee;
select sum(salary) from employee;


CREATE TABLE department(
	dept_id INT PRIMARY KEY,
	dept_name VARCHAR(50)
);
INSERT INTO department(dept_id,dept_name)
VALUES(1,'IT'),
(2,'SALES'),
(3,'HR'),
(4,'MARKETTING');


select e.name,d.dept_name
from emp e
INNER JOIN department d
on e.dept_id=d.dept_id;


select e.name,d.dept_name
from emp e
LEFT JOIN department d
ON e.dept_id=d.dept_id;



select department,count(*)
from emp
group by department;

select ROUND(AVG(salary),2) from emp; 
select MAX(salary),MIN(salary) from emp;


CREATE VIEW high_salary_employees AS
select name,salary 
from emp 
where salary>50000;

select * from high_salary_employees;


select name,salary from emp
where salary>(select AVG(salary) from emp);

select name from emp
where dept_id IN(
select dept_id from department where dept_name='SALES');






create table student(
 id INT PRIMARY KEY,
 name VARCHAR(50),
 course VARCHAR(50),
 loc VARCHAR(50)
)


INSERT INTO student(id,name,course,loc)
VALUES(1,'Ann','MCA','Kottayam'),
(2,'Tom','BCA','Kollam'),
(3,'Amiya','B-Tech','Malappuram'),
(4,'Sobin','B-Tech','Kottayam'),
(5,'Tansya','MCA','Kochi');



select * from student;

select * from student where loc IN('Kottayam','Kochi');
SELECT TOP 2 * 
FROM emp 
ORDER BY salary desc;







create table departments(
	dept_id int primary key not null,
	dept_name varchar(50) unique not null,

)

create table tbl_emp(
id INT PRIMARY KEY NOT NULL,
name VARCHAR(20) NOT NULL,
dept_id int foreign key references departments(dept_id) not null,
salary decimal(10,2) not null,
);


INSERT INTO departments(dept_id,dept_name)
VALUES(1,'IT'),
(2,'SALES'),
(3,'HR'),
(4,'MARKETTING');

INSERT INTO tbl_emp(id,name,salary,dept_id)
VALUES(1,'John',35000,1),
(2,'Ann',30000,2),
(3,'Sara',20000,2),
(4,'Tom',50000,4),
(5,'Anna',55000,3);


select CURRENT_TIMESTAMP;

select UPPER(name) from tbl_emp;
select Lower(name) from tbl_emp;
select CONCAT(id,name) from tbl_emp;
select LEN(name) from tbl_emp;

select count(*) from tbl_emp;
select Sum(salary) as Total_Salary,MAX(salary) as Max_Salary,min(salary) as Min_Salary ,Avg(salary) as Average_Salary from tbl_emp;

select dept_id,avg(salary) from  tbl_emp group by dept_id;

select d.dept_name,avg(e.salary) as Avg_Salary from tbl_emp e JOIN departments d
on e.dept_id=d.dept_id group by e.dept_id;



select e.name ,d.dept_name from tbl_emp e JOIN departments d on e.dept_id=d.dept_id;

insert into departments values(5,'DEVELOPMENT');


select dept_name from departments where dept_id not in(select dept_id from tbl_emp); 

drop table projects
create table projects(
id int primary key not null,
project_name varchar(50) not null,
emp_id int foreign key references tbl_emp(id) not null,
dept_id int foreign key references departments(dept_id) not null,
budget decimal(10,2) not null
);

insert into projects values(1,'Expense tracker',2,2,500000),
(2,'Portfolio',3,2,20000),
(3,'freelance job management system',3,2,100000),
(4,'AI',1,1,250000),
(5,'Finance Management App',5,3,65000),
(6,'Music App',5,3,85000);


select e.id,e.name,COUNT(DISTINCT p.id) AS project_count
from tbl_emp e
JOIN projects p 
ON e.id = p.emp_id
group by e.id, e.name
having COUNT(DISTINCT p.id) > 1
order by project_count DESC;



select d.dept_name,count(*) as emp_count  from tbl_emp e join departments d 
on e.dept_id=d.dept_id
group by d.dept_id,d.dept_name
order by emp_count desc;



select d.dept_name ,avg(e.salary) as AVG_Salary from tbl_emp e join departments d
on e.dept_id=d.dept_id
group by d.dept_id,d.dept_name
having avg(e.salary)>50000
order by d.dept_id desc;


select d.dept_name,sum(p.budget) as Total_Budget from departments d right join projects p 
on d.dept_id=p.dept_id
group by d.dept_id,d.dept_name
order by d.dept_id desc;


select id,name ,salary from tbl_emp where salary>(select avg(salary) from tbl_emp);


select top 3 d.dept_name ,sum(e.salary) as Salary from departments d join tbl_emp e
on e.dept_id=d.dept_id
group by d.dept_id,d.dept_name 
order by d.dept_id desc;


select e.id,e.name,d.dept_name from tbl_emp e join departments d 
on e.dept_id=d.dept_id
where d.dept_name IN('IT','SALES');


select id,name from tbl_emp where exists(select * from projects where projects.emp_id = tbl_emp.id);
select id, name 
from tbl_emp 
where not exists (
    select * from projects where projects.emp_id = tbl_emp.id
);