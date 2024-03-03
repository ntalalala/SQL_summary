--ex1
SELECT COUNTRY.CONTINENT, FLOOR(AVG(CITY.POPULATION))
FROM CITY 
JOIN COUNTRY 
ON CITY.COUNTRYCODE = COUNTRY.CODE
GROUP BY COUNTRY.CONTINENT;

--ex2
SELECT 
ROUND(AVG(
  CASE 
    WHEN texts.signup_action = 'Confirmed' THEN 1
    ELSE 0
  END), 2)
FROM texts
LEFT JOIN emails
ON texts.email_id = emails.email_id;

--ex3
SELECT age_breakdown.age_bucket,
ROUND(
  SUM(CASE WHEN activities.activity_type = 'send' THEN activities.time_spent ELSE 0 END) * 100.0/
  SUM(activities.time_spent), 2
) AS send_perc,
ROUND(
  SUM(CASE WHEN activities.activity_type = 'open' THEN activities.time_spent ELSE 0 END) * 100.0/
  SUM(activities.time_spent), 2
) AS open_perc
FROM activities
JOIN age_breakdown
ON activities.user_id = age_breakdown.user_id
WHERE activities.activity_type IN ('send', 'open') 
GROUP BY age_breakdown.age_bucket;

--ex4
SELECT a.customer_id
FROM customer_contracts AS a   
JOIN products AS b  
ON a.product_id = b.product_id
GROUP BY a.customer_id
HAVING COUNT(DISTINCT b.product_category) = (SELECT COUNT(DISTINCT product_category) FROM products);

--ex5
SELECT b.employee_id, b.name, COUNT(*) AS reports_count, ROUND(AVG(a.age)) AS average_age
FROM Employees AS a
JOIN Employees AS b
ON a.reports_to = b.employee_id
GROUP BY a.reports_to
ORDER BY b.employee_id;

--ex6
SELECT Products.product_name, SUM(Orders.unit) AS unit FROM Products
JOIN Orders 
ON Orders.product_id = Products.product_id 
WHERE EXTRACT(month FROM order_date) = 2 AND  EXTRACT(year FROM order_date) = 2020
GROUP BY Orders.product_id
HAVING SUM(Orders.unit) >= 100;

--ex7
SELECT a.page_id
FROM pages AS a
LEFT JOIN page_likes AS b
ON a.page_id = b.page_id
WHERE b.liked_date IS NULL
GROUP BY a.page_id
ORDER BY a.page_id;


--mid-course test
--ques1
SELECT DISTINCT replacement_cost FROM film
ORDER BY replacement_cost;

--ques2
SELECT 
	CASE
		WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
		WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
		WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
	END xep_loai,
	COUNT(*) so_luong
FROM film
GROUP BY 
	CASE
		WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
		WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
		WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
	END;
	
--ques3
SELECT a.title, a.length, c.name
FROM film a
JOIN film_category b
ON a.film_id = b.film_id
JOIN category c
ON c.category_id = b.category_id
WHERE c.name = 'Drama' OR c.name = 'Sports'
ORDER BY a.length DESC;

--ques4
SELECT c.name, COUNT(a.title) || ' titles' so_luong
FROM film a
JOIN film_category b
ON a.film_id = b.film_id
JOIN category c
ON c.category_id = b.category_id
GROUP BY c.name
ORDER BY so_luong DESC;

--ques5
SELECT a.first_name, a.last_name, COUNT(film_id) || ' movies' AS so_luong_phim
FROM actor a
JOIN film_actor b
ON a.actor_id = b.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY so_luong_phim DESC;

--ques6
SELECT COUNT(*) FROM address a
LEFT JOIN customer AS b
ON a.address_id = b.address_id
WHERE customer_id IS NULL;

--ques7
SELECT d.city, SUM(a.amount) AS sales_revenue
FROM payment a
JOIN customer b
ON a.customer_id = b.customer_id
JOIN address c
ON b.address_id = c.address_id
JOIN city d
ON c.city_id = d.city_id
GROUP BY d.city
ORDER BY sales_revenue DESC;

--ques8
SELECT d.city || ', ' || e.country AS city_and_country,
SUM(a.amount) AS sales_revenue
FROM payment a
JOIN customer b
ON a.customer_id = b.customer_id
JOIN address c
ON b.address_id = c.address_id
JOIN city d
ON c.city_id = d.city_id
JOIN country e
ON d.country_id = e.country_id
GROUP BY d.city || ', ' || e.country
ORDER BY sales_revenue;



