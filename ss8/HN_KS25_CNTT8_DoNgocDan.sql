create database KTThucHanh;
use KTThucHanh;

create table department(
dept_id int primary key auto_increment,
dept_name VARCHAR(100) NOT NULL,
location VARCHAR(100)
);

create table employee(
emp_id int primary key auto_increment,
emp_name varchar(100) not null,
gender INT DEFAULT (1),
birth_date DATE,
salary DECIMAL,
dept_id INT,
foreign key (dept_id) references department(dept_id) ON UPDATE CASCADE
);

create table project(
project_id INT primary key auto_increment,
project_name VARCHAR(150) NOT NULL,
emp_id INT ,
foreign key (emp_id) references employee(emp_id),
start_date DATE DEFAULT(CURRENT_DATE),
end_date DATE
);

-- 2.hay đổi cấu trúc bảng (DDL)

alter table employee
add email VARCHAR(100) UNIQUE;

alter table project 
modify project_name VARCHAR(200);

alter table project 
add constraint end_date check(end_date >= start_date);

-- 3.Thao tác dữ liệu (DML) 
-- 3.1 Thêm mới dữ liệu

insert into department(dept_name,location)
value('IT','Ha Noi'),('HR','HCM'),('Marketing','Da Nang');

insert into employee(emp_name, gender, birth_date ,salary ,dept_id ,email)
value
('Nguyen Van A',1,'1990-01-15',1500, 1,'a@gmail.com'),
('Tran Thi B',0,'1995-05-20',1200,1,'b@gmail.com'),
('Le Minh C',1,'1988-10-10',2000 ,2,'c@gmail.com'),
('Pham Thi D',0,'1992-12-05',1800 ,3,'d@gmail.com');

insert into project
value
(101,'Website Redesign',1,'2024-01-01','2024-06-01'),
(102 ,'Recruitment System', 3 ,'2024-02-01' ,'2024-08-01'),
(103 ,'Marketing Campaign', 4 ,'2024-03-01', NULL);

-- 3.2 Cập nhật dữ liệu
update employee 
set salary = salary + 200
where dept_id = 1;

update project
set end_date = '2024-12-31' 
where end_date is NULL;

-- 3.3  Xóa dữ liệu
delete from project
where start_date < '2024-02-01';

-- 4. Truy vấn dữ liệu nâng cao
-- 4.1 CASE & AS
select emp_name, email , gender
from employee;
-- 4.2 Hàm hệ thống
select upper(emp_name),(current_date())
from employee;
-- 4.3 INNER JOIN
select e.emp_name,e.salary,d.dept_name
from department d inner join employee e on d.dept_id = e.dept_id;
-- 4.4 ORDER BY & LIMIT
select *
from employee
order by salary desc
limit 2;
-- 4.5 GROUP BY & HAVING
select e.emp_name ,count(dept_id) as 'số lượng nhân viên'
from employee e inner join department d on d.dept_id = e.dept_id
GROUP BY dept_id
having count(dept_id) >= 2;
-- 4.6 GROUP BY & HAVING
select emp_name 
from employee
where salary>(select avg(salary)
from employee);

