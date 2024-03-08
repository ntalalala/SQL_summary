--ex1
WITH cte AS (
    SELECT * 
    FROM (
        SELECT *,
        RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank
        FROM Delivery
    )
    WHERE rank = 1
)

SELECT ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cte), 2) AS immediate_percentage
FROM cte
WHERE order_date = customer_pref_delivery_date;

--ex2
SELECT ROUND(COUNT(*) * 1.0 / (SELECT COUNT(DISTINCT player_id) FROM Activity), 2) AS fraction  
FROM(
    SELECT *,
    LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) - event_date AS diff,
    RANK() OVER(PARTITION BY player_id ORDER BY event_date) AS rank
    FROM Activity
) AS new_table
WHERE rank = 1 AND diff = 1;

--ex3
SELECT id,
CASE
    WHEN id % 2 = 0 AND lag IS NOT NULL THEN lag
    WHEN id % 2 != 0 AND lead IS NOT NULL THEN lead
    ELSE student
END AS student
FROM (
    SELECT *,
    LEAD(student) OVER (ORDER BY id),
    LAG(student) OVER (ORDER BY id)
    FROM Seat
) AS new1;

--ex4
WITH cte AS(
    SELECT visited_on, amount, 
    CASE
        WHEN LAG(amount, 7) OVER(ORDER BY visited_on) IS NULL THEN 0
        ELSE LAG(amount, 7) OVER(ORDER BY visited_on)
    END AS lag_amount
    FROM (
        SELECT visited_on,  
        SUM(amount) OVER(ORDER BY visited_on) AS amount
        FROM(
            SELECT visited_on, 
            SUM(amount) AS amount 
            FROM Customer
            GROUP BY visited_on
        )
    )
    ORDER BY visited_on
)

SELECT visited_on, 
amount - lag_amount AS amount,
ROUND((amount - lag_amount)*1.0 / 7, 2) AS average_amount FROM cte
WHERE visited_on - (SELECT MIN(visited_on) FROM cte) + 1 >= 7;

--ex5
SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM Insurance
WHERE tiv_2015 IN (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) IN (
    SELECT lat, lon 
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
);

--ex6
SELECT Department, Employee, Salary
FROM(
    SELECT a.name AS Department, b.name AS Employee, b.salary AS Salary,
    DENSE_RANK() OVER(PARTITION BY b.departmentId ORDER BY b.salary DESC) AS rank
    FROM Department AS a
    JOIN Employee AS b ON a.id = b.departmentId
)
WHERE rank <= 3;

--ex7
SELECT person_name 
FROM (
    SELECT person_name, 
    SUM(weight) OVER (ORDER BY turn) AS total_weight
    FROM Queue
    ORDER BY turn
) AS new_table
WHERE total_weight <= 1000
ORDER BY total_weight DESC
LIMIT 1;

--ex8
SELECT DISTINCT a.product_id, 
CASE
    WHEN b.price IS NULL THEN 10
    ELSE b.price
END AS price
FROM Products AS a
LEFT JOIN (
    SELECT *,
    FIRST_VALUE(new_price) OVER(PARTITION BY product_id ORDER BY change_date DESC) AS price FROM Products 
    WHERE change_date <= '2019-08-16'
) AS b
ON a.product_id = b.product_id;

