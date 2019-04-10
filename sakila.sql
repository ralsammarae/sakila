/* Greater understanding of family watching behavior */

SELECT f.title film_title, c.name category_name, COUNT(rental_id) rental_count
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music'
GROUP BY 1, 2
ORDER BY 2, 1;


/* Family friendly movie rental durations expressed in percentiles */

SELECT f.title film_title, c.name category_name, f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music';


/* Count of movies given the combination of film category and corresponding rental duration category */

WITH t1 AS (
            SELECT c.name category_name, NTILE(4) OVER (ORDER BY f.rental_duration) standard_quartile
            FROM film f
            JOIN film_category fc
            ON f.film_id = fc.film_id
            JOIN category c
            ON c.category_id = fc.category_id
            WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music')

SELECT category_name, standard_quartile, COUNT(*)
FROM t1
GROUP BY 1, 2
ORDER BY 1, 2;


/* Comparison of stores with regards to rental orders each month */

SELECT DATE_PART('month', r.rental_date) rental_month, DATE_PART('year', r.rental_date) rental_year, s.store_id, COUNT(r.rental_id) count_rentals
FROM rental r
JOIN staff s
ON r.staff_id = s.store_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;


/* Top 10 paying customers, pay count and pay amount per month */

WITH t1 AS (
            SELECT p.customer_id, c.first_name || ' ' || c.last_name full_name, SUM(amount) pay_total
            FROM payment p
            JOIN customer c
            ON p.customer_id = c.customer_id
            GROUP BY 1, 2
            ORDER BY 3 DESC
            LIMIT 10)

SELECT DATE_TRUNC('month', payment_date) pay_month, t1.full_name, COUNT(*) pay_count, SUM(p.amount) pay_amount
FROM t1
JOIN payment p
ON t1.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 2, 1;
