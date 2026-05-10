CREATE DATABASE bai2;
USE bai2;

SELECT restaurant_name, created_at
FROM Restaurants
LIMIT 5;  	-- vì để mình limit mà không dùng order by  nên csdl sẽ trả về ngẫu nhiên 5 dòng dòng 
			-- đầu tiên theo cách lưu trữ vật lý trong database hoặc thứ tự khác sau mỗi lần refresh / tối ưu query / thay đổi index
            
-- sửa lại code 
SELECT restaurant_name, created_at
FROM Restaurants
ORDER BY created_at DESC -- thêm order by sắp sếp desc để lấy các dl mới nhất 
LIMIT 5;
			