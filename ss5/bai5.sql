CREATE DATABASE bai5;
USE bai5;

SELECT customer_name AS Ten_Khach_Hang,
    CASE -- là câu lệnh tự động rẽ nhánh và tạo cột trong sql 
        WHEN total_orders IS NULL THEN 'Chưa phân loại' -- nếu null thì sẽ sếo vào không phân loại
        WHEN total_orders > 500 THEN 'Kim Cương'
        WHEN total_orders BETWEEN 100 AND 500 THEN 'Vàng'
        ELSE 'Bạc'
    END AS Xep_Hang
FROM Users;