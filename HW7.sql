USE shop;
SHOW TABLES;
DESC orders;
DESC users;
-- #1 too easy after previous homework
SELECT name, birthday_at FROM users WHERE id IN (SELECT user_id FROM orders);

-- #2 not very, but rather fast. Thanks to previous homework)
DESC catalogs;
DESC products;
SELECT * FROM catalogs;
SELECT * FROM products;
SELECT p.name, c.name FROM products p RIGHT JOIN catalogs c ON p.catalog_id = c.id;

-- #3
CREATE TABLE flights(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	departure VARCHAR(50) NOT NULL,
	arrival VARCHAR(50) NOT NULL
);
CREATE TABLE cities (
	label VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL
);

INSERT INTO flights(departure,arrival) VALUES ('moscow','omsk'),('novgorod','kazan'),('irkutsk','moscow'),('omsk','irkutsk'),('moscow','kazan');
INSERT INTO cities(label, name) VALUES ('moscow','москва'),('kazan','казань'),('novgorod','новгород'),('irkutsk','иркутск'),('omsk','омск');

SELECT * FROM flights;
SELECT 
	flights.id, 
	(SELECT name from cities WHERE label = flights.departure) AS откуда,
	(SELECT name from cities WHERE label = flights.arrival) AS куда
FROM flights




