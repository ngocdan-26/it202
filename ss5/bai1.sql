CREATE DATABASE bai1;
USE bai1;

SELECT restaurant_name, address, rating
FROM Restaurants
WHERE district = 'Quận 1' OR district = 'Quận 3' AND rating > 4.0;  -- do and được ưu tiên hơn or nên code chỉ lấy 
																	-- điểm đánh giá của quận 3 trên 4.0 còn quân 1 lấy cae đánh giá dưới 4.0
-- code sửa lại để lấy đánh giá cả 2 quận trên 4.0
SELECT restaurant_name, address, rating
FROM Restaurants
WHERE district IN ('Quận 1', 'Quận 3') AND rating > 4.0;                                                        
			