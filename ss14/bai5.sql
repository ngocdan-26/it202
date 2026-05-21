USE RikkeiClinicDB;

DELIMITER //
CREATE PROCEDURE Sp_FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN
    SELECT bed_id INTO p_bed_id
    FROM Beds
    WHERE department_id = p_dept_id AND status = 0
    LIMIT 1;
END //
CREATE PROCEDURE Sp_EmergencyAdmission(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_dept_id INT,
    IN p_admit_time DATETIME
)
BEGIN
    DECLARE v_selected_bed_id INT;
    DECLARE v_is_staying INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; 
    END;
    START TRANSACTION;
    SELECT COUNT(*) INTO v_is_staying 
    FROM Beds WHERE patient_id = p_patient_id AND status = 1;
    IF v_is_staying > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Từ chối: Bệnh nhân đang lưu trú';
    END IF;
    CALL Sp_FindAvailableBed(p_dept_id, v_selected_bed_id);
    IF v_selected_bed_id IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Từ chối: Khoa hiện đã hết giường';
    END IF;
    INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
    VALUES (p_patient_id, p_doctor_id, p_admit_time, 'In-patient');
    UPDATE Beds 
    SET status = 1, patient_id = p_patient_id 
    WHERE bed_id = v_selected_bed_id;
    COMMIT;
    SELECT CONCAT('Thành công! Đã xếp bệnh nhân vào giường số: ', v_selected_bed_id) AS Result;
END //
DELIMITER ;

CALL Sp_EmergencyAdmission(1, 10, 5, NOW());

CALL Sp_EmergencyAdmission(2, 11, 9, NOW()); 

CALL Sp_EmergencyAdmission(1, 12, 5, NOW());

CALL Sp_EmergencyAdmission(3, 10, 999, NOW());