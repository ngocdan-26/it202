
CREATE DATABASE IF NOT EXISTS rikkei_clinic_db;
USE rikkei_clinic_db;

-- 1. TẠO BẢNG DỮ LIỆU
-- Bảng lưu trữ thông tin khoa (Dùng cho bài Báo cáo tài chính)
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Bảng lưu trữ thông tin bệnh nhân 
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    phone VARCHAR(15) NOT NULL,
    room_number VARCHAR(10),
    hiv_status VARCHAR(20),
    mental_health_history TEXT,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Bảng lưu trữ hóa đơn (Dùng cho bài Báo cáo tài chính)
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    patient_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Bảng lưu trữ kho dược (Dùng cho bài Tối ưu kho dược phẩm)
CREATE TABLE pharmacy_inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    drug_name VARCHAR(255) NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL
);

-- Bảng lưu trữ bệnh án tập trung (Dùng cho bài Data Masking)
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    diagnosis TEXT NOT NULL, 
    total_cost DECIMAL(10,2) NOT NULL, 
    paid_amount DECIMAL(10,2) DEFAULT 0
);

-- Bảng lưu vết sinh tồn (Dùng cho bài ER Dashboard)
CREATE TABLE vitals_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    heart_rate INT CHECK (heart_rate > 0),
    record_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- 2. CHÈN DỮ LIỆU MẪU
-- Insert Khoa
INSERT INTO departments (department_id, department_name) VALUES 
(1, 'Khoa Noi'), 
(2, 'Khoa Ngoai');

-- Insert Bệnh nhân (3 người này sẽ dùng test toàn bộ các bài)
INSERT INTO patients (patient_id, full_name, age, phone, room_number, hiv_status, mental_health_history, department_id) VALUES
(1, 'Nguyen Van A', 45, '0901234567', '101A', 'Negative', 'None', 1),
(2, 'Tran Thi B', 30, '0912345678', '102B', 'Positive', 'Depression 2020', 1),
(3, 'Le Hoang C', 50, '0923456789', '103A', 'Negative', 'Anxiety', 2);

-- Insert Hóa đơn
INSERT INTO invoices (invoice_id, patient_id, amount) VALUES 
(101, 1, 500000), 
(102, 2, 300000), 
(103, 3, 1000000);

-- Insert Kho dược phẩm
INSERT INTO pharmacy_inventory (drug_name, batch_number, expiry_date, quantity) VALUES
('Paracetamol', 'B001', '2026-12-31', 500),
('Amoxicillin', 'B002', '2025-10-15', 300),
('Ibuprofen', 'B003', '2027-01-20', 1000),
('Paracetamol', 'B004', '2025-08-01', 200);

-- Insert Bệnh án tập trung
INSERT INTO medical_records (patient_name, diagnosis, total_cost, paid_amount) VALUES 
('Nguyen Van A', 'Nhiem trung duong ruot', 1500000, 500000),
('Tran Thi B', 'Giai phau tham my', 50000000, 50000000),
('Le Hoang C', 'Viem da co dia', 2000000, 0);

-- Insert Dữ liệu sinh tồn cho bài ER Dashboard
-- BN1 có 2 lần đo, lần đo cuối nhịp tim 130
INSERT INTO vitals_logs (patient_id, heart_rate, record_time) VALUES 
(1, 80, '2026-05-14 08:00:00'),
(1, 130, '2026-05-14 08:15:00');

-- BN2 có 1 lần đo, nhịp tim 75
INSERT INTO vitals_logs (patient_id, heart_rate, record_time) VALUES 
(2, 75, '2026-05-14 08:10:00');

-- BN3 không có dữ liệu để sinh viên test logic lấy ra trạng thái Pending/UNKNOWN

-- Kịch bản 1: Truy vấn WHERE drug_name = 'Paracetamol' AND expiry_date <= '2026-12-31' đang bị cảnh báo quét toàn bảng (type = ALL).
-- Dù chạy nhanh trên dữ liệu mẫu, nhưng khi nhiều dữ liệu thì sẽ làm chậm hệ thống.
EXPLAIN
SELECT *
FROM pharmacy_inventory
WHERE drug_name = 'Paracetamol'
AND expiry_date <= '2026-12-31';
-- Kết quả mong đợi trước tối ưu:
-- type = ALL
-- => Database quét toàn bộ bảng

-- Kịch bản 2:Dược sĩ nhập từ khóa LIKE '%Paracetamol%'.
-- Dù Database có được lập chỉ mục đi nữa, cách viết chuỗi này vẫn vô hiệu hóa Index và ép hệ thống quét toàn bảng.
-- Index riêng cho tên thuốc
CREATE INDEX idx_drug_name
ON pharmacy_inventory(drug_name);

-- Index riêng cho hạn sử dụng
CREATE INDEX idx_expiry_date
ON pharmacy_inventory(expiry_date);
-- Dấu % ở đầu chuỗi làm MySQL không xác định được điểm bắt đầu tìm kiếm trong B-Tree Index, nên Index bị vô hiệu hóa.
EXPLAIN
SELECT *
FROM pharmacy_inventory
WHERE drug_name LIKE 'Paracetamol%';


