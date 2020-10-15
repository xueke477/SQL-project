/*This answers Problem 1 on Page 1 of the presentation.*/ 
/*Generate a table that only contains customer_id and customer_countries 
information, to improve performace speed.*/
WITH customer_address AS
(
SELECT cu.customer_id,
	co.country AS customer_countries
FROM customer AS cu
JOIN address AS ad
ON cu.address_id = ad.address_id
JOIN city AS ci
ON ad.city_id = ci.city_id
JOIN country AS co
ON ci.country_id = co.country_id
),
/*Find the top 10 countries in DVD rental expenditure.*/ 
top_10_countries AS
(
SELECT c.customer_countries,
	SUM(p.amount) AS total_amount
FROM customer_address AS c
JOIN rental AS r
ON c.customer_id = r.customer_id
JOIN payment AS p
ON r.rental_id = p.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
)
/*Display the top 10 countries and their respective expenditures, and the 
total expenditure of all the other countries.*/
SELECT *
FROM top_10_countries
UNION
SELECT 'Other Countries',
	(SELECT SUM(amount) FROM payment) - (SELECT SUM(t.total_amount) FROM top_10_countries AS t)
