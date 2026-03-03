create database employeeAnalytics;

use employeeAnalytics;

create table Departments(
dept_id int primary key,
dept_name varchar(50) not null 
);

create table Locations(
location_id int primary key,
locatio_name varchar(50) not null 
);

create table Job_Roles(
role_id int primary key,
role_name varchar(50) not null,
min_salary decimal(10,2),
max_salary decimal(10,2)
);

create table employees(
emp_id int primary key,
emp_name varchar(100) not null,
gender varchar(10),
dept_id int,
role_id int,
location_id int,
join_date date,
status varchar(20) default 'Active',
Foreign key(dept_id) references Departments(dept_id),
Foreign key(role_id) references Job_Roles(role_id),
Foreign key(location_id) references Locations(location_id)
);

create table Salaries(
salary_id int primary key,
emp_id int,
salary decimal(10,2),
effective_date date,
foreign key(emp_id) references employees(emp_id)
);



create table Performance_Reviews(
review_id int primary key,
emp_id int,
review_year int,
rating decimal(2,1) check(rating between 1 and 5),
foreign key(emp_id) references employees(emp_id)
);


BULK INSERT Departments
FROM 'D:\Departments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
BULK INSERT Locations
FROM 'D:\Locations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
BULK INSERT Job_Roles
FROM 'D:\job_roles.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
BULK INSERT employees
FROM 'D:\employees.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
BULK INSERT Salaries
FROM 'D:\salaries.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
BULK INSERT Performance_reviews
FROM 'D:\Performance_reviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
select * from Performance_Reviews;

-- 1..Top 10 high performing employees

select top 10 e.emp_id ,e.emp_name,avg(pr.rating) as Average_Rating
from employees e join Performance_Reviews pr on 
e.emp_id = pr.emp_id
group by e.emp_id,e.emp_name 
order by avg(pr.rating) desc;

-- 2.Average rating per department


select d.dept_id,d.dept_name,round(avg(pr.rating),2) as Average_Rating from Departments d join employees e 
on e.dept_id=d.dept_id
join Performance_Reviews pr
on e.emp_id=pr.emp_id
where e.status='Active'
group by d.dept_id,d.dept_name
order by avg(pr.rating) desc;


-- 3.Employees eligible for promotion(rating>4 & 2+ years)


select e.emp_id,e.emp_name,pr.rating from employees e 
join Performance_Reviews pr
on e.emp_id =pr.emp_id
where pr.rating>4 and 
datediff(year, e.join_date, getdate()) >= 2;


-- 4.performance trend over years
select 
    review_year,
    AVG(rating) AS avg_rating
from Performance_Reviews
group by review_year
order by review_year;


--Salary Analytics
-- 5.Salary distribution per department

select d.dept_id,d.dept_name,avg(s.salary) as Average_Salary
from Departments d join
employees e
on e.dept_id=d.dept_id
join salaries s
on s.emp_id=s.emp_id
group by d.dept_id,d.dept_name
order by Average_Salary;


-- 6.Highest and lowest salary per role

select r.role_id,r.role_name,max(s.salary) as Highest_Salary,min(s.salary) as Lowest_Salary from Job_Roles r
join employees e
on e.role_id=r.role_id
join  Salaries s
on s.emp_id=e.emp_id
group by r.role_id,r.role_name
order by Highest_Salary desc;

-- 7.Salary vs Performance Correlation
select e.emp_id,e.emp_name,s.salary,pr.rating from employees e
join Salaries s
on s.emp_id=e.emp_id
join Performance_Reviews pr
on pr.emp_id=e.emp_id
order by e.emp_id;

-- 8.Employees below department avaerage salary
select e.emp_id,e.emp_name,d.dept_name,s.salary from employees e
join Departments d 
on e.dept_id=d.dept_id
join salaries s
on s.emp_id=e.emp_id
where s.salary<(select avg(s2.salary) from employees e2
join Salaries s2
on e2.emp_id =s2.emp_id
where e2.dept_id=e.dept_id);

-- Department  Growth

-- 9.Hiring Trend Per year
select year(join_date) as Year,count(*) as 'No of Employees Hired' from employees 
group by YEAR(join_date);


-- 10.HeadCount growth by department

select d.dept_id,d.dept_name ,year(e.join_date) as 'Year',count(e.emp_id) as HeadCount from Departments d 
join employees e
on e.dept_id=d.dept_id
group by d.dept_id,d.dept_name,year(e.join_date)
order by d.dept_id,d.dept_name,year(e.join_date),HeadCount;

-- 11.Attrition rate by department



--Strategic Insights
-- 12.Employees overdue for promotion

select e.emp_id,e.emp_name,pr.rating from employees e join Performance_Reviews pr 
on e.emp_id=pr.emp_id
where pr.rating>4
order by pr.rating desc;


-- 13.High Salary but low performance cases
select e.emp_id,e.emp_name,s.salary,pr.rating from employees e
join salaries s
on e.emp_id=s.emp_id
join Performance_Reviews pr
on e.emp_id=pr.emp_id
where s.salary>(select avg(salary) from salaries)
and pr.rating<4
order by s.salary desc,pr.rating desc;



-- 14.Most stable department(lowest attrition)

-- 15.Attendence vs performance analysis
-- 16.Location-wise salary comparison
select l.location_id,l.locatio_name,sum(s.salary) as Salary from Locations l
join employees e
on e.location_id=l.location_id
join Salaries s
on s.emp_id=e.emp_id
group by l.location_id,l.locatio_name
order by Salary desc;

-- 17.Gender diversity ratio

select gender,count(*) as total,count(*)*100/(select count(*) from employees) as percentage
from employees group by gender;

-- 18.Median Salary calculation
with ranked as(
select salary,
 ROW_NUMBER() over(order by salary) as row_num,
 count(*) over() as total
 from Salaries
)
select  avg(salary) as AverageSalary
from ranked 
where row_num in ((total + 1)/2, (total + 2)/2);


-- 19.Employees with multiple promotions

-- 20.Identify leadership pipeline candidates

select e.emp_id,e.emp_name,pr.rating,datediff(year, e.join_date, getdate()) as Experience from employees e 
join Performance_Reviews pr
on e.emp_id =pr.emp_id
where pr.rating>4.5 and 
datediff(year, e.join_date, getdate()) >= 10
order by Experience desc;
