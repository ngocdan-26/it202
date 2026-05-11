create database bai2;
use bai2;

SELECT hotel_id, room_name, MIN(price_per_night) -- do mỗi hotel_id sẽ có nhiều room_name 
												 -- nên khi lấy bảng có room_name thì sẽ không biểt lấy tên phòng nào
FROM Rooms
GROUP BY hotel_id; 
    
-- sửa lại cho đúng
SELECT hotel_id,MIN(price_per_night) AS cheapest_price
FROM Rooms
GROUP BY hotel_id;