-- practice of operators, filtration, sort and limits
	-- #1
		USE shop;
		SHOW TABLES;
		DESC users;
		SELECT * FROM users;
		-- cleat date fields
		UPDATE users SET created_at = NULL;
		UPDATE users SET updated_at = NULL;
		-- fill date fields (limit is optional here, it is reasonable whe we add date columns after having some data in users)
		UPDATE users SET created_at = NOW() LIMIT 6;
		UPDATE users SET created_at = NOW() LIMIT 6;
	
	
	-- #2
		USE shop;
		SHOW TABLES;
		DESC users;
		SELECT * FROM users;
		-- lead columns with date to dd-mm-yyyy hh:mm format
		ALTER TABLE users MODIFY created_at VARCHAR(25);
		ALTER TABLE users MODIFY updated_at VARCHAR(25);
		UPDATE users SET created_at = DATE_FORMAT(created_at,'%d-%m-%Y %h:%i');
		UPDATE users SET updated_at = DATE_FORMAT(updated_at,'%d-%m-%Y %h:%i');
		SELECT created_at, updated_at FROM users;
		
		-- adding seconds to the saved date and time
		UPDATE users SET created_at = CONCAT(created_at,':00');
		UPDATE users SET updated_at = CONCAT(updated_at,':00');
		
		-- changing field value to the correct date and time format and modifying columns
		UPDATE users SET created_at = STR_TO_DATE(created_at,'%d-%m-%Y %h:%i:%s');
		UPDATE users SET updated_at = STR_TO_DATE(updated_at,'%d-%m-%Y %h:%i:%s');
		ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
		ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP;
		-- check the result
		SELECT created_at, updated_at FROM users;
	
	-- #3
		USE shop;
		-- check info about tables
		DESC storehouses_products ;
		DESC storehouses;
		-- fill storehouses with values
		INSERT INTO storehouses(name) 
		VALUES ('moscow'), ('ufa'), ('novosibirsk'), ('yakutsk'), ('vladivostok');
		-- refrshing the storehouses_products table with complete data 
		TRUNCATE storehouses_products;
		INSERT INTO storehouses_products(storehouse_id,product_id,value) 
		VALUES
			(1,1,741),(1,2,103),(1,3,0),(1,4,436),(1,5,0),(1,6,29),(1,7,25),(2,1,156),(2,2,0),(2,3,252),(2,4,0),(2,5,189),(2,6,359),(2,7,0),(3,1,489),(3,2,679),(3,3,123),(3,4,0),(3,5,230),(3,6,724),
			(3,7,418),(4,1,0),(4,2,60),(4,3,564),(4,4,0),(4,5,284),(4,6,0),(4,7,373),(5,1,379),(5,2,539),(5,3,0),(5,4,466),(5,5,0),(5,6,166),(5,7,159);
		-- create the querry to get list of products in a paticular storehouse
		SELECT * FROM storehouses_products WHERE storehouse_id = 1 ORDER BY value = 0, value;
	-- #4
		USE shop;
		-- add some data and the new column
		INSERT INTO users (name, birthday_at)
		VALUES
			('Евгений','1981-08-11'),('Анна','1995-03-09'),('Павел','1999-10-21'),('Инна','2010-02-11'),('Пюрешечка','1977-05-30'),('Оливье','1990-01-08'),
			('Шампанское', '2002-08-01'),('Тимофей', '1981-05-05'),('С','2020-05-31'),('Новым','2020-12-31'),('Годом!','2021-01-01');
		ALTER TABLE users ADD COLUMN month_of_birth VARCHAR(10);
		-- self check
		DESC users;
		SELECT *FROM users;
		-- fill column of months
		UPDATE users SET month_of_birth = DATE_FORMAT(birthday_at, '%M');	
		-- select users with birthdays in May or August
		SELECT * FROM users u2 WHERE month_of_birth = 'August' OR month_of_birth = 'May';
	-- #5
		USE shop;
		-- I'm not sure this is the best way, but looks quite good
		SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5,1,2);
