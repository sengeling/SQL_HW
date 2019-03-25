-- activate the sakila db
USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT_WS(' ', UPPER(first_name), UPPER(last_name)) AS 'Actor Name' 
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name LIKE 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`.
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries:
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table `actor` named `description` and use the data type `BLOB`
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;
-- Test that result shows.
SELECT * FROM actor LIMIT 10;

-- 3b. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;
-- Test that result shows.
SELECT * FROM actor LIMIT 10;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS 'Name Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(DISTINCT first_name) AS '#_of_unique_first_names'
FROM actor
GROUP BY last_name
HAVING COUNT(DISTINCT first_name) >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
-- Write a query to fix the record.
-- Find the actor_id for 'GROUCHO WILLIAMS'
SELECT * FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- Update the first_name to 'HARPO'
UPDATE actor 
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- 4d. In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
-- Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address, address.address2
FROM staff
LEFT JOIN address ON staff.address_id=address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total Amount'
FROM staff
INNER JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(DISTINCT film_actor.actor_id) AS '# of Actors'
FROM film
INNER JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.inventory_id) AS '# of Copies'
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Amount'
FROM customer
INNER JOIN payment ON customer.customer_id=payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN
	(SELECT language_id
	FROM language
	WHERE name = 'English');
    
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id
	FROM film_actor
	WHERE film_id IN
		(SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
		)
	);

-- 7c. Use joins to retrieve the names and email addresses of all Canadian customers.
SELECT cus.first_name, cus.last_name, cus.email
FROM customer AS cus
INNER JOIN address AS a ON cus.address_id = a.address_id 
INNER JOIN city AS c ON a.city_id = c.city_id 
INNER JOIN country AS cty ON c.country_id = cty.country_id
WHERE cty.country = 'Canada';

-- 7d. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
	(SELECT film_id
	FROM film_category
	WHERE category_id IN
		(SELECT category_id
		FROM category
		WHERE name = 'Family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.title) AS '# rented'
FROM film AS f
INNER JOIN inventory AS i ON f.film_id = i.film_id 
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(f.title) DESC; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS '$ made by store'
FROM store AS s
INNER JOIN customer AS c ON s.store_id = c.store_id 
INNER JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country
FROM store AS s
INNER JOIN address AS a ON s.address_id = a.address_id
INNER JOIN city AS ci ON a.city_id = ci.city_id 
INNER JOIN country AS co ON ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS '$ by genre'
FROM category AS c
INNER JOIN film_category AS fc ON c.category_id = fc.category_id 
INNER JOIN film AS f ON fc.film_id = f.film_id
INNER JOIN inventory AS i ON f.film_id = i.film_id
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres AS
	(SELECT c.name, SUM(p.amount) AS '$ by genre'
	FROM category AS c
	INNER JOIN film_category AS fc ON c.category_id = fc.category_id 
	INNER JOIN film AS f ON fc.film_id = f.film_id
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
	INNER JOIN payment AS p ON r.rental_id = p.rental_id
	GROUP BY c.name
	ORDER BY SUM(p.amount) DESC
	LIMIT 5
    );

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
