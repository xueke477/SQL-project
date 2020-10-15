/*This answers Problem 3 on Page 3 of the presentation.*/ 
/*Find the top 10 paying customers.*/
WITH top_10 AS
(
SELECT c.customer_id,
	CONCAT(first_name, ' ', last_name) AS full_name,
	SUM(p.amount) AS total_payment	
FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10
),
/*Generate a table that categorizes each payment of the top 10 paying customers
into one of the four months from Feb to May.*/
top_10_by_month AS
(
SELECT t.full_name AS full_name,
	CASE DATE_PART('month', p.payment_date) 
		WHEN '2' THEN p.amount
		ELSE 0 END AS Feb,
	CASE DATE_PART('month', p.payment_date) 
		WHEN '3' THEN p.amount
		ELSE 0 END AS Mar,
	CASE DATE_PART('month', p.payment_date) 
		WHEN '4' THEN p.amount
		ELSE 0 END AS Apr,	
	CASE DATE_PART('month', p.payment_date) 
		WHEN '5' THEN p.amount
		ELSE 0 END AS May,
	t.total_payment
FROM top_10 AS t
JOIN payment AS p
ON t.customer_id = p.customer_id
)
/*Compute the total monthly payments for each one of the top 10 paying
customers and order by the total payment of 2007.*/
SELECT full_name,
	SUM(Feb) AS Feb_total,
	SUM(Mar) AS Mar_total,
	SUM(Apr) AS Apr_total,
	SUM(May) AS May_total,
	total_payment
FROM top_10_by_month AS t
GROUP BY 1, 6
ORDER BY 6 DESC
