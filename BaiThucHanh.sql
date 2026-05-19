-- PART 1: CREATE DATABASE + TABLES
CREATE DATABASE BaiThucHanh;
USE BaiThucHanh;

-- Guests
CREATE TABLE Guests (
    guest_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    loyalty_points INT DEFAULT 0,
    CHECK (loyalty_points >= 0)
);

-- Guest Profiles
CREATE TABLE Guest_Profiles (
    profile_id INT PRIMARY KEY,
    guest_id INT UNIQUE,
    address VARCHAR(255) NOT NULL,
    birthday DATE NOT NULL,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id)
);

-- Rooms
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL,
    room_type ENUM('Standard','Deluxe','Suite') NOT NULL,
    price_per_night DECIMAL(12,2) NOT NULL,
    room_status ENUM('Available','Occupied','Maintenance') NOT NULL,CHECK(price_per_night > 0)
);

-- Bookings
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    total_charge DECIMAL(15,2),
    booking_status ENUM('Pending','Completed','Cancelled') NOT NULL,
    created_at DATETIME
    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id)REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id)REFERENCES Rooms(room_id)
);

-- Room Log
CREATE TABLE Room_Log (
    log_id INT PRIMARY KEY,
    room_id INT NOT NULL,
    action_type ENUM('Check-in','Check-out','Maintenance','Cancelled') NOT NULL,
    change_note VARCHAR(255),
    logged_at DATETIME NOT NULL,
    FOREIGN KEY (room_id)REFERENCES Rooms(room_id)
);

-- INSERT DATA
-- Guests
INSERT INTO Guests
VALUES
(1,'Nguyen Van A','anv@gmail.com','901234567',150),
(2,'Tran Thi B','btt@gmail.com','912345678',500),
(3,'Le Van C','cle@yahoo.com','922334455',0),
(4,'Pham Minh D','dpham@hotmail.com','933445566',1000),
(5,'Hoang Anh E','ehoang@gmail.com','944556677',20);

-- Guest Profiles
INSERT INTO Guest_Profiles
VALUES
(101,1,'123 Le Loi, Q1, HCM','1990-05-15','1234'),
(102,2,'456 Nguyen Hue, Q1, HCM','1985-10-20','2345'),
(103,3,'789 Phan Chu Trinh, Da Nang','1995-12-01','3456'),
(104,4,'101 Hoang Hoa Tham, Ha Noi','1988-03-25','4567'),
(105,5,'202 Tran Hung Dao, Can Tho','2000-07-10','5678');


-- Rooms
INSERT INTO Rooms
VALUES
(1,'Room 101','Standard',10000000,'Available'),
(2,'Room 202','Deluxe',5000000,'Occupied'),
(3,'Room 303','Suite',50000000,'Available'),
(4,'Room 104','Standard',1000000,'Occupied'),
(5,'Room 205','Deluxe',20000000,'Maintenance');

-- Bookings
INSERT INTO Bookings
(booking_id,guest_id,room_id,check_in_date,check_out_date,total_charge,booking_status)
VALUES
(1001,1,2,'2023-11-15 10:30:00','2023-11-18 12:00:00',35500000,'Completed'),
(1002,2,3,'2023-12-01 14:20:00','2023-12-04 12:00:00',28000000,'Completed'),
(1003,1,1,'2024-01-10 09:15:00','2024-01-11 12:00:00',500000,'Pending'),
(1004,3,4,'2023-05-20 16:45:00','2023-05-22 12:00:00',7000000,'Cancelled'),
(1005,4,5,'2024-01-18 11:00:00','2024-01-20 12:00:00',1200000,'Completed');

-- Room Log
INSERT INTO Room_Log
VALUES
(1,1,'Check-in','Guest checked in','2023-10-01 09:00:00'),
(2,1,'Check-out','Guest checked out','2023-11-15 12:00:00'),
(3,4,'Maintenance','Room reported as damaged','2023-11-20 10:30:00'),
(4,2,'Check-in','New guest arrival','2023-11-25 14:00:00'),
(5,3,'Maintenance','Schedule maintenance','2023-12-01 08:00:00');

-- UPDATE + DELETE
-- cộng 200 điểm gmail
UPDATE Guests
SET loyalty_points = loyalty_points + 200
WHERE email LIKE '%@gmail.com';


-- xóa log trước 10/11/2023
DELETE FROM Room_Log
WHERE logged_at < '2023-11-10';

-- PART 2: BASIC QUERY
-- Câu 1
SELECT room_name,price_per_night,room_status
FROM Rooms
WHERE price_per_night > 1000000
OR room_status = 'Maintenance'
OR room_type = 'Suite';

-- Câu 2
SELECT full_name,email
FROM Guests
WHERE email LIKE '%@gmail.com'
AND loyalty_points BETWEEN 50 AND 300;


-- Câu 3
SELECT *
FROM Bookings
ORDER BY total_charge DESC
LIMIT 3 OFFSET 1;

-- PART 3: ADVANCED QUERY
-- Câu 1
SELECT g.full_name,gp.national_id,b.booking_id,b.check_in_date,b.total_charge
FROM Bookings b
INNER JOIN Guests g ON b.guest_id = g.guest_id
INNER JOIN Guest_Profiles gp ON gp.guest_id = g.guest_id;

-- Câu 2
SELECT g.guest_id,g.full_name,SUM(b.total_charge) AS total_spending
FROM Guests g
INNER JOIN Bookings b ON g.guest_id = b.guest_id
WHERE b.booking_status = 'Completed'
GROUP BY g.guest_id,g.full_name
HAVING SUM(b.total_charge)
> 20000000;

-- Câu 3
SELECT *
FROM Rooms
WHERE price_per_night =
(
    SELECT MAX(r.price_per_night)
    FROM Rooms r
    INNER JOIN Bookings b ON r.room_id = b.room_id
    WHERE b.booking_status = 'Completed'
);

-- PART 4: INDEX + VIEW
-- Câu 1
-- Composite Index

CREATE INDEX idx_booking_status_date
ON Bookings(
    booking_status,
    created_at
);

-- Câu 2
-- View thống kê booking khách hàng
CREATE VIEW vw_guest_booking_stats AS
SELECT
    g.full_name AS guest_name,
    COUNT(b.booking_id) AS total_bookings,
    IFNULL(SUM(b.total_charge),0) AS total_paid
FROM Guests g
LEFT JOIN Bookings b
    ON g.guest_id = b.guest_id
    AND b.booking_status <> 'Cancelled'
GROUP BY g.guest_id,g.full_name;
-- test view
SELECT *
FROM vw_guest_booking_stats;

-- PART 5: STORED PROCEDURE
DELIMITER //
-- 1. LẤY TẤT CẢ PHÒNG
CREATE PROCEDURE sp_get_all_rooms()
BEGIN
    SELECT *
    FROM Rooms;
END //
-- test
CALL sp_get_all_rooms();

-- 2. LẤY PHÒNG THEO ID
CREATE PROCEDURE sp_get_room_by_id
(
    IN p_room_id INT
)
BEGIN
    SELECT *
    FROM Rooms
    WHERE room_id = p_room_id;
END //

-- test
CALL sp_get_room_by_id(1);

-- 3. THÊM PHÒNG
CREATE PROCEDURE sp_insert_room
(
    IN p_room_id INT,
    IN p_room_name VARCHAR(100),
    IN p_room_type VARCHAR(50),
    IN p_price DECIMAL(12,2),
    IN p_status VARCHAR(50)
)
BEGIN
    INSERT INTO Rooms(room_id,room_name,room_type,price_per_night,room_status)
    VALUES(p_room_id,p_room_name,p_room_type,p_price,p_status);
END //


-- test
CALL sp_insert_room(6,'Room 606','Suite',15000000,'Available');

-- 4. UPDATE PHÒNG
CREATE PROCEDURE sp_update_room
(
    IN p_room_id INT,
    IN p_room_name VARCHAR(100),
    IN p_room_type VARCHAR(50),
    IN p_price DECIMAL(12,2),
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE Rooms
    SET
        room_name = p_room_name,
        room_type = p_room_type,
        price_per_night = p_price,
        room_status = p_status
    WHERE room_id = p_room_id;
END //

-- test
CALL sp_update_room(1,'VIP Room 101','Deluxe',25000000,'Occupied');

-- 5. XÓA PHÒNG
-- kiểm tra có booking không
CREATE PROCEDURE sp_delete_room(IN p_room_id INT)
BEGIN
    DECLARE room_booking_count INT;
    SELECT COUNT(*)
    INTO room_booking_count
    FROM Bookings
    WHERE room_id = p_room_id;
    IF room_booking_count > 0 THEN
        SELECT 'Khong the xoa phong da co booking' AS message;
    ELSE
        DELETE FROM Rooms
        WHERE room_id = p_room_id;
        SELECT 'Xoa phong thanh cong' AS message;
    END IF;
END //

-- test
CALL sp_delete_room(5);

-- CÂU 2
-- sp_get_room_status
CREATE PROCEDURE sp_get_room_status(IN p_room_id INT)
BEGIN
    DECLARE v_status VARCHAR(50);
    SELECT room_status
    INTO v_status
    FROM Rooms
    WHERE room_id = p_room_id;
    IF v_status = 'Available' THEN
        SELECT 'Phong trong' AS message;
    ELSEIF v_status = 'Occupied' THEN
        SELECT 'Dang co khach' AS message;
    ELSEIF v_status = 'Maintenance' THEN
        SELECT 'Bao tri' AS message;
    ELSE
        SELECT 'Khong tim thay phong' AS message;
    END IF;
END //

-- test
CALL sp_get_room_status(1);  

-- CÂU 3
-- sp_cancel_booking
CREATE PROCEDURE sp_cancel_booking
(IN p_booking_id INT)
BEGIN
    DECLARE v_room_id INT;
    DECLARE v_log_id INT;
    START TRANSACTION;
    -- lấy room_id
    SELECT room_id
    INTO v_room_id
    FROM Bookings
    WHERE booking_id = p_booking_id;

    -- tạo log_id mới
    SELECT IFNULL(MAX(log_id),0) + 1
    INTO v_log_id
    FROM Room_Log;

    -- cập nhật booking
    UPDATE Bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;

    -- cập nhật trạng thái phòng
    UPDATE Rooms
    SET room_status = 'Available'
    WHERE room_id = v_room_id;

    -- ghi log
    INSERT INTO Room_Log(log_id,room_id,action_type,change_note,logged_at)
    VALUES(v_log_id,v_room_id,'Cancelled','Booking cancelled',NOW());
    COMMIT;
END //

DELIMITER ;
-- TEST PROCEDURE
-- hủy booking
CALL sp_cancel_booking(1003);

-- kiểm tra lại
SELECT *
FROM Bookings;

SELECT *
FROM Rooms;

SELECT *
FROM Room_Log;