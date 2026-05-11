create database bai5;
use bai5;

/*
Bẫy dữ liệu logic (NOT IN vs NULL): Nếu bạn dùng cấu trúc WHERE room_id NOT IN (SELECT room_id FROM Bookings),
hệ thống có nguy cơ trả về 0 kết quả nếu trong bảng Bookings có chứa dù chỉ 1 bản ghi có room_id bị NULL thì :
WHERE room_id NOT IN (
    SELECT room_id FROM Bookings
)
có nguy cơ trả về 0 kết quả vì về mặt toán học:
NOT IN
được SQL hiểu như chuỗi phép so sánh AND.
*/

/* Thiết kế giải pháp an toàn: Dùng LEFT JOIN + IS NULL
Logic hoạt động
LEFT JOIN lấy toàn bộ phòng từ Rooms
Nếu phòng đã có booking → join được dữ liệu
Nếu chưa từng được đặt → phía Bookings sẽ là NULL
*/
SELECT r.room_id, r.room_name
FROM Rooms r
LEFT JOIN Bookings b
    ON r.room_id = b.room_id
WHERE b.room_id IS NULL;