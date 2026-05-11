create database  bai1;
use bai1;

SELECT city, SUM(total_price) AS revenue
FROM Bookings
WHERE status = 'COMPLETED' AND SUM(total_price) > 0 -- đoạn mã sd where để lấy sum là sai do where lọc dữ liệu gốc trước khi nhóm
GROUP BY city;

-- viết lại câu lệnh 
SELECT city, SUM(total_price) AS revenue
FROM Bookings
WHERE status = 'COMPLETED'
GROUP BY city
HAVING SUM(total_price) > 0;