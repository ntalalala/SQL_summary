--ex1
SELECT DISTINCT CITY FROM STATION
WHERE ID % 2 = 0;

--ex2
SELECT COUNT(*) - COUNT(DISTINCT CITY) FROM STATION;

--ex3
SELECT CEIL(AVG(Salary) -  AVG(REPLACE(Salary, '0', ''))) FROM EMPLOYEES;

--ex4
SELECT ROUND((SUM(item_count * order_occurrences) :: numeric)/ SUM(order_occurrences), 1)  AS mean FROM items_per_order;

--ex5
SELECT candidate_id FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(DISTINCT skill) = 3
ORDER BY candidate_id;

--ex6
SELECT user_id,
MAX(DATE(post_date)) - MIN(DATE(post_date)) as days_between
FROM posts
WHERE EXTRACT(YEAR FROM post_date) = 2021
GROUP BY user_id
HAVING COUNT(user_id) >= 2;

--ex7
SELECT card_name, MAX(issued_amount) - MIN(issued_amount) as difference 
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;

--ex8
SELECT manufacturer, COUNT(drug) AS drug_count, SUM(ABS(cogs - total_sales)) AS total_loss
FROM pharmacy_sales
WHERE cogs > total_sales
GROUP BY manufacturer
ORDER BY total_loss DESC;

--ex9
SELECT * FROM Cinema
WHERE id % 2 != 0 AND description != 'boring'
ORDER BY rating DESC;

--ex10
# Write your MySQL query statement below
SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM teacher
GROUP BY teacher_id;

--ex11
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id;

--ex12
SELECT class FROM Courses
GROUP BY class
HAVING COUNT(student) >= 5;
