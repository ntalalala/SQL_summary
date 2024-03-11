SELECT * FROM SALES_DATASET_RFM_PRJ;
-- 1.Chuyển đổi kiểu dữ liệu phù hợp cho các trường (sử dụng câu lệnh ALTER) 
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN ordernumber TYPE integer USING(trim(ordernumber) :: integer);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN quantityordered TYPE smallint USING(trim(quantityordered) :: smallint);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN priceeach TYPE numeric USING(trim(priceeach) :: numeric);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderlinenumber TYPE smallint USING(trim(orderlinenumber) :: smallint);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN sales TYPE numeric USING(trim(sales) :: numeric);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE timestamp with time zone USING orderdate :: timestamp with time zone;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN status TYPE varchar(15) USING(trim(status) :: varchar(15));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productline TYPE varchar(20) USING(productline :: varchar(20));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN msrp TYPE smallint USING(trim(msrp) :: smallint);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productcode TYPE varchar(15) USING(productcode :: varchar(15));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN customername TYPE text USING(customername :: text);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN phone TYPE varchar(20) USING(phone :: varchar(20)); 

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline1 TYPE text USING(addressline1 :: text);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline2 TYPE text USING(addressline2 :: text);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN city TYPE varchar(20) USING(city :: varchar(20));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN state TYPE varchar(20) USING(state :: varchar(20));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN postalcode TYPE varchar(15) USING(postalcode :: varchar(15));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN country TYPE varchar(15) USING(country :: varchar(15));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN territory TYPE varchar(10) USING(territory :: varchar(10));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN contactfullname TYPE varchar(25) USING(contactfullname :: varchar(25));

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN dealsize TYPE varchar(10) USING(dealsize :: varchar(15));

-- 2. Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
SELECT * 
FROM SALES_DATASET_RFM_PRJ
WHERE ordernumber IS NULL 
OR quantityordered IS NULL
OR priceeach IS NULL 
OR orderlinenumber IS NULL 
OR sales IS NULL
OR orderdate IS NULL 
 -- -> None

-- 3.Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
-- Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. 
-- Gợi ý: ( ADD column sau đó INSERT)
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN CONTACTFIRSTNAME text,
ADD COLUMN CONTACTLASTNAME text;

UPDATE SALES_DATASET_RFM_PRJ 
SET 
	CONTACTFIRSTNAME = UPPER(LEFT(contactfullname, 1)) || LOWER(SUBSTRING(contactfullname FROM 2 FOR POSITION('-' IN contactfullname) - 2)),
	CONTACTLASTNAME = UPPER(SUBSTRING(contactfullname FROM POSITION('-' IN contactfullname) + 1 FOR 1)) || LOWER(RIGHT(contactfullname, LENGTH(contactfullname) -  POSITION('-' IN contactfullname) - 1));	

-- 4. Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Quý, tháng, năm được lấy ra từ ORDERDATE 
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN QTR_ID smallint,
ADD COLUMN MONTH_ID smallint,
ADD COLUMN YEAR_ID smallint;

UPDATE SALES_DATASET_RFM_PRJ
SET
	MONTH_ID = EXTRACT(month FROM orderdate),
	YEAR_ID = EXTRACT(year FROM orderdate);

UPDATE SALES_DATASET_RFM_PRJ
SET
	QTR_ID = 
	CASE 
		WHEN MONTH_ID IN (1, 2, 3) THEN 1
		WHEN MONTH_ID IN (4, 5, 6) THEN 2
		WHEN MONTH_ID IN (7, 8, 9) THEN 3
		ELSE 4
	END;

SELECT * FROM SALES_DATASET_RFM_PRJ;

-- 5. Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) ( Không chạy câu lệnh trước khi bài được review)

-- C1: IQR = Q3 - Q1, min = Q1 - 1.5*IQR, max = Q3 + 1.5*IQR, outlier > max or < min
-- Q1 = 27, Q3 = 43, IQR = 16, min = 3, max = 67
CREATE TEMP TABLE cte1 AS(
	SELECT 
		Q1 - 1.5*IQR AS min,
		Q3 + 1.5*IQR AS max
	FROM(
		SELECT
			percentile_cont(0.25) WITHIN GROUP(ORDER BY quantityordered) AS Q1,
			percentile_cont(0.75) WITHIN GROUP(ORDER BY quantityordered) AS Q3,
			percentile_cont(0.75) WITHIN GROUP(ORDER BY quantityordered) - percentile_cont(0.25) WITHIN GROUP(ORDER BY quantityordered) AS IQR
		FROM SALES_DATASET_RFM_PRJ
	)
);
-- các outlier c1
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered > (SELECT max FROM cte1) OR quantityordered < (SELECT min FROM cte1)

-- C2: z-score = (quantity - AVG(quantity))/stddev, outlier when |z| > 3 and consider outlier when |z| > 2
CREATE TEMP TABLE cte2 AS (
	SELECT *
	FROM SALES_DATASET_RFM_PRJ
	WHERE ABS((quantityordered - (SELECT AVG(quantityordered) FROM SALES_DATASET_RFM_PRJ))*1.0 / (SELECT stddev(quantityordered) FROM SALES_DATASET_RFM_PRJ)) > 2
);

----Xử lí outlier + chưa chạy
-- C1: Xoá outlier khỏi database
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered IN (SELECT quantityordered FROM cte2);

-- C2: Thay thế outlier với GT trung bình
UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = (SELECT AVG(quantityordered) FROM SALES_DATASET_RFM_PRJ)
WHERE quantityordered IN (SELECT quantityordered FROM cte2);

--6. Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới tên là SALES_DATASET_RFM_PRJ_CLEAN
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS(
	SELECT * FROM SALES_DATASET_RFM_PRJ
)
