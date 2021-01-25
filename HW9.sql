-- 9-1 #1
-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. 
-- Используйте транзакции.

-- check if smample DB exists
SHOW DATABASES;
-- unfortunately I haven't this DB, so I'll create it;
USE shop;
DESC users;
SELECT * FROM sample.users LIMIT 5;
CREATE DATABASE sample;
USE sample;
-- To recycle this code
DROP TABLE IF EXISTS sample.users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
); -- creating table users same as in shop DB

-- Fill table with any name and birthday from shop.users
SELECT @name:=name, @birth:=birthday_at FROM shop.users u WHERE u.id = 15; -- trying sesion variables implementation
INSERT INTO sample.users (name, birthday_at) VALUES (@name, @birth);

-- using transaction to replace first row of sample.users with first row of shop.users
START TRANSACTION;
	SELECT @name:=name, @birth:=birthday_at, @cr_at:=created_at, @upd_at:=updated_at 
	FROM shop.users u 
	WHERE u.id = 2;
	UPDATE sample.users
		SET name = @name,
			birthday_at = @birth,
			created_at = @cr_at,
			updated_at = @upd_at
		WHERE id = 1;
	-- In case when sample is empty can use INSERT operation below. I'm not sure if sample.users empty by default
	-- INSERT INTO sample.users (name, birthday_at, created_at, updated_at) VALUES (@name, @birth, @cr_at, @upd_at);
COMMIT;

-- check if update were applied
SELECT * FROM sample.users WHERE id = 1;


-- 9-1 #2
-- Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

USE shop;
DESC catalogs;
DESC products;
SELECT * FROM products p LIMIT 10;
SELECT * FROM catalogs c;

-- creating view of products
CREATE OR REPLACE VIEW product_catalog AS 
SELECT 
  c.name AS category, p.name AS name, description 
FROM 
  products p 
LEFT JOIN 
  catalogs c
ON p.catalog_id = c.id
ORDER BY FIELD (c.id, NULL) DESC; -- removing DESC here can help to find non cataloged items. They will be in first rows of querry result

-- check if view works
SELECT * FROM product_catalog;

-- insert row with unnamed catalog_id
INSERT  INTO products (name, description, price) 
	 	VALUES ('GeForce GTX 1660 SUPER STORMX', 'Видеокарта Palit GeForce GTX 1660 SUPER STORMX [NE6166S018J9-161F]',30000);
-- It's intersting to apply view to non-existing category
SELECT * FROM product_catalog;

-- 9-1 #3
-- (по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.)


SELECT * FROM orders LIMIT 10;
DROP TABLE dates;
CREATE TABLE IF NOT EXISTS dates(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	order_date DATE
); -- creating table for the #3 task

-- fill table with dates from the task and some additional
INSERT INTO dates (order_date) VALUES ('2018-08-01'),('2016-08-04'),('2018-08-16'),('2018-08-17');

DROP TABLE august_dates;
CREATE TABLE IF NOT EXISTS august_dates(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	aug_date DATE
); -- creating table with august dates for the #3 task

-- Filling with august dates	
INSERT INTO august_dates (aug_date) 
	SELECT * FROM
    (SELECT ADDDATE('2020-07-31',t0 + t1*10) AS gen_date FROM
    (SELECT 0 t0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
    (SELECT 0 t1 UNION SELECT 1 uNION SELECT 2 UNION SELECT 3) t1) v
	WHERE gen_date BETWEEN '2020-08-01' AND '2020-08-31';
-- unfortunately I can't do it in VIEW without intermediate table=((

-- creating a view to solve #3 task
CREATE OR REPLACE VIEW check_august 
  	(dates, is_in_dates)
AS SELECT
	DATE_FORMAT(ad.aug_date, '%m-%d'), (CASE WHEN DATE_FORMAT(ad.aug_date, '%m-%d') = DATE_FORMAT(d.order_date, '%m-%d') THEN 1 ELSE 0 END) 
FROM 
  	august_dates AS ad
LEFT JOIN
	dates AS d
ON
	DATE_FORMAT(ad.aug_date, '%m-%d') = DATE_FORMAT(d.order_date, '%m-%d')
ORDER BY 
	DATE_FORMAT(ad.aug_date, '%m-%d');																		

-- check if it works correct
SELECT * FROM check_august;

-- 9-1 #4
-- (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, 
-- оставляя только 5 самых свежих записей.

DROP TABLE demo_dates;
CREATE TABLE IF NOT EXISTS demo_dates(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	order_date DATETIME,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP	
); -- creating table for the #4 task

-- fill table with dates from the task and some additional
INSERT INTO demo_dates (order_date) VALUES ('2018-08-11'),('2016-08-04'),('2018-08-16');
INSERT INTO demo_dates (order_date) VALUES ('2018-08-21'),('2016-08-03'),('2018-08-17');
INSERT INTO demo_dates (order_date) VALUES ('2018-12-01'),('2016-02-02');
INSERT INTO demo_dates (order_date) VALUES ('2018-06-01'),('2016-07-02'),('2018-08-18');

SELECT * FROM demo_dates;

-- WITH cte AS
-- 	(SELECT created_at, ROW_NUMBER () OVER(ORDER BY created_at DESC) AS rn 
-- 	FROM demo_dates
-- 	ORDER BY created_at)
-- DELETE FROM cte WHERE rn > 5; 
-- it is working as temporary viewing, but not for deleting/

SELECT created_at
FROM demo_dates
WHERE created_at IN 
	(SELECT created_at FROM 
		(SELECT created_at FROM demo_dates ORDER BY created_at DESC LIMIT 5) a 
	);-- I've found double nesting in internet, but I'm not sure if I completely understand why it should be working
	
-- Now I should just remove all the others rows in the same double nesting
DELETE FROM 
	demo_dates 
	WHERE created_at NOT IN 
		(SELECT created_at FROM 
			(SELECT created_at FROM demo_dates ORDER BY created_at DESC LIMIT 5) a 
		);

-- 9-2 #1
-- Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

USE shop;

-- creating two users and give them passwords
CREATE USER shop_read IDENTIFIED WITH sha256_password BY 'pass1';
CREATE USER shop IDENTIFIED WITH sha256_password BY 'pass2';

-- granting read-only option for user shop_read
GRANT SELECT ON *.* TO shop_read; 
-- task is ambiguous about shop_read, if this user should be able read from any table, so put 'shop.*' instead of '*.*'

-- granting all rights for user shop for shop DB
GRANT ALL ON shop.* TO shop;
GRANT GRANT OPTION ON shop.* TO shop;

-- 9-2 #1
-- (по желанию) Пусть имеется таблица accounts содержащая три столбца 
-- id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, 
-- однако, мог бы извлекать записи из представления username.

-- creating DB for the task
CREATE DATABASE home_work_9;
USE home_work_9;

-- creating table accounts according to the task
CREATE TABLE accounts (
	id TINYINT UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(40) NOT NULL UNIQUE,
	user_password VARCHAR(40)
);

-- filling table with some rows
INSERT INTO accounts (name, user_password)VALUES
('user1','pass1'),
('user2','pass2'),
('user3','pass3'),
('user4','pass4'),
('user5','pass5');

-- check if table filled
SELECT * FROM accounts a ;

-- creating a view to get accounts(id,name) content
CREATE OR REPLACE VIEW username (id, name) AS
SELECT id, name FROM accounts;

-- check if the view operates correctly
SELECT * FROM username;

-- creating the user with an access to the view only
CREATE USER foo IDENTIFIED WITH sha256_password BY 'pass';
GRANT SELECT ON home_work_9.username TO foo;

-- trying to run "select id, name FROM accounts" by user foo leads to a message:
-- ERROR 1142 (42000): SELECT command denied to user 'foo'@'localhost' for table 'accounts'

-- whereas "SELECT * FROM username" query by user foo gives:
-- +----+-------+
-- | id | name  |
-- +----+-------+
-- |  1 | user1 |
-- |  2 | user2 |
-- |  3 | user3 |
-- |  4 | user4 |
-- |  5 | user5 |
-- +----+-------+
-- 5 rows in set (0.00 sec)

-- 9-3 #1
-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

-- many times it has been run before I found my last mistake here
DROP FUNCTION IF EXISTS hello;

-- create function with case structure
-- (checked the result with adding argument into function)
CREATE FUNCTION hello ()
RETURNS varchar(255) DETERMINISTIC
BEGIN
	DECLARE greetings VARCHAR(25) DEFAULT 'Hello';
	CASE 
		WHEN CURRENT_TIME BETWEEN "00:00:00" AND "06:00:00"
			THEN SET greetings = 'Доброй ночи';
		WHEN CURRENT_TIME BETWEEN "06:00:00" AND "12:00:00"
			THEN SET greetings = 'Доброе утро';
		WHEN CURRENT_TIME BETWEEN "12:00:00" AND "18:00:00"
			THEN SET greetings = 'Добрый день';
		WHEN CURRENT_TIME BETWEEN "18:00:00" AND "24:00:00"
			THEN SET greetings = 'Добрый вечер';
	END CASE;
	RETURN greetings;
END

-- call function
SELECT hello();
-- it sends me to go to sleep, but I'll fight to the last task! =)

-- 9-3 #2
-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

USE shop;
DESC products;

-- creating the trigger with conditions of task
DROP TRIGGER IF EXISTS product_decription;
CREATE TRIGGER product_decription BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	CASE 
		WHEN NEW.name IS NULL AND NEW.description IS NULL						-- main case for this trigger
			THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
		WHEN NEW.name IS NOT NULL AND NEW.description IS NULL 					-- additional case to make some fun
			THEN SET NEW.description = NEW.name;
		ELSE 
			SET NEW.name = NEW.name; 											-- not sure this is correct way to do this
			SET NEW.description = NEW.description; 								-- same doubts as above
	END CASE;
END

;
-- check if every conase operates correctly
-- first case
INSERT INTO products (name, description) 
VALUES (NULL,NULL);

-- second case
INSERT INTO products (name, description) 
VALUES ('Philips 203V5LSB26',NULL);

-- else case
INSERT INTO products (name, description) 
VALUES ('AOC e970Swn/01','Монитор AOC e970Swn/01 с диагональю 18.5');

-- check the result table
SELECT * FROM products p;

-- Sorry, I'can't think anymore today, so last task is only in this way
-- unfortunately recursion is nat allowed =(((((

-- This works correct, but it is probably not the most sharp and beautiful solution
DROP FUNCTION IF EXISTS fibonacci;
CREATE FUNCTION fibonacci(num INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE i INT DEFAULT 1;
	DECLARE j INT DEFAULT 1;
	DECLARE k INT DEFAULT 0;
	CASE
		WHEN num = 0
			THEN RETURN num;
		WHEN num < 0
			THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Repeat with non negative number, please!';
		WHEN num = 1 OR num = 2
			THEN RETURN 1;
		ELSE
			cycle:LOOP
				SET k = j;
				SET j = i+j;
				SET i = k;
				SET num = num-1;
				IF num <3 THEN LEAVE cycle;
				END IF;
			END LOOP cycle;
			RETURN j;
	END CASE;
END

SELECT fibonacci(9);





	
	
	