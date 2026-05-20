USE RikkeiClinicDB;
-- 1. Tạo bảng lưu lịch sử biến động giá
CREATE TABLE Price_Changes_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    change_type VARCHAR(20),
    price_diff DECIMAL(10, 2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 2. Tạo Trigger kiểm soát và ghi Log
DELIMITER //
CREATE TRIGGER trg_AfterPriceChange
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    -- Trường hợp 1: Chặn giá không hợp lệ (âm hoặc bằng 0)
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
    END IF;
    -- Trường hợp 2: Chỉ ghi log khi giá thực sự thay đổi
    IF NEW.price <> OLD.price THEN
        IF NEW.price > OLD.price THEN
            -- Tăng giá
            INSERT INTO Price_Changes_Log (medicine_id, old_price, new_price, change_type, price_diff)
            VALUES (OLD.medicine_id, OLD.price, NEW.price, 'TĂNG GIÁ', NEW.price - OLD.price);
        ELSE
            -- Giảm giá
            INSERT INTO Price_Changes_Log (medicine_id, old_price, new_price, change_type, price_diff)
            VALUES (OLD.medicine_id, OLD.price, NEW.price, 'GIẢM GIÁ', OLD.price - NEW.price);
        END IF;
    END IF;
END //
DELIMITER ;
-- kiểm thử
UPDATE Medicines SET price = 150000 WHERE medicine_id = 1;
UPDATE Medicines SET price = 80000 WHERE medicine_id = 2;
UPDATE Medicines SET stock_quantity = 500 WHERE medicine_id = 1;
UPDATE Medicines SET price = -5000 WHERE medicine_id = 3;