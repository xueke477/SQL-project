/*This answers Problem 4 on Page 4 of the presentation.*/ 
/*Find the top n paying customers where n=5.*/
WITH top_n AS
(
SELECT c.customer_id,
	CONCAT(first_name, ' ', last_name) AS full_name,
	SUM(p.amount) AS total_payment	
FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC
/*Limit to the top n paying customers. n can be customized.*/
LIMIT 5
),
/*Generate a table that categorizes each payment of the top n paying customers
by the month of the payment, and then compute the payment count and total 
payment of each month.*/
top_n_by_month AS
(
SELECT t.full_name AS full_name,
	DATE_PART('month', p.payment_date) AS month,
	COUNT(p.*) AS payment_count_by_month,
	SUM(p.amount) AS payment_amount_by_month
FROM top_n AS t
JOIN payment AS p
ON t.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 1, 2
),
/*Generate the Cartesian product of the set of the top n payings customers and
the set of months in which any payment is made.*/
name_month AS
(
SELECT sub1.full_name,
	sub2.month
FROM (
	SELECT full_name 
	FROM top_n
     ) sub1,
     (
	SELECT DISTINCT DATE_PART('month', payment_date) AS month
	FROM payment
     ) sub2
ORDER BY 1, 2
),
/*Data cleansing. Fill the NULL values by 0.*/
filled_in AS
(
SELECT sub.full_name AS full_name,
	sub.month AS month,
	COALESCE(sub.payment_count_by_month, 0) AS payment_count_by_month,
	COALESCE(sub.payment_amount_by_month, 0) AS payment_amount_by_month
FROM (  /*Make sure the same set of months are involved for each customer. If a
	customer didn't make a payment in a certain month, set the values of 
	payment_count_by_month and payment_amount_by_month as NULL.*/
	SELECT n.full_name,
	       n.month,
	       t.payment_count_by_month,
               t.payment_amount_by_month
	FROM name_month AS n
	LEFT JOIN top_n_by_month AS t
	ON (n.full_name = t.full_name AND n.month = t.month)
     ) sub
),
/*Use the window function LEAD to compute the change of payments across
successive months for each customer.*/
monthly_increase AS
(
SELECT full_name,
	(month + 1) AS new_month,
	(LEAD(payment_amount_by_month, 1) OVER (PARTITION BY full_name ORDER BY month))-payment_amount_by_month AS payment_increase_at_new_month
FROM filled_in
ORDER BY 1, 2
)
/*"Transpose" the output table of monthly_increase so that the new output
can be used to make a chart without additional data prep (required by 
"Additional Guidelines").*/
SELECT full_name,
	SUM(Feb_to_Mar) AS Feb_to_Mar,
	SUM(Mar_to_Apr) AS Mar_to_Apr,
	SUM(Apr_to_May) AS Apr_to_May
FROM (
      SELECT full_name,
	     CASE new_month
		WHEN 3 THEN payment_increase_at_new_month
		ELSE 0 END AS Feb_to_Mar,
	     CASE new_month
		WHEN 4 THEN payment_increase_at_new_month
		ELSE 0 END AS Mar_to_Apr,
	     CASE new_month
		WHEN 5 THEN payment_increase_at_new_month
		ELSE 0 END AS Apr_to_May
      FROM monthly_increase
     ) AS sub
GROUP BY 1
ORDER BY 1
