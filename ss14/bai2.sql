USE RikkeiClinicDB;

DELIMITER //
CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
-- Thao tác 1: Giải phóng giường cũ
UPDATE Beds SET patient_id = NULL WHERE patient_id = p_patient_id;
-- Thao tác 2: Gán giường mới
UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = p_new_bed_id;
END //
DELIMITER ;

-- 1. Xóa thủ tục cũ
DROP PROCEDURE IF EXISTS TransferBed;

-- 2. Tạo thủ tục mới với cơ chế Transaction
DELIMITER //
CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_old_bed_id INT,
    IN p_new_bed_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi hệ thống: Quá trình chuyển giường đã được hoàn nguyên!';
    END;
    START TRANSACTION;
    UPDATE Beds 
    SET status = 0, patient_id = NULL 
    WHERE bed_id = p_old_bed_id;
    UPDATE Beds 
    SET status = 1, patient_id = p_patient_id 
    WHERE bed_id = p_new_bed_id;
    COMMIT;
    SELECT 'Chuyển giường thành công!' AS Result;
END //
DELIMITER ;