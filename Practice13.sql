--ex1
SELECT COUNT(*) FROM
  (SELECT company_id, title FROM job_listings
  GROUP BY company_id, title
  HAVING COUNT(*) > 1) AS new_table;

--ex2
SELECT category, product, total_spend FROM
  (SELECT category, product, SUM(spend) AS total_spend,
  RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) rank FROM product_spend
  WHERE EXTRACT(year FROM transaction_date) = 2022
  GROUP BY category, product) AS new_table
WHERE rank <= 2;

--ex3
SELECT COUNT(*) AS member_count FROM
  (SELECT policy_holder_id FROM callers
  GROUP BY policy_holder_id
  HAVING COUNT(*) >= 3
  ) AS new_table;
  
--ex4
SELECT page_id FROM pages
WHERE page_id NOT IN (SELECT page_id FROM page_likes);

--ex5
SELECT 7 AS month, COUNT(*) AS monthly_active_users FROM 
  (SELECT user_id, COUNT(*) FROM
    (SELECT user_id, EXTRACT(month FROM event_date) FROM user_actions
    WHERE EXTRACT(month FROM event_date) IN (6, 7)
    GROUP BY user_id, EXTRACT(month FROM event_date)) AS new_table
  GROUP BY user_id
  HAVING COUNT(*) = 2) AS new_table2;

--ex6
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, country, COUNT(*) AS trans_count,
SUM(
    CASE
        WHEN state = 'approved' THEN 1
        ELSE 0
    END
) AS approved_count, 
SUM(amount) AS trans_total_amount,
SUM(
    CASE
        WHEN state = 'approved' THEN amount
        ELSE 0
    END
) AS approved_total_amount
FROM Transactions
GROUP BY DATE_FORMAT(trans_date, '%Y-%m'), country;

--ex7
SELECT a.product_id, a.year AS first_year, a.quantity, a.price
FROM Sales AS a
JOIN 
    (SELECT product_id, MIN(year) AS first_year FROM Sales
    GROUP BY product_id) AS b
ON a.product_id = b.product_id AND a.year = b.first_year;

--ex8
SELECT customer_id FROM 
    (SELECT a.* FROM Customer AS a
    JOIN Product AS b
    ON a.product_key = b.product_key) AS new_table
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);

--ex9
SELECT employee_id FROM Employees
WHERE salary < 30000 AND manager_id IS NOT NULL AND manager_id NOT IN (SELECT employee_id FROM Employees)
ORDER BY employee_id;

--ex10
SELECT COUNT(*) AS duplicate_companies FROM
  (SELECT company_id AS so_post FROM job_listings
  GROUP BY company_id, title
  HAVING COUNT(*) > 1) AS new_table;

--ex11


