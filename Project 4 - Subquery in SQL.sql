/*

Subqueries Types : Scalar , Multiple row subquery, Correlated Subquery   
                  (Subqueries use in Select, From, Where, Having, Insert, Update, Delete commands)
*/

create table tbl_employee(
             emp_id int Primary Key, emp_name varchar(50), dept_name varchar(50), salary int);

create table tbl_department(
             dept_id int, dept_name varchar(50), location varchar(100));

insert into tbl_employee
values (101, 'Mohan', 'Admin', 4000),
       (102, 'Rajkumar', 'HR', 3000),
	   (103, 'Akbar', 'IT', 4000),
	   (104, 'Dorvin', 'Finance', 6500),
	   (105, 'Rohit', 'HR', 3000),
	   (106, 'Rajesh', 'Finance', 5000),
	   (107, 'Preet', 'HR', 7000),
	   (108, 'Maryam', 'Admin', 4000),
	   (109, 'Sanjay', 'IT', 6500),
	   (110, 'Vasudha', 'IT', 7000),
	   (111, 'Melinda', 'IT', 8000),
	   (112, 'Komal', 'IT', 10000),
	   (113, 'Gautham', 'Admin', 2000),
	   (114, 'Manisha', 'HR', 3000),
	   (115, 'Chandni', 'IT', 4500),
	   (116, 'Satya', 'Finance', 6500),
	   (117, 'Adarsh', 'HR', 3500),
	   (118, 'Tejaswi', 'Finance', 5500),
	   (119, 'Cory', 'HR', 8000),
	   (120, 'Monica', 'Admin', 5000),
	   (121, 'Rosalin', 'IT', 6000),
	   (122, 'Ibrahim', 'IT', 8000),
	   (123, 'Vikram', 'IT', 8000),
	   (124, 'Dheeraj', 'IT', 11000);

insert into tbl_department
values (1, 'Admin', 'Bangalore'),
       (2, 'HR', 'Bangalore'),
	   (3, 'IT', 'Bangalore'),
	   (4, 'Finance', 'Mumbai'),
	   (5, 'Marketing', 'Bangalore'),
	   (6, 'Sales', 'Mumbai');

create table tbl_sales
            (store_id int, store_name varchar(50), product_name varchar(50), quantity int, price int);

insert into tbl_sales
values (1, 'Apple Store 1', 'iPhone 13 Pro', 1, 1000),
       (1, 'Apple Store 1', 'MacBook pro 14', 3, 6000),
	   (1, 'Apple Store 1', 'AirPods Pro', 2, 500),
	   (2, 'Apple Store 2', 'iPhone 13 Pro', 2, 2000),
	   (3, 'Apple Store 3', 'iPhone 12 Pro', 1, 750),
	   (3, 'Apple Store 3', 'MacBook Pro 14', 1, 2000),
	   (3, 'Apple Store 3', 'MacBook Air', 4, 4400),
	   (3, 'Apple Store 3', 'iPhone 13', 2, 1800),
	   (3, 'Apple Store 3', 'AirPods Pro', 3, 750),
	   (4, 'Apple Store 4', 'iPhone 12 Pro', 2, 1500),
	   (4, 'Apple Store 4', 'MacBook Pro 16', 1, 3500);

select * from tbl_employee;
select * from tbl_department;

--Find the employees who's salary is more than the average salary earned by all employees.
--Using Subquery in where clause
select *
from tbl_employee
where salary > (select avg(salary) from employee);

--There three types of subqueries
--Scalar Subquery
--Multiple row subquery
--Correlated Subquery

--Scalar Subquery
--It always returns 1 row and 1 coloumn.
--Using the same subquery in join condition that is in your from clause 

select *
from tbl_employee e 
join (select avg(salary) sal from employee) avg_sal
on e.salary > avg_sal.sal;
----------------------------------------------------------------------------------------------------
--multiple row subquery
--subquery which returns multiple columns and multiple row
--subquery which returns only 1 column and multiple rows.

--Question : Find the employees who earn the highest salary in each department.
select dept_name, max(salary)
from tbl_employee
group by dept_name;

select *
from tbl_employee
where (dept_name , salary) in (select dept_name, max(salary) 
                              from tbl_employee
							  group by dept_name);

--Single column, multiple row subquery
--Find department who do not have any employees

select *
from tbl_department
where dept_name not in (select distinct dept_name from employee)
----------------------------------------------------------------------------------------------------
--Correlated Subquery
--A subquery which is related to the outer query.
--Find the employees in each department who earn more than the average salary in that department.
select *
from tbl_employee e1
where salary > (select avg(salary)
                from tbl_employee e2
				where e2.dept_name = e1.dept_name
				)

--Find department who do not have any employees
select *
from tbl_department d
where not exists (select 1 from tbl_employee e where e.dept_name = d.dept_name);

--Subquery inside a Subquery
--Find stores who's sales were better than the average sales across all stores.

select *
from tbl_sales;

select *
from (select store_name, sum(price) as total_sales
     from tbl_sales
	 group by store_name) sales
join (select avg(total_sales) as sales 
     from (select store_name, sum(price) as total_sales
	       from tbl_sales
		   group by store_name) x) avg_sales
		on sales.total_sales > avg_sales.sales;

--Modifying the same subquery by using with clause
with sales as 
    (select store_name, sum(price) as total_sales
     from tbl_sales
	 group by store_name)
select *
from sales
join (select avg(total_sales) as sales
     from sales x) avg_sales
	 on sales.total_sales > avg_sales.sales;
----------------------------------------------------------------------------------------------------
--Using a sucquery in select in Select clause.
--Fetch all employee details and add remarks to those employees who earn more than the average pay.
select *
, (case when salary > avg_sal.sal
   then 'Higher than average'
   else null
   end) as remarks
from tbl_employee
cross join (select avg(salary) sal from tbl_employee) avg_sal;

--Having
--Find the stores who have sold more units than the average units sold by all stores.

select store_name, sum(quantity)
from tbl_sales
group by store_name
having sum(quantity) > (select avg(quantity) from tbl_sales);

--Insert
--Insert data to employee_history table. Make sure not insert duplicate records.
select * from employee_history;

create table employee_history(
emp_id int, emp_name varchar(50), dept_name varchar(50), salary int, location varchar(50));

insert into employee_history
select e.emp_id, e.emp_name, d.dept_name, e.salary, d.location
from tbl_employee e
join tbl_department d on d.dept_name = e.dept_name
where not exists(select 1 
               from employee_history eh
			   where eh.emp_id = e.emp_id);
----------------------------------------------------------------------------------------------------
--Update
--Give 10% increment to all employees in Bangalore location based on the maximum salary earned
--by an emp in each dept. Only consider employees in employee_history table.
Update tbl_employee e
set salary = (select max(salary) + (max(salary) * 0.1) 
              from employee_history eh 
			  where eh.dept_name = e.dept_name)
where e.dept_name in (select dept_name
                     from tbl_department
					 where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history);
-----------------------------------------------------------------------------------------------------
--Delete
--Delete all departments who do not have any employees.
select dept_name
from tbl_department d
where not exists (select 1 from tbl_employee e where e.dept_name = d.dept_name);

delete from tbl_department
where dept_name in (select dept_name
                    from tbl_department d
					where not exists (select 1 from tbl_employee e where e.dept_name = d.dept_name)); 

-----------------------------------------------------------------------------------------------------