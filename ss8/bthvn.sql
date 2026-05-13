CREATE DATABASE hospital_management;
USE hospital_management;

-- 1. BẢNG BỆNH NHÂN
CREATE TABLE Patients (
    patient_id CHAR(5) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    patient_dob DATE NOT NULL,
    patient_phone VARCHAR(10) UNIQUE NOT NULL,
    patient_address VARCHAR(255) NOT NULL
);

-- 2. BẢNG BÁC SĨ
CREATE TABLE Doctors (
    doctor_id CHAR(5) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    doctor_specialty VARCHAR(100) NOT NULL,
    doctor_experience INT CHECK (doctor_experience >= 0),
    doctor_status BIT DEFAULT 1
);

-- 3. BẢNG PHIẾU KHÁM
CREATE TABLE Appointments (
    app_id CHAR(5) PRIMARY KEY,
    patient_id CHAR(5) NOT NULL,
    doctor_id CHAR(5) NOT NULL,
    app_date DATE NOT NULL,
    app_cost DECIMAL(12,2) NOT NULL CHECK(app_cost >= 0),
    app_status ENUM(
        'Pending',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Pending',
    FOREIGN KEY (patient_id)REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id)REFERENCES Doctors(doctor_id)
);

-- =====================================
-- 4. BẢNG ĐƠN THUỐC
-- 1 phiếu khám = 1 đơn thuốc
-- =====================================
CREATE TABLE Prescriptions (
    pres_id INT PRIMARY KEY AUTO_INCREMENT,
    app_id CHAR(5) UNIQUE NOT NULL,
    pres_medicine_details TEXT,
    pres_total_meds_cost DECIMAL(12,2)
        CHECK(pres_total_meds_cost >= 0),
    FOREIGN KEY (app_id)REFERENCES Appointments(app_id)
);

-- CHÈN DỮ LIỆU BỆNH NHÂN
INSERT INTO Patients VALUES
('BN001','Nguyễn Thị Hà','2000-05-15','0901111222','Hà Nội'),
('BN002','Trần Thu Bình','1998-08-20','0912222333','Hải Phòng'),
('BN003','Lê Văn Chiến','1999-07-26','0983333444','Hà Nội'),
('BN004','Nguyễn Xuân Bách','1998-03-31','0964444555','Đà Nẵng'),
('BN005','Trần Minh Cường','1995-02-19','0975555666','Hà Nội');

-- CHÈN DỮ LIỆU BÁC SĨ
INSERT INTO Doctors VALUES
('BS001','Nguyễn Lân Việt','Tim mạch',18,1),
('BS002','Trần Ngọc Lương','Ngoại khoa',15,1),
('BS003','Nguyễn Chấn Hùng','Ung Bướu',16,0),
('BS004','Nguyễn Văn Liệu','Thần Kinh',13,1),
('BS005','Nguyễn Viết Tiến','Phụ khoa',12,1);

-- CHÈN DỮ LIỆU PHIẾU KHÁM
INSERT INTO Appointments VALUES
('PK001','BN001','BS001','2026-05-13',500000,'Completed'),
('PK002','BN002','BS002','2026-04-16',300000,'Completed'),
('PK003','BN001','BS003','2026-03-29',700000,'Completed'),
('PK004','BN003','BS001','2026-05-13',400000,'Pending'),
('PK005','BN004','BS004','2026-04-12',200000,'Cancelled'),
('PK006','BN002','BS002','2026-05-08',300000,'Completed');

-- CHÈN DỮ LIỆU ĐƠN THUỐC
INSERT INTO Prescriptions
(app_id,pres_medicine_details,pres_total_meds_cost)
VALUES
('PK001','Aspirin, Beta-blocker',1500000),
('PK002','Vitamin C, Paracetamol',130000),
('PK003','Neurobion, Ginkgo Biloba',3500000);

-- II. CẬP NHẬT DỮ LIỆU

-- 1. Tăng phí khám +50,000
-- cho bác sĩ Tim mạch
UPDATE Appointments a
INNER JOIN Doctors d
ON a.doctor_id = d.doctor_id
SET a.app_cost = a.app_cost + 50000
WHERE d.doctor_specialty = 'Tim mạch';

-- 2. XÓA BÁC SĨ NGUYỄN LÂN VIỆT
-- Kiểm tra lịch hẹn liên quan
SELECT *
FROM Appointments
WHERE doctor_id = 'BS001';

-- Xóa đơn thuốc liên quan
DELETE FROM Prescriptions
WHERE app_id IN (
    SELECT app_id
    FROM (
        SELECT app_id
        FROM Appointments
        WHERE doctor_id = 'BS001'
    ) temp
);

-- Xóa phiếu khám
DELETE FROM Appointments
WHERE doctor_id = 'BS001';

-- Xóa bác sĩ
DELETE FROM Doctors
WHERE doctor_id = 'BS001';

-- III. VẬN HÀNH BỆNH VIỆN
-- 1. Phiếu khám hoàn thành
SELECT
    app_id,
    doctor_id,
    app_date,
    app_cost
FROM Appointments
WHERE app_status = 'Completed'
ORDER BY app_date DESC;

-- 2. Bệnh nhân Hà Nội
-- SDT bắt đầu bằng 090
SELECT
    patient_id,
    patient_phone,
    patient_name
FROM Patients
WHERE patient_address = 'Hà Nội'
AND patient_phone LIKE '090%';

-- 3. TV hiển thị 3 người tiếp theo
SELECT
    patient_id,
    patient_name,
    patient_dob
FROM Patients
LIMIT 2,3;

-- IV. BÁO CÁO & KẾ TOÁN
-- 1. Hóa đơn viện phí
SELECT
    p.patient_id,
    p.patient_name,
    d.doctor_name,
    a.app_cost
    + IFNULL(pr.pres_total_meds_cost,0)
    AS total_payment
FROM Appointments a INNER JOIN Patients p
ON a.patient_id = p.patient_id INNER JOIN Doctors d
ON a.doctor_id = d.doctor_id LEFT JOIN Prescriptions pr
ON a.app_id = pr.app_id;
-- 2. KPI bác sĩ
SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(a.app_id)
    AS total_visits,
    SUM(
        a.app_cost +
        IFNULL(pr.pres_total_meds_cost,0)
    ) AS total_revenue

FROM Doctors d INNER JOIN Appointments a
ON d.doctor_id = a.doctor_id LEFT JOIN Prescriptions pr
ON a.app_id = pr.app_id
GROUP BY
    d.doctor_id,
    d.doctor_name
HAVING COUNT(a.app_id) >= 2;
-- 3. Completed nhưng không kê thuốc
SELECT
    a.app_id,
    a.patient_id,
    a.app_date
FROM Appointments a LEFT JOIN Prescriptions p
ON a.app_id = p.app_id
WHERE a.app_status = 'Completed'
AND p.app_id IS NULL;

-- V. PHÂN TÍCH DỮ LIỆU
-- 1. Bác sĩ có kinh nghiệm
-- cao hơn trung bình
SELECT
    doctor_id,
    doctor_name,
    doctor_experience
FROM Doctors
WHERE doctor_experience >
(
    SELECT AVG(doctor_experience)
    FROM Doctors
);

-- 2. Bệnh nhân chưa khám
SELECT DISTINCT
    p.patient_id,
    p.patient_name,
    p.patient_phone
FROM Patients p INNER JOIN Appointments a
ON p.patient_id = a.patient_id
WHERE a.app_status = 'Pending';

-- 3. Phiếu khám đắt nhất
SELECT
    p.patient_name,
    d.doctor_name,
    a.app_date,
    a.app_cost
FROM Appointments a INNER JOIN Patients p
ON a.patient_id = p.patient_id INNER JOIN Doctors d
ON a.doctor_id = d.doctor_id
WHERE a.app_cost =
(
    SELECT MAX(app_cost)
    FROM Appointments
);

-- 4. Bệnh nhân VIP
SELECT 
    p.patient_id,
    p.patient_name,
    p.patient_phone,
    p.patient_address
FROM
    Patients p INNER JOIN Appointments a 
    ON p.patient_id = a.patient_id LEFT JOIN Prescriptions pr 
    ON a.app_id = pr.app_id
GROUP BY p.patient_id , p.patient_name , p.patient_phone , p.patient_address
HAVING SUM(a.app_cost + IFNULL(pr.pres_total_meds_cost, 0)) = (SELECT 
        MAX(total_spent)
    FROM
        (SELECT 
            SUM(a.app_cost + IFNULL(pr.pres_total_meds_cost, 0)) AS total_spent
        FROM Appointments a LEFT JOIN Prescriptions pr 
        ON a.app_id = pr.app_id
        GROUP BY a.patient_id) vip);