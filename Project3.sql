-- Sử dụng dataset đã được xử lý ở PROJECT 1, phân tích theo các ý sau:

-- 1) Doanh thu theo từng ProductLine, Year và DealSize?
-- Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE
SELECT productline, year_id, dealsize,
SUM(sales) AS revenue
FROM SALES_DATASET_RFM_PRJ_CLEAN
WHERE status = 'Shipped'
GROUP BY productline, year_id, dealsize;


-- 2) Đâu là tháng có bán tốt nhất mỗi năm?
-- Output: MONTH_ID, REVENUE, ORDER_NUMBER
SELECT month_id, year_id,
SUM(sales) AS revenue,
COUNT(ordernumber) AS order_number
FROM SALES_DATASET_RFM_PRJ_CLEAN
WHERE status = 'Shipped'
GROUP BY month_id, year_id
ORDER BY year_id, revenue DESC, order_number DESC
--> Các tháng bán tốt nhất: Tháng 11 năm 2003, Tháng 11 năm 2004, Tháng 2 năm 2005


-- 3) Product line nào được bán nhiều ở tháng 11?
-- Output: MONTH_ID, REVENUE, ORDER_NUMBER
SELECT month_id, productline,
SUM(sales) AS revenue,
COUNT(ordernumber) AS order_number
FROM SALES_DATASET_RFM_PRJ_CLEAN
WHERE month_id = 11 AND status = 'Shipped'
GROUP BY month_id, productline
ORDER BY order_number DESC
--> Product line: Classic Cars bán nhiều ở T11


-- 4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
-- Xếp hạng các các doanh thu đó theo từng năm.
-- Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK
SELECT *, 
RANK() OVER(PARTITION BY year_id ORDER BY revenue DESC) AS rank
FROM(
	SELECT year_id, productline,
	SUM(sales) AS revenue
	FROM SALES_DATASET_RFM_PRJ_CLEAN
	WHERE status = 'Shipped' AND country = 'UK'
	GROUP BY year_id, productline
)
--> Sản phẩm có doanh thu tốt nhất theo năm ở UK là: Classic Cars (năm 2023), Vintage Cars (năm 2024), Motorcycle (năm 2025)


-- 5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
WITH customer_rfm AS (
	SELECT customername,
	current_date - MAX(orderdate) AS R,
	COUNT(DISTINCT ordernumber) AS F,
	SUM(sales) AS M
	FROM SALES_DATASET_RFM_PRJ_CLEAN
	WHERE status = 'Shipped'
	GROUP BY customername
)
, rfm_score AS (
	SELECT customername,
	ntile(5) OVER (ORDER BY R DESC) AS r_score,
	ntile(5) OVER (ORDER BY F) AS f_score,
	ntile(5) OVER (ORDER BY M) AS m_score
	FROM customer_rfm
)
, rfm_final AS (
	SELECT customername, 
	CAST(r_score AS varchar) || CAST(f_score AS varchar) || CAST(m_score AS varchar) AS rfm_score
	FROM rfm_score
)
, customer_retention AS (
SELECT b.customername, a.segment
FROM segment_score AS a
JOIN rfm_final AS b ON a.scores = b.rfm_score
ORDER BY segment
)

SELECT * 
FROM customer_retention
WHERE segment = 'Champions'
