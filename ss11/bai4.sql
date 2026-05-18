
/*
Input (IN)
Phonepatient_id
phone
Output (OUT)
Tổng nợ
Thông báo trạng thái
*/
-- Đề xuất 2 giải pháp xử lý logic
/* Ý tưởng:
Giải pháp 1 — Dùng IF / ELSE (Rẽ nhánh)
IF p_patient_id IS NOT NULL THEN
    -- tìm theo ID
ELSEIF p_phone IS NOT NULL THEN
    -- tìm theo Phone
ELSE
    -- báo lỗi
END IF;
Giải pháp 2 — Truy vấn linh hoạt bằng WHERE
SELECT pi.total_due
INTO p_total_due
FROM Patient_Invoices pi
JOIN Patients p
ON pi.patient_id = p.patient_id
WHERE
(p.patient_id = p_patient_id OR p_patient_id IS NULL)
AND
(p.phone = p_phone OR p_phone IS NULL)
LIMIT 1;
| Tiêu chí         | IF / ELSE | WHERE linh hoạt  |
| ---------------  | --------- | ---------------- |
| Dễ đọc           | Cao       | x Trung bình     |
| Dễ debug         | v         | x                |
| Dễ mở rộng       | v         | x                |
| Tối ưu hiệu năng | v         | x OR có thể chậm |
| Dễ maintain      | v         | x                |
--> Chọn Giải pháp 1
*/

/*
1. Thiết kế luồng xử lý
Bước 1: Validate input
Bước 2: Tìm kiếm dữ liệu
Bước 3: Kiểm tra kết quả 	
*/

-- 2.Triển khai Stored Procedure
DROP PROCEDURE IF EXISTS GetPatientDebt;
DELIMITER //
CREATE PROCEDURE GetPatientDebt(
    IN p_patient_id INT,
    IN p_phone VARCHAR(15),
    OUT p_total_due DECIMAL(18,2),
    OUT p_message VARCHAR(100)
)
BEGIN
    -- Reset giá trị tránh giữ dữ liệu cũ
    SET p_total_due = NULL;
    -- Kịch bản 1: NULL cả ID và Phone
    IF p_patient_id IS NULL
       AND p_phone IS NULL THEN
        SET p_total_due = 0;
        SET p_message = 'Lỗi: Vui lòng nhập ID hoặc số điện thoại';
    ELSE
        -- Ưu tiên tìm theo ID
        IF p_patient_id IS NOT NULL THEN
            SELECT total_due
            INTO p_total_due
            FROM Patient_Invoices
            WHERE patient_id = p_patient_id;
        -- Nếu không có ID thì tìm theo Phone
        ELSE
            SELECT pi.total_due
            INTO p_total_due
            FROM Patient_Invoices pi
            INNER JOIN Patients p
                ON pi.patient_id = p.patient_id
            WHERE p.phone = p_phone;
        END IF;
        -- Không tìm thấy dữ liệu
        IF p_total_due IS NULL THEN
            SET p_total_due = 0;
            SET p_message = 'Không tìm thấy bệnh nhân';
        ELSE
            SET p_message = 'Tra cứu thành công';
        END IF;
    END IF;
END //
DELIMITER ;

-- Nghiệm thu
CALL GetPatientDebt(
    1,
    NULL,
    @debt,
    @message
);
SELECT @debt, @message;