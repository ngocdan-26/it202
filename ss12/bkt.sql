CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- Xóa các bảng cũ nếu đã tồn tại để làm sạch dữ liệu trước khi chấm/làm bài
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS department;
SET FOREIGN_KEY_CHECKS = 1;



-- Bảng department (Thông tin khoa)
CREATE TABLE department (
    dept_id VARCHAR(5) PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- Bảng student (Thông tin sinh viên)
CREATE TABLE student (
    student_id VARCHAR(6) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    birth_date DATE,
    dept_id VARCHAR(5),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Bảng course (Thông tin môn học)
CREATE TABLE course (
    course_id VARCHAR(6) PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    credits INT
);

-- Bảng enrollment (Sinh viên đăng ký môn học)
CREATE TABLE enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(6),
    course_id VARCHAR(6),
    score DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    CONSTRAINT unique_student_course UNIQUE (student_id, course_id)
);



-- Chèn dữ liệu vào bảng department
INSERT INTO department (dept_id, dept_name) VALUES
('IT', 'Information Technology'),
('ME', 'Mechanical Engineering'),
('BA', 'Business Administration');

-- Chèn dữ liệu vào bảng student
INSERT INTO student (student_id, full_name, gender, birth_date, dept_id) VALUES
('SV0001', 'Nguyen Van An', 'Male', '2004-05-15', 'IT'),
('SV0002', 'Tran Thi Binh', 'Female', '2004-09-20', 'IT'),
('SV0003', 'Le Hoang Cao', 'Male', '2003-11-02', 'ME'),
('SV0004', 'Pham Minh Dang', 'Male', '2004-02-28', 'IT'),
('SV0005', 'Vu Hoang Yen', 'Female', '2004-07-12', 'BA');

-- Chèn dữ liệu vào bảng course
INSERT INTO course (course_id, course_name, credits) VALUES
('C00001', 'Database Systems', 3),
('C00002', 'Java Programming', 4),
('C00003', 'Marketing Basics', 2);

-- Chèn dữ liệu vào bảng enrollment
INSERT INTO enrollment (student_id, course_id, score) VALUES
('SV0001', 'C00001', 8.50),  -- Sinh viên khoa IT
('SV0002', 'C00001', 9.50),  -- Sinh viên khoa IT (Thiết lập đồng điểm cao nhất môn C00001)
('SV0003', 'C00001', 9.50),  -- Sinh viên khoa ME (Thiết lập đồng điểm cao nhất môn C00001)
('SV0004', 'C00001', 7.00),  -- Sinh viên khoa IT
('SV0001', 'C00002', 6.00),
('SV0002', 'C00002', 8.00),
('SV0005', 'C00003', 9.00);
-- Phần A
-- câu 1:
create view view_student_basic as
select student_id,full_name,dept_name
from student s join  department d on s.dept_id = d.dept_id;
select * from view_student_basic;
-- câu 2:
create index idx_full_name on student(full_name);
-- câu 3:
delimiter //
create procedure get_students_it ()
begin 
select s.student_id,s.full_name,s.birth_date,s.dept_id,d.dept_name
from student s join department d on s.dept_id = d.dept_id
where d.dept_name = 'Information Technology' ;
end//
delimiter ;
call get_students_it();
-- Phần B
-- Câu 4:
-- a,
create view view_student_count_by_dept as
select d.dept_name, count(d.dept_id)  as total_students 
from student s join department d on s.dept_id = d.dept_id
group by d.dept_id;


select * from view_student_count_by_dept;
-- b,
select *
from view_student_count_by_dept 
order by total_students desc limit 1;

-- Cau 5:
-- a
Delimiter //
CREATE procedure get_top_score_student(in var_course_id varchar(6))
begin
    Select s.student_id,s.full_name,e.course_id,e.score
    from enrollment e join student s ON e.student_id = s.student_id
    where e.course_id = var_course_id and e.score = (Select max(score) 
														from enrollment 
														where course_id = var_course_id);
end //
Delimiter ;
-- b
Call get_top_score_student('C00002');

-- câu 6
-- a
Create view  view_it_enrollment_db as
select s.student_id,s.full_name,e.course_id,e.score
from enrollment e join student s on e.student_id = s.student_id
Where e.course_id = 'C00001' and s.dept_id = 'IT';
select * from view_it_enrollment_db

delimiter //
create procedure update_score_it_db(
INvar_student_idVARCHAR(6),
INOUTinout_new_scoreDECIMAL(4,2))
begin 
	update 

