CREATE DATABASE bai4;
USE bai4;

-- giải pháp 1
-- Dùng = kết hợp OR khi có 1 đk đúng đơn hàng sẽ đc lấy nhưng tương đối dai dòng
SELECT *
FROM Orders
WHERE cancel_reason = 'KHACH_HUY'
   OR cancel_reason = 'QUAN_DONG_CUA'
   OR cancel_reason = 'KHONG_CO_TAI_XE'
   OR cancel_reason = 'BOM_HANG';
-- giải pháp 2
-- Dùng IN () viết ngắn gọn hơn cách 1 do in thực chất là cú pháp rút gọn của nhiều OR nên chọn cách 2
SELECT *  
FROM Orders
WHERE cancel_reason IN (
    'KHACH_HUY',
    'QUAN_DONG_CUA',
    'KHONG_CO_TAI_XE',
    'BOM_HANG'
);