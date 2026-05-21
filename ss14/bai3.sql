USE RikkeiClinicDB;

DELIMITER //
CREATE PROCEDURE Sp_IssueMedicine(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi hệ thống hoặc lỗi dữ liệu. Giao dịch đã được hủy!' AS Status;
    END;
    START TRANSACTION;
    SELECT stock, price INTO v_stock, v_price 
    FROM Medicines WHERE medicine_id = p_medicine_id;

    IF v_stock < p_quantity THEN
        ROLLBACK;
        SELECT 'Lỗi: Số lượng tồn kho không đủ' AS Status;
    ELSE
        UPDATE Medicines 
        SET stock = stock - p_quantity 
        WHERE medicine_id = p_medicine_id;
        UPDATE Patients 
        SET total_debt = total_debt + (p_quantity * v_price)
        WHERE patient_id = p_patient_id;
        COMMIT;
        SELECT 'Đã cấp phát thành công' AS Status;
    END IF;
END //
DELIMITER ;

CALL Sp_IssueMedicine(10, 1, 10);

CALL Sp_IssueMedicine(10, 1, 100);