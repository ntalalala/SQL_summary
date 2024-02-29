--ex1
SELECT 
SUM(
  CASE 
    WHEN device_type = 'laptop' THEN 1
    ELSE 0
  END
  ) AS laptop_views,
SUM(
  CASE
    WHEN device_type != 'laptop' THEN 1
    ELSE 0
  END
  ) AS mobile_views
FROM viewership;

--ex2
SELECT x, y, z, 
CASE
    WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
    ELSE 'No'
END triangle
FROM Triangle;

--ex3
SELECT
  ROUND(
    COUNT(
      CASE
        WHEN call_category IS NULL OR call_category = 'n/a' THEN 1
        ELSE 0
      END) * 100.0 / COUNT(case_id), 1) AS call_percentage
FROM callers;

--ex4
SELECT name FROM Customer
WHERE referee_id != 2 or referee_id IS NULL;

--ex5
SELECT survived,
    SUM(
        CASE
            WHEN pclass = 1 THEN 1
            ELSE 0
        END 
        ) AS first_class,
    SUM(
        CASE
            WHEN pclass = 2 THEN 1
            ELSE 0
        END 
        ) AS second_class,
    SUM(
        CASE
            WHEN pclass = 3 THEN 1
            ELSE 0
        END 
        ) AS third_class
    FROM titanic
    GROUP BY survived;
