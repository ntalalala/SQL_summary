--ex1
SELECT Name FROM STUDENTS
WHERE Marks > 75
ORDER BY RIGHT(Name, 3), ID;

--ex2
SELECT user_id, 
CONCAT(UPPER(LEFT(name, 1)), LOWER(RIGHT(name, LENGTH(name) - 1))) AS name FROM Users
ORDER BY user_id;

--ex3
SELECT manufacturer,
CONCAT('$', ROUND(SUM(total_sales)/1000000), ' million') AS sales_mil 
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer;

--ex4
SELECT EXTRACT(month FROM submit_date) AS mth,
product_id AS product,
ROUND(AVG(stars), 2) AS avg_stars FROM reviews
GROUP BY EXTRACT(month FROM submit_date), product_id
ORDER BY mth, product_id;

--ex5
SELECT sender_id, COUNT(*) AS message_count
FROM messages
WHERE sent_date BETWEEN '08/01/2022' and '09/01/2022'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;

--ex6
SELECT tweet_id FROM Tweets
WHERE LENGTH(content) > 15;

--ex7
SELECT activity_date AS day, 
COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
GROUP BY activity_date;

--ex8
SELECT COUNT(*) FROM employees
WHERE joining_date BETWEEN '2022-01-01' AND '2022-07-31';

--ex9
SELECT POSITION('a' IN first_name) FROM worker
WHERE first_name = 'Amitah';

--ex10
SELECT title, SUBSTRING(title, POSITION('2' IN title), 4)
FROM winemag_p2
WHERE country = 'Macedonia';
