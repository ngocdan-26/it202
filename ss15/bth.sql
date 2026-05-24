-- 1. Tạo cơ sở dữ liệu nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS rikkeifood_db;
USE rikkeifood_db;


-- 2. Xóa bảng cũ nếu tồn tại (Xóa theo thứ tự ngược lại của khóa ngoại để tránh lỗi ràng buộc)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS foods;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;


-- =========================================================================
-- THỰC THỂ 1: USERS (Người dùng)
-- =========================================================================
CREATE TABLE users (
  user_id INT AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  wallet_balance DECIMAL(10, 2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


  CONSTRAINT pk_users PRIMARY KEY (user_id),
  CONSTRAINT uq_user_email UNIQUE (email),
  CONSTRAINT chk_user_wallet CHECK (wallet_balance >= 0)
);


-- =========================================================================
-- THỰC THỂ 2: RESTAURANTS (Cửa hàng / Nhà hàng)
-- =========================================================================
CREATE TABLE restaurants (
	restaurant_id INT AUTO_INCREMENT,
	restaurant_name VARCHAR(150) NOT NULL,
	address VARCHAR(255) NOT NULL,
	rating DECIMAL(2, 1) DEFAULT 5.0,
	is_active TINYINT(1) DEFAULT 1,


	CONSTRAINT pk_restaurants PRIMARY KEY (restaurant_id),
	CONSTRAINT chk_restaurant_rating CHECK (rating >= 0.0 AND rating <= 5.0)
);


-- =========================================================================
-- THỰC THỂ 3: FOODS (Món ăn)
-- =========================================================================
CREATE TABLE foods (
  food_id INT AUTO_INCREMENT,
  restaurant_id INT NOT NULL,
  food_name VARCHAR(150) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INT DEFAULT 99,
  is_available TINYINT(1) DEFAULT 1,


  CONSTRAINT pk_foods PRIMARY KEY (food_id),
-- Nếu nhà hàng bị xóa, xóa luôn các món ăn của nhà hàng đó (ON DELETE CASCADE)
  CONSTRAINT fk_foods_restaurants FOREIGN KEY (restaurant_id)
	  REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
  CONSTRAINT chk_food_price CHECK (price > 0),
  CONSTRAINT chk_food_stock CHECK (stock_quantity >= 0)
);


-- =========================================================================
-- THỰC THỂ 4: ORDERS (Đơn hàng)
-- =========================================================================
CREATE TABLE orders (
	order_id INT AUTO_INCREMENT,
	user_id INT NOT NULL,
	restaurant_id INT NOT NULL,
	total_amount DECIMAL(10, 2) NOT NULL,
	order_status ENUM('PENDING', 'PREPARING', 'SHIPPING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
	order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


	CONSTRAINT pk_orders PRIMARY KEY (order_id),
	-- Khóa ngoại liên kết tới người dùng mua hàng
	CONSTRAINT fk_orders_users FOREIGN KEY (user_id)
	   REFERENCES users(user_id),
	-- Khóa ngoại liên kết tới nhà hàng. Nếu nhà hàng bị xóa, giữ lại đơn hàng để đối soát (ON DELETE RESTRICT)
	CONSTRAINT fk_orders_restaurants FOREIGN KEY (restaurant_id)
	   REFERENCES restaurants(restaurant_id) ON DELETE RESTRICT,
	CONSTRAINT chk_order_amount CHECK (total_amount >= 0)
	);

INSERT INTO users (full_name, email, phone, wallet_balance) VALUES
('Nguyen Van A', 'vana@gmail.com', '0912345678', 500000.00),
('Tran Thi B', 'thib@gmail.com', '0923456789', 120000.00),
('Le Van C', 'vanc@gmail.com', '0934567890', 0.00),
('Pham Minh D', 'minhd@gmail.com', '0945678901', 250000.00),
('Hoang Thi E', 'thie@gmail.com', '0956789012', 1050000.00),
('Vu Hoang F', 'hoangf@gmail.com', '0967890123', 50000.00),
('Do Thi G', 'thig@gmail.com', '0978901234', 320000.00),
('Bui Van H', 'vanh@gmail.com', '0989012345', 75000.00),
('Dang Thi I', 'thii@gmail.com', '0990123456', 0.00),
('Ngo Van K', 'vank@gmail.com', '0901234567', 1500000.00);


-- Chèn dữ liệu cho bảng RESTAURANTS (10 nhà hàng)
INSERT INTO restaurants (restaurant_name, address, rating, is_active) VALUES
 ('Bun Cha Obama', '24 Le Van Huu, Hai Ba Trung, Ha Noi', 4.8, 1),
 ('Phở Thìn Bờ Hồ', '61 Dinh Tien Hoang, Hoan Kiem, Ha Noi', 4.5, 1),
 ('Com Tam Cali', '123 Nguyen Hue, Quan 1, TP HCM', 4.2, 1),
 ('Pizza Hut Cầu Giấy', '222 Xuan Thuy, Cau Giay, Ha Noi', 4.0, 1),
 ('Gà Rán KFC Kim Mã', '102 Kim Ma, Ba Dinh, Ha Noi', 4.1, 1),
 ('Bánh Mì Huỳnh Hoa', '26 Le Thi Rieng, Quan 1, TP HCM', 4.9, 1),
 ('Trà Sữa DingTea', '88 Tran Dai Nghia, Hai Ba Trung, Ha Noi', 3.9, 1),
 ('Sushi Kei', 'Tầng 3 Aeon Mall Long Bien, Ha Noi', 4.4, 1),
 ('Lẩu Phan', '7 Đào Duy Anh, Dong Da, Ha Noi', 4.3, 1),
 ('Cơm Niêu Sài Gòn', '59 Ho Xuan Huong, Quan 3, TP HCM', 4.6, 1);


-- Chèn dữ liệu cho bảng FOODS (10 món ăn phân bổ ở các nhà hàng)
INSERT INTO foods (restaurant_id, food_name, price, stock_quantity, is_available) VALUES
 (1, 'Bún Chả Đặc Biệt', 60000.00, 50, 1),
 (1, 'Nem Cua Bể', 20000.00, 100, 1),
 (2, 'Phở Bò Tái Lăn', 55000.00, 30, 1),
 (3, 'Cơm Tấm Sườn Bì Chả', 65000.00, 40, 1),
 (4, 'Pizza Hải Sản Cỡ Vừa', 189000.00, 15, 1),
 (5, 'Combo Gà Rán 2 Miếng', 89000.00, 60, 1),
 (6, 'Bánh Mì Thập Cẩm', 58000.00, 120, 1),
 (7, 'Trà Sữa Trân Châu Ô Long', 45000.00, 200, 1),
 (9, 'Buffet Lẩu Bò 199k', 199000.00, 80, 1),
 (10, 'Cơm Niêu Đập', 75000.00, 25, 1);


-- Chèn dữ liệu cho bảng ORDERS (10 đơn hàng giả lập các tình huống)
INSERT INTO orders (user_id, restaurant_id, total_amount, order_status) 
VALUES
(1, 1, 140000.00, 'COMPLETED'), -- User 1 mua ở nhà hàng 1 (2 bún chả + 1 nem)
(1, 4, 189000.00, 'SHIPPING'),  -- User 1 mua tiếp đơn thứ hai ở nhà hàng 4
(2, 2, 55000.00, 'COMPLETED'),  -- User 2 mua phở
(4, 3, 65000.00, 'PREPARING'),  -- User 4 đơn đang chuẩn bị
(5, 6, 116000.00, 'COMPLETED'), -- User 5 mua 2 bánh mì Huỳnh Hoa
(5, 9, 398000.00, 'COMPLETED'), -- User 5 đi ăn lẩu với bạn
(7, 7, 45000.00, 'PENDING'),    -- User 7 đang chờ duyệt trà sữa
(8, 5, 89000.00, 'CANCELLED'),  -- User 8 hủy đơn gà rán
(10, 10, 150000.00, 'COMPLETED'),-- User 10 mua 2 phần cơm niêu
(10, 1, 60000.00, 'PENDING');   -- User 10 đặt thêm bún chả


-- PHẦN 3: BÀI TẬP TRUY VẤN CƠ BẢN
-- MỤC A:TRUY VẤN DỮ LIỆU CƠ BẢN (SELECT, WHERE, ORDER BY) 
-- Bài 1: Xem toàn bộ thực đơn món ăn đang mở bán
select *
from foods
where  is_available = 1;

-- Bài 2: Lọc các nhà hàng có chất lượng dịch vụ cao nhất
select *
from restaurants
where rating >= 4.5;

-- Bài 3: Kiểm tra danh sách khách hàng có số dư ví điện tử lớn
select *
from users
where wallet_balance > 200000;

-- MỤC B: TRUY VẤN THỐNG KÊ VÀ ĐẾM DỮ LIỆU (COUNT, LIMIT)  
-- Bài 4: Kiểm tra các đơn hàng mới phát sinh đang chờ duyệt 
select *
from orders
where order_status = 'PENDING'
order by order_status desc 
limit 5;

-- Bài 5: Thống kê số lượng đối tác nhà hàng đang hoạt động
select count(restaurant_id) as 'total_restaurant'
from restaurants
where is_active = 1;

-- PHẦN 4: BÀI TẬP TRUY VẤN NÂNG CAO & LOGIC NGHIỆP VỤ
-- MỤC A: TRUY VẤN NÂNG CAO (JOIN, GROUP BY, SUBQUERY)
-- Bài 1: Thống kê doanh thu theo từng nhà hàng
select r.restaurant_id,r.restaurant_name, sum(o.total_amount)
from restaurants r join  orders o on r.restaurant_id = o.restaurant_id
where order_status = 'COMPLETED'
group by r.restaurant_id,r.restaurant_name;

-- Bài 2: Tìm khách hàng "VIP" chi tiêu nhiều nhất
select u.user_id,u.full_name , sum(o.total_amount) AS total_spent
from users u join orders o on u.user_id = o.user_id
group by u.user_id,u.full_name 
order by sum(o.total_amount) desc
limit 3

-- Bài 3: Tìm các món ăn có giá cao hơn mức giá trung bình (Ứng dụng Subquery độc lập)
SELECT food_id, food_name,rice
FROM foods
WHERE price > (
    SELECT AVG(price)
    FROM foods
);

-- Bài 4: Tìm kiếm nhà hàng "Ế" chưa có đơn hàng nào
SELECT r.restaurant_id,
       r.restaurant_name,
       r.address
FROM restaurants r
LEFT JOIN orders o
ON r.restaurant_id = o.restaurant_id
WHERE o.order_id IS NULL;

-- MỤC B: THỦ TỤC LƯU TRỮ (STORED PROCEDURE)
-- Bài 5: Procedure lấy danh sách món ăn của một nhà hàng
DELIMITER //
CREATE PROCEDURE sp_get_foods_by_restaurant(
    IN p_restaurant_id INT
)
BEGIN
    SELECT food_id,
           food_name,
           price,
           stock_quantity,
           is_available
    FROM foods
    WHERE restaurant_id = p_restaurant_id;
END //
DELIMITER ;
CALL sp_get_foods_by_restaurant(1);

-- Bài 6: Procedure kiểm tra và nạp tiền vào ví điện tử
DELIMITER //
CREATE PROCEDURE sp_topup_wallet(
    IN p_user_id INT,
    INOUT p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE current_balance DECIMAL(10,2);
    SELECT wallet_balance
    INTO current_balance
    FROM users
    WHERE user_id = p_user_id;
    UPDATE users
    SET wallet_balance = wallet_balance + p_amount
    WHERE user_id = p_user_id;
    SET p_amount = current_balance + p_amount;
END //
DELIMITER ;

SET @money = 100000;
CALL sp_topup_wallet(1, @money);
SELECT @money AS new_balance;

-- MỤC C: KÍCH HOẠT
-- Bài 7: Tự động khóa món ăn khi số lượng tồn kho bằng 0
DELIMITER //
CREATE TRIGGER trg_auto_disable_food
BEFORE UPDATE
ON foods
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity = 0 THEN
        SET NEW.is_available = 0;
    END IF;
END //
DELIMITER ;

UPDATE foods
SET stock_quantity = 0
WHERE food_id = 1;

-- Bài 8: Ngăn chặn tạo đơn hàng khi ví người dùng không đủ tiền
DELIMITER //
CREATE TRIGGER trg_check_wallet_before_order
BEFORE INSERT
ON orders
FOR EACH ROW
BEGIN
    DECLARE user_balance DECIMAL(10,2);
    SELECT wallet_balance
    INTO user_balance
    FROM users
    WHERE user_id = NEW.user_id;
    IF user_balance < NEW.total_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'So du vi khong du de thanh toan';
    END IF;
END //
DELIMITER ;

INSERT INTO orders (
    user_id,
    restaurant_id,
    total_amount,
    order_status
)
VALUES (3, 1, 100000, 'PENDING');

-- MỤC D: GIAO DỊCH VÀ TOÀN VẸN DỮ LIỆU 
-- Bài 9: Quy trình xử lý thanh toán đơn hàng tự động 
DELIMITER //
CREATE PROCEDURE sp_complete_order(
    IN p_order_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_balance DECIMAL(10,2);
    START TRANSACTION;
    SELECT user_id, total_amount
    INTO v_user_id, v_amount
    FROM orders
    WHERE order_id = p_order_id;
    SELECT wallet_balance
    INTO v_balance
    FROM users
    WHERE user_id = v_user_id;
    IF v_balance < v_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong du tien trong vi';
    ELSE
        UPDATE users
        SET wallet_balance = wallet_balance - v_amount
        WHERE user_id = v_user_id;
        UPDATE orders
        SET order_status = 'COMPLETED'
        WHERE order_id = p_order_id;
        COMMIT;
    END IF;
END //
DELIMITER ;

CALL sp_complete_order(10);

-- Bài 10: Xử lý hủy đơn và hoàn tiền khi xảy ra sự cố
DELIMITER //
CREATE PROCEDURE sp_cancel_order(
    IN p_order_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    SELECT user_id, total_amount
    INTO v_user_id, v_amount
    FROM orders
    WHERE order_id = p_order_id;
    UPDATE users
    SET wallet_balance = wallet_balance + v_amount
    WHERE user_id = v_user_id;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Gia lap loi giao dich';
    UPDATE orders
    SET order_status = 'CANCELLED'
    WHERE order_id = p_order_id;
    COMMIT;
END //
DELIMITER ;

CALL sp_cancel_order(2);

-- Bài 11: Procedure tích hợp Transaction hoàn chỉnh
DELIMITER //
CREATE PROCEDURE sp_place_order(
    IN p_user_id INT,
    IN p_food_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_restaurant_id INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    SELECT restaurant_id,price,stock_quantity
    INTO v_restaurant_id,v_price,v_stock
    FROM foods
    WHERE food_id = p_food_id;
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mon an khong du so luong';
    END IF;
    SET v_total = v_price * p_quantity;
    UPDATE foods
    SET stock_quantity = stock_quantity - p_quantity
    WHERE food_id = p_food_id;
    INSERT INTO orders(
        user_id,
        restaurant_id,
        total_amount,
        order_status
    )
    VALUES(p_user_id,v_restaurant_id,v_total,'PENDING');
    COMMIT;
END //
DELIMITER ;

CALL sp_place_order(1, 1, 2);
CALL sp_place_order(1, 1, 1000);