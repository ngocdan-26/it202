CREATE DATABASE student_management;
USE student_management;

CREATE TABLE Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    course_status ENUM('Hoạt động', 'Không hoạt động')
);

CREATE TABLE Subject (
    sub_id CHAR(4) PRIMARY KEY,
    sub_name VARCHAR(100) NOT NULL,
    credit INT NOT NULL CHECK (credit > 0),
    sub_status ENUM('Hoạt động', 'Không hoạt động'),
    course_id INT NULL,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE SET NULL
);

CREATE TABLE Student (
    stu_id CHAR(5) PRIMARY KEY,
    stu_name VARCHAR(100) NOT NULL,
    birth_year INT CHECK (birth_year >= 1900),
    gender ENUM('Nam', 'Nữ', 'Khác'),
    phone VARCHAR(15) UNIQUE,
    address VARCHAR(255),
    stu_status ENUM('Đang học','Bảo lưu','Đình chỉ','Tốt nghiệp')
);

CREATE TABLE Enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    sub_id CHAR(4),
    stu_id CHAR(5),
    score DECIMAL(4,2)CHECK(score BETWEEN 0 AND 10),
    register_date DATE,
    FOREIGN KEY (sub_id)REFERENCES Subject(sub_id),
    FOREIGN KEY (stu_id)REFERENCES Student(stu_id)
);

CREATE TABLE CitizenCard (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    cccd_number VARCHAR(12) UNIQUE NOT NULL,
    issue_date DATE,
    issue_place VARCHAR(100),
    stu_id CHAR(5) UNIQUE,
    FOREIGN KEY (stu_id) REFERENCES Student(stu_id)
);

INSERT INTO Course
(course_name, duration, course_status)
VALUES
('CNTT K17', '4 năm', 'Hoạt động'),
('Marketing K18', '4 năm', 'Hoạt động'),
('Kế toán K16', '4 năm', 'Không hoạt động'),
('Thiết kế đồ họa', '3 năm', 'Hoạt động'),
('Du lịch', '3 năm', 'Hoạt động');

INSERT INTO Subject
(sub_id, sub_name, credit, sub_status, course_id)
VALUES
('MH01', 'Giải tích', 2, 'Hoạt động', 1),
('MH02', 'Lập trình C', 3, 'Hoạt động', 1),
('MH03', 'Marketing căn bản', 2, 'Hoạt động', 2),
('MH04', 'Kế toán tài chính', 3, 'Không hoạt động', 3),
('MH05', 'Photoshop', 2, 'Hoạt động', NULL);

INSERT INTO Student
(stu_id, stu_name, birth_year,gender, phone, address, stu_status)
VALUES
('SV001', 'Nguyễn Văn A', 2003,'Nam', '0911111111', 'Hà Nội', 'Đang học'),
('SV002', 'Trần Thị B', 2004,'Nữ', '0922222222', 'TP HCM', 'Đang học'),
('SV003', 'Lê Văn C', 2002,'Nam', '0933333333', 'Đà Nẵng', 'Bảo lưu'),
('SV004', 'Phạm Thị D', 2001,'Nữ', '0944444444', 'Hải Phòng', 'Tốt nghiệp'),
('SV005', 'Hoàng Văn E', 2003,'Nam', '0955555555', 'Hà Nam', 'Đình chỉ');

INSERT INTO Enrollment 
(sub_id, stu_id, score, register_date)
VALUES
('MH01', 'SV001', 8.5, '2025-01-10'),
('MH02', 'SV001', 9.0, '2025-01-11'),
('MH01', 'SV002', 7.5, '2025-01-15'),
('MH03', 'SV003', 8.0, '2025-01-20'),
('MH05', 'SV004', 9.5, '2025-01-25');

INSERT INTO CitizenCard 
(cccd_number, issue_date,issue_place, stu_id)
VALUES
('001111111111', '2020-01-01','Hà Nội', 'SV001'),
('002222222222', '2020-02-02','TP HCM', 'SV002'),
('003333333333', '2020-03-03','Đà Nẵng', 'SV003'),
('004444444444', '2020-04-04','Hải Phòng', 'SV004'),
('005555555555', '2020-05-05','Hà Nam', 'SV005');

-- Cập nhật môn học có mã là MH01 thành tên ‘Toán cao cấp’ và có số tín chỉ là 3
UPDATE Subject
SET sub_name = 'Toán cao cấp', credit = 3
WHERE sub_id = 'MH01';

-- Thực hiện xóa các môn học có trạng thái là Không hoạt động
DELETE FROM Subject
WHERE sub_status = 'Không hoạt động';

-- Lấy thông tin các sinh viên gồm: mã sinh viên, tên sinh viên, số điện thoại,địa chỉ
SELECT stu_id,stu_name,phone,address
FROM Student;

