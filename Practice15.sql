--ex1
SELECT year, product_id, curr_year_spend, prev_year_spend,
ROUND((curr_year_spend - prev_year_spend)* 100.0/ prev_year_spend, 2) AS yoy_rate
FROM
  (SELECT EXTRACT(year FROM transaction_date) AS year,
  product_id, spend AS curr_year_spend,
  LAG(spend) OVER(PARTITION BY product_id ORDER BY EXTRACT(year FROM transaction_date)) AS prev_year_spend
  FROM user_transactions) AS new_table;

--ex2
SELECT card_name, issued_amount
FROM
  (SELECT *, 
  RANK() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS rank
  FROM monthly_cards_issued) AS new_table
WHERE rank = 1
ORDER BY issued_amount DESC;

--ex3
SELECT user_id, spend, transaction_date
FROM
  (SELECT *,
  RANK() OVER(PARTITION BY user_id ORDER BY transaction_date) AS rank
  FROM transactions) AS new_table
WHERE rank = 3;

--ex4
SELECT transaction_date, user_id, purchase_count
FROM
  (SELECT transaction_date, user_id,
  COUNT(*) OVER(PARTITION BY user_id, transaction_date ORDER BY transaction_date DESC) AS purchase_count,
  ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) AS rank
  FROM user_transactions) AS new_table
WHERE rank = 1
ORDER BY transaction_date;

--ex5
--c1
SELECT user_id, tweet_date,
ROUND(AVG(tweet_count) OVER (
  PARTITION BY user_id 
  ORDER BY tweet_date
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg_3d
FROM tweets;

--c2
WITH cte AS(
  SELECT *,
  LAG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date) AS prev1, 
  LAG(tweet_count, 2) OVER (PARTITION BY user_id ORDER BY tweet_date) AS prev2
  FROM tweets
)

SELECT user_id, tweet_date,
CASE
  WHEN prev2 IS NULL AND prev1 IS NULL THEN ROUND(tweet_count*1.0, 2)
  WHEN prev2 IS NULL THEN ROUND((tweet_count + prev1) * 1.0 / 2, 2)
  ELSE ROUND((tweet_count + prev1 + prev2)*1.0 / 3, 2)
END AS rolling_avg_3d
FROM cte;

--ex6
SELECT COUNT(*) AS payment_count FROM
  (SELECT *,
  LEAD(transaction_timestamp) OVER (PARTITION BY merchant_id, credit_card_id, amount) AS time_for_next_payment,
  LEAD(transaction_timestamp) OVER (PARTITION BY merchant_id, credit_card_id, amount) - transaction_timestamp AS time_change
  FROM transactions) AS new_table
WHERE EXTRACT(EPOCH FROM time_change) <= 600;

--ex7
SELECT category, product, total_spend FROM
  (SELECT category, product, SUM(spend) AS total_spend,
  RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) rank FROM product_spend
  WHERE EXTRACT(year FROM transaction_date) = 2022
  GROUP BY category, product) AS new_table
WHERE rank <= 2;

--ex8
SELECT artist_name, artist_rank
FROM(
  SELECT artist_name, 
  DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS artist_rank
  FROM artists AS a  
  JOIN songs AS b ON a.artist_id = b.artist_id
  JOIN global_song_rank AS c ON b.song_id = c.song_id
  WHERE c.rank <= 10
  GROUP BY a.artist_name
) AS new1
WHERE artist_rank <= 5;
