create database bai3;
use bai3;

/*
Ý tưởng xử lý
Bước 1: Gom nhóm theo người dùng
Dùng:GROUP BY user_id
để gom toàn bộ booking của từng khách hàng.
Bước 2: Đếm tổng số booking
Dùng: COUNT(*)
Vì yêu cầu là:đếm tất cả booking bất kể trạng thái
Bước 3: Chỉ đếm booking bị hủy 
Ta dùng: SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END)
*/

-- Triển khai
SELECT 
    user_id,
    COUNT(*) AS total_bookings,
    SUM(IF(status = 'CANCELLED', 1, 0)) AS cancelled_bookings
FROM Bookings
GROUP BY user_id
HAVING COUNT(*) >= 10
AND SUM(IF(status = 'CANCELLED', 1, 0)) > 5;