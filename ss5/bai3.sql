CREATE DATABASE bai3;
USE bai3;

SELECT driver_id,driver_name,status,trust_score,distance_km
FROM Drivers
WHERE status = 'AVAILABLE' -- chỉ lấy tài xế sẵn sàng nhận đơn
AND trust_score between 3.5 and 5 -- lấy điểm đánh giá từ 3.5 đến 5 sao 
ORDER BY distance_km ASC, -- khoảng cách lấy từ gần đến xa
         trust_score DESC; -- điểm đánh giá lấy từ cao nhất 