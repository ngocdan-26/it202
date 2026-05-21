/*
Chiến lược 1: Reactive (Phản ứng lỗi)
Cách làm: "Chạy lệnh UPDATE ngay, dùng HANDLER để bắt lỗi nếu Database báo lỗi (ví dụ: vi phạm ràng buộc CHECK)."
Ưu điểm: "Code ngắn gọn, tận dụng tối đa các ràng buộc (Constraints) của Database."
Nhược điểm,Khó tùy biến thông báo lỗi riêng biệt cho từng tình huống logic kinh doanh.

Chiến lược 2: Proactive (Chủ động kiểm tra)
Cách làm: "Truy vấn số dư ví trước, so sánh với số tiền cần trả. Chỉ thực hiện UPDATE nếu đủ điều kiện."
Ưu điểm: "Kiểm soát logic chặt chẽ, thông báo lỗi tường minh cho người dùng, tránh gây áp lực lên ghi log lỗi hệ thống."
Nhược điểm: Tốn thêm một bước truy vấn SELECT trước khi cập nhật.

=> Lựa chọn: Chiến lược 2 được chọn vì đảm bảo trải nghiệm người dùng tốt hơn và an toàn tuyệt đối cho dữ liệu tài chính.
*/

USE RikkeiClinicDB;

DELIMITER //
CREATE PROCEDURE Sp_OneTouchPayment(
    IN p_patient_id INT,
    IN p_payment_amount DECIMAL(18,2)
)
BEGIN
    DECLARE v_current_balance DECIMAL(18,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Lỗi hệ thống: Giao dịch đã được hoàn nguyên an toàn!' AS Status;
    END;
    START TRANSACTION;
    IF p_payment_amount <= 0 THEN
        ROLLBACK;
        SELECT 'Lỗi: Số tiền thanh toán phải lớn hơn 0' AS Status;
    ELSE
        SELECT balance INTO v_current_balance 
        FROM Wallets WHERE patient_id = p_patient_id;
        IF v_current_balance < p_payment_amount THEN
            ROLLBACK;
            SELECT 'Lỗi: Số dư Ví không đủ để thực hiện giao dịch' AS Status;
        ELSE
            UPDATE Wallets 
            SET balance = balance - p_payment_amount 
            WHERE patient_id = p_patient_id;
            UPDATE Patient_Invoices 
            SET amount_due = amount_due - p_payment_amount 
            WHERE patient_id = p_patient_id;
            COMMIT;
            SELECT 'Thanh toán một chạm thành công!' AS Status;
        END IF;
    END IF;
END //
DELIMITER ;

CALL Sp_OneTouchPayment(1, 200000); 

CALL Sp_OneTouchPayment(1, 2000000); 

CALL Sp_OneTouchPayment(1, -50000); 