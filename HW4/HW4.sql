-- Query 1: Average length of films in each category

SELECT c.name AS category_name, AVG(f.length) AS average_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name;


-- Query 2: Categories with the longest and shortest average film lengths

SELECT c.name AS category_name, AVG(f.length) AS average_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY average_length DESC
LIMIT 1;

SELECT c.name AS category_name, AVG(f.length) AS average_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY average_length ASC
LIMIT 1;


-- Query 3: Customers who rented action but not comedy or classic movies

SELECT DISTINCT cu.customer_id, cu.first_name, cu.last_name
FROM customer cu
JOIN rental r ON cu.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action' 
AND cu.customer_id NOT IN (
    SELECT cu2.customer_id
    FROM customer cu2
    JOIN rental r2 ON cu2.customer_id = r2.customer_id
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
    JOIN film_category fc2 ON i2.film_id = fc2.film_id
    JOIN category c2 ON fc2.category_id = c2.category_id
    WHERE c2.name IN ('Comedy', 'Classics')
);


-- Query 4: Actor with the most appearances in English-language movies

SELECT a.actor_id, a.first_name, a.last_name, COUNT(*) AS appearances
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN language l ON f.language_id = l.language_id
WHERE l.name = 'English'
GROUP BY a.actor_id
ORDER BY appearances DESC
LIMIT 1;


-- Query 5: Number of distinct movies rented for exactly 10 days from the store where Mike works

SELECT COUNT(DISTINCT i.film_id) AS distinct_movies
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN staff st ON s.store_id = st.store_id
WHERE st.first_name = 'Mike'
AND DATEDIFF(r.return_date, r.rental_date) = 10;


-- Query 6: Alphabetically list actors who appeared in the movie with the largest cast of actors

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
    SELECT fa2.film_id
    FROM film_actor fa2
    GROUP BY fa2.film_id
    ORDER BY COUNT(fa2.actor_id) DESC
    LIMIT 1
)
ORDER BY a.last_name, a.first_name;
