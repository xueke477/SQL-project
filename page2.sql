/*This answers Problem 2 on Page 2 of the presentation.*/
/*Filter for rentals in 2005 and flag them as past due or not.*/
WITH flag_past_due_rentals AS
(
SELECT f.film_id, 
	r.rental_id,
	f.length,
	CASE WHEN (EXTRACT(day from (r.return_date-r.rental_date)) > f.rental_duration) THEN 1
	ELSE 0 END AS flag
FROM film AS f 
JOIN inventory AS i 
ON f.film_id = i.film_id 
JOIN rental AS r 
ON i.inventory_id = r.inventory_id
WHERE DATE_PART('year', r.rental_date) = '2005'
)
/*Generate a table that shows the length and the percentage of past due 
rentals for each movie.*/
SELECT film_id,
	length,
	(SUM(flag)::decimal)/(COUNT(rental_id)::decimal) AS past_due_percentage
FROM flag_past_due_rentals
GROUP BY 1, 2