-- Lấy thông tin các môn học chưa thuộc khóa học gồm: mã khóa học, tên khóa học, số tín chỉ
SELECT sub_id,sub_name,credit
FROM Subject
WHERE course_id IS NULL;

-- Lấy các mã khóa học đã có môn học
SELECT DISTINCT course_id
FROM Subject
WHERE course_id IS NOT NULL;

-- Lấy thông tin các đăng ký gồm: mã sinh viên, tên sinh viên, ngày đăng ký,
-- tên môn học đăng ký, điểm môn học, số căn cước công dân sắp xếp theo
-- năm sinh giảm dần
SELECT s.stu_id,s.stu_name,e.register_date,sub.sub_name,e.score,c.cccd_number
FROM Enrollment e 
INNER JOIN Student s ON e.stu_id = s.stu_id
INNER JOIN Subject sub ON e.sub_id = sub.sub_id
INNER JOIN CitizenCard c ON s.stu_id = c.stu_id
ORDER BY s.birth_year DESC;

-- a.Tính tổng số lần đăng ký của từng môn học
-- dùng count để đếm số lượt đăng ký
SELECT s.sub_id,s.sub_name,COUNT(e.enrollment_id) AS total_registration 
-- Enrollment chứa dữ liệu đăng ký,Subject chứa thông tin môn học.
FROM Subject s LEFT JOIN Enrollment e ON s.sub_id = e.sub_id 
-- thống kê theo từng môn học
GROUP BY s.sub_id, s.sub_name; 

-- b.Thống kê số môn học của từng khóa học
SELECT c.course_id,c.course_name,COUNT(s.sub_id) AS total_subject 
-- Course chứa thông tin khóa học,Subject chứa môn học thuộc khóa.
FROM Course c LEFT JOIN Subject s ON c.course_id = s.course_id
GROUP BY c.course_id, c.course_name;

-- c.Tính điểm trung bình của sinh viên (điểm trung bình của tất cả các đăng ký)
SELECT s.stu_id,s.stu_name,AVG(e.score) AS avg_score
-- Enrollment chứa điểm, Student chứa thông tin sinh viên.
FROM Student s LEFT JOIN Enrollment e ON s.stu_id = e.stu_id
GROUP BY s.stu_id, s.stu_name;

-- d.Lấy thông tin các môn học có điểm trung bình lớn hơn 5 gồm: mã môn học,tên môn học, tên khóa họ
-- Hàm tính toán AVG() tính điểm trung bình
SELECT s.sub_id,s.sub_name,c.course_name,AVG(e.score) AS avg_score
-- Enrollment chứa điểm,Subject chứa môn học,Course chứa tên khóa học.
FROM Subject s INNER JOIN Enrollment e
ON s.sub_id = e.sub_id LEFT JOIN Course c
ON s.course_id = c.course_id
GROUP BY s.sub_id,s.sub_name,c.course_name 
-- lọc sau khi tính trung bình
HAVING AVG(e.score) > 5;

-- Lấy thông tin các đăng ký có điểm lớn nhất gồm: mã sinh viên, tên sinh viên, tên môn học, điểm môn học
SELECT s.stu_id,s.stu_name,sub.sub_name,e.score
-- Enrollment chứa điểm,Student chứa sinh viên,Subject chứa tên môn.
FROM Enrollment e INNER JOIN Student s
ON e.stu_id = s.stu_id INNER JOIN Subject sub
ON e.sub_id = sub.sub_id
-- Tìm điểm cao nhất --> Lấy các sinh viên có điểm bằng điểm lớn nhất.
WHERE e.score = (SELECT MAX(score) FROM Enrollment);

-- Lấy thông tin sinh viên đã đăng ký môn học có điểm trung bình lớn nhất
-- gồm: mã sinh viên, tên sinh viên, tuổi, tên môn học, tên khóa học
-- YEAR(CURDATE()) Tính tuổi sinh viên.
SELECT s.stu_id,s.stu_name,YEAR(CURDATE()) - s.birth_year AS age,sub.sub_name,c.course_name
-- Student chứa thông tin sinh viên,Enrollment chứa điểm,Subject chứa môn học,Course chứa khóa học
FROM Student s INNER JOIN Enrollment e
ON s.stu_id = e.stu_id INNER JOIN Subject sub
ON e.sub_id = sub.sub_id LEFT JOIN Course c
ON sub.course_id = c.course_id

-- Lấy sinh viên học môn đó
WHERE sub.sub_id =
-- Lấy môn có điểm TB cao nhất
(SELECT sub_id 
FROM Enrollment 
-- tính trung bình theo từng môn.
GROUP BY sub_id 
ORDER BY AVG(score) DESC LIMIT 1);