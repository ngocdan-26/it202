USE RikkeiClinicDB;

DELIMITER //
CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
-- Lõi logic: Dùng NEW thay vì OLD khiến toàn bộ hệ thông bị "tê liệt"
IF NEW.status = 'Completed' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lôi: Không được phép thao tác trên lịch khám này!'
END IF;
END //
DELIMITER ;

-- Viết một câu lệnh UPDATE thử chuyển lịch khám có mã appointment_id = 104 từ trạng thái 'Pending' sang 'Completed' để quan sát lỗi do Trigger gây ra.
UPDATE Appointments 
SET status = 'Completed' 
WHERE appointment_id = 104;

/* Ta phải sử dụng đối tượng OLD. Vì OLD đại diện cho dữ liệu trước khi thay đổi. 
Nếu OLD.status = 'Completed', nghĩa là lịch khám này đã đóng sổ trong quá khứ, ta cần chặn mọi hành động chỉnh sửa nó. 
Nếu dùng NEW, hệ thống sẽ hiểu lầm là đang chặn trạng thái mới mà người dùng định cập nhật.
*/

-- iết lại Trigger PreventStatusRevert để chặn UPDATE.
-- 1. Xóa trigger cũ bị sai logic
DROP TRIGGER IF EXISTS PreventStatusRevert;
-- 2. Tạo trigger mới để bảo vệ các bản ghi đã 'Completed'
DELIMITER //
CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Nếu trạng thái CŨ đã là 'Completed' thì không cho phép sửa bất cứ thông tin gì
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không thể chỉnh sửa lịch khám đã hoàn thành (Completed)!';
    END IF;
END //
DELIMITER ;