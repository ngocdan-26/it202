USE RikkeiClinicDB;

DELIMITER //
-- 1. Trigger cho thao tác Thêm mới (INSERT)
CREATE TRIGGER trg_PreventDoubleBooking_Insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Appointments 
        WHERE doctor_id = NEW.doctor_id 
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
-- 2. Trigger cho thao tác Cập nhật (UPDATE)
CREATE TRIGGER trg_PreventDoubleBooking_Update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Appointments 
        WHERE doctor_id = NEW.doctor_id 
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
          -- Ngoại lệ 2: Không so sánh với chính ca khám đang sửa
          AND appointment_id <> NEW.appointment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
DELIMITER ;

-- kiểm thử
-- Lịch mới vào khung giờ trống (Thành công)
INSERT INTO Appointments (doctor_id, patient_id, appointment_date, status)
VALUES (1, 10, '2026-06-01 09:00:00', 'Pending');

-- Trùng giờ với một ca đang 'Pending' (Bị chặn & Báo lỗi)
INSERT INTO Appointments (doctor_id, patient_id, appointment_date, status)
VALUES (1, 11, '2026-06-01 09:00:00', 'Pending');

-- Lịch mới vào khung giờ đang có ca 'Cancelled' (Thành công)
UPDATE Appointments SET status = 'Cancelled' WHERE doctor_id = 1 AND appointment_date = '2026-06-01 09:00:00';
INSERT INTO Appointments (doctor_id, patient_id, appointment_date, status)
VALUES (1, 12, '2026-06-01 09:00:00', 'Pending');

-- Cập nhật trạng thái chính ca đó (Thành công - Vượt qua ngoại lệ 2)
UPDATE Appointments 
SET status = 'Completed' 
WHERE doctor_id = 1 AND appointment_date = '2026-06-01 09:00:00' AND status = 'Pending';