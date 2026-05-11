create database bai4;
use bai4;

/*
Hướng tiếp cận 1:
không dùng WHERE
Gom nhóm toàn bộ booking của khách sạn
Sau đó dùng HAVING để kiểm tra:
chỉ tính booking COMPLETED
số lượng ≥ 50
AVG(total_price) > 3000000
*/
SELECT hotel_id
FROM Bookings
GROUP BY hotel_id
HAVING  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) >= 50
		AND AVG(
        CASE 
            WHEN status = 'COMPLETED' THEN total_price
            ELSE NULL
        END) > 3000000;

/*
Hướng tiếp cận 2:
Dùng: WHERE status = 'COMPLETED'
để loại bỏ dữ liệu rác ngay từ đầu.
Sau đó mới: GROUP BY hotel_id và HAVING
*/
SELECT hotel_id
FROM Bookings
WHERE status = 'COMPLETED'
GROUP BY hotel_id
HAVING COUNT(*) >= 50
   AND AVG(total_price) > 3000000;
   
/*
bảng so sánh 2 hướng tiếp cận
| Tiêu chí                 | Cách 1 - Lọc Trễ |      Cách 2 - Lọc Sớm |
| ------------------------ | ---------------: | --------------------: |
| Dữ liệu đưa vào GROUP BY |  Toàn bộ booking | Chỉ booking COMPLETED |
| CPU                      |              Cao |                  Thấp |
| RAM                      |        Tốn nhiều |                Ít hơn |
| Temporary Table          |              Lớn |                   Nhỏ |
| Tốc độ                   |             Chậm |                 Nhanh |
| Khả năng scale           |              Kém |                   Tốt |
--> nên dùng cách 2
*/