-- 1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
-- Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng (Từ 1/2019-4/2022)
-- Output: month_year ( yyyy-mm) , total_user, total_orde
-- Insight là gì? ( nhận xét về sự tăng giảm theo thời gian)
SELECT * FROM bigquery-public-data.thelook_ecommerce.orders;

SELECT FORMAT_DATETIME('%Y-%m', created_at) AS month_year,
COUNT(user_id) AS total_user,
COUNT(order_id) AS total_ord 
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete' AND FORMAT_DATETIME('%Y-%m', created_at) BETWEEN '2019-01' AND '2022-04'
GROUP BY 1
ORDER BY month_year;

-- Insight: Nhìn chung số lượng đơn hàng và số lượng khách hàng mỗi tháng có xu hướng tăng theo thời gian từ T1/2019 đến T4/2022 đạt đỉnh 477 đơn hàng với 476 người mua vào tháng 4/2022

-- 2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
-- Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng 
-- (Từ 1/2019-4/2022)
-- Output: month_year ( yyyy-mm), distinct_users, average_order_value
-- Hint: Giá trị đơn hàng lấy trường sale_price từ bảng order_items
-- giá trị đơn hàng trung bình = tổng giá trị đơn hàng trong tháng/số lượng đơn hàng
-- Insight là gì?  ( nhận xét về sự tăng giảm theo thời gian)
SELECT * FROM bigquery-public-data.thelook_ecommerce.order_items;

SELECT FORMAT_DATETIME('%Y-%m', created_at) AS month_year,
COUNT(DISTINCT user_id) AS distinct_user,
ROUND(SUM(sale_price) / COUNT(DISTINCT order_id), 2) AS average_order_items
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE status = 'Complete' AND FORMAT_DATETIME('%Y-%m', created_at) BETWEEN '2019-01' AND '2022-04'
GROUP BY 1
ORDER BY month_year;

-- Insight: Tổng số người dùng khác nhau mỗi tháng có xu hương tăng dần theo thời gian từ T1/2019 đến T4/2022
-- Về giá trị đơn hàng trung bình từ T1/2019 đến T10/2019 có nhiều biến động mạnh, đạt đỉnh 128.35 vào T2/2019 và sau đó giảm mạnh đến T5/2019 còn 66.14. Từ T5/2019 đến T9/2019 nhìn chung giá trị trung bình tăng dần dù có biến động nhẹ đạt đỉnh 108.77 vào T9/2019. Từ T10/2019 - T4/2022 giá trị trung bình đơn hàng có xu hướng ổn định và sự dao động trong khoảng 75.78 đến 99.87 

-- 3. Nhóm khách hàng theo độ tuổi
-- Tìm các khách hàng trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính (Từ 1/2019-4/2022)
-- Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)
-- Hint: Sử dụng UNION các KH tuổi trẻ nhất với các KH tuổi trẻ nhất 
-- tìm các KH tuổi trẻ nhất và gán tag ‘youngest’  
-- tìm các KH tuổi trẻ nhất và gán tag ‘oldest’ 
-- Insight là gì? (Trẻ nhất là bao nhiêu tuổi, số lượng bao nhiêu? Lớn nhất là bao nhiêu tuổi, số lượng bao nhiêu) 
-- Note: Lưu output vào temp table rồi đếm số lượng tương ứng 
SELECT * FROM bigquery-public-data.thelook_ecommerce.users;

WITH customer_age_sorting AS (
  SELECT first_name, last_name, gender, age,
  CASE
    WHEN rank1 = 1 THEN 'youngest'
    WHEN rank2 = 1 THEN 'oldest'
  END AS tag
  FROM (
    SELECT a.first_name, a.last_name, a.gender, a.age,
    RANK() OVER(PARTITION BY a.gender ORDER BY a.age) AS rank1,
    RANK() OVER(PARTITION BY a.gender ORDER BY a.age DESC) AS rank2
    FROM bigquery-public-data.thelook_ecommerce.users AS a
    JOIN bigquery-public-data.thelook_ecommerce.orders AS b
    ON a.id = b.user_id
    WHERE b.status = 'Complete' AND FORMAT_DATETIME('%Y-%m', b.created_at) BETWEEN '2019-01' AND '2022-04'
  ) AS new1
  WHERE rank1 = 1 OR rank2 = 1
),

-- SELECT gender, age, COUNT(*)
-- FROM customer_age_sorting
-- GROUP BY gender,age

customer_age_oldest_youngest AS (
  SELECT gender, age, COUNT(*)
  FROM customer_age_sorting
  GROUP BY gender,age
),

-- Insight: Từ T1/2019 đến T4/2022 có 65 khách hàng nữ trẻ tuổi nhất (12 tuổi) và 67 khách hàng nữ lớn tuổi nhất (70 tuổi)
--          Có 66 khách hàng nam trẻ tuổi nhất (12 tuổi) và 86 khách hàng nữ lớn tuổi nhất (70 tuổi)

-- 4.Top 5 sản phẩm mỗi tháng.
-- Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). 
-- Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month
-- Hint: Sử dụng hàm dense_rank()
Top5_highest_profit_products AS (
  SELECT * FROM (
    SELECT FORMAT_DATETIME('%Y-%m', a.created_at) AS month_year, a.product_id, b.name AS product_name,
    a.sale_price AS sales, b.cost, a.sale_price - b.cost AS profit, 
    DENSE_RANK() OVER (PARTITION BY FORMAT_DATETIME('%Y-%m', a.created_at) ORDER BY a.sale_price - b.cost DESC)
    AS rank_per_month
    FROM bigquery-public-data.thelook_ecommerce.order_items AS a
    JOIN bigquery-public-data.thelook_ecommerce.products AS b ON a.product_id = b.id
  ) AS new2
  WHERE rank_per_month <= 5
  ORDER BY month_year, rank_per_month
)

SELECT * FROM Top5_highest_profit_products

-- 5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
-- Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
-- Output: dates (yyyy-mm-dd), product_categories, revenue

