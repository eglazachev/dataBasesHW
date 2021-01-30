-- #11-1
-- Создайте таблицу logs типа Archive. 
-- Пусть при каждом создании записи в таблицах users, catalogs и products 
-- в таблицу logs помещается 
-- время и дата создания записи, 
-- название таблицы, 
-- идентификатор первичного ключа 
-- содержимое поля name.

USE shop;
SHOW TABLES;
DESC users;
DESC catalogs;
DESC products;

-- creating of logs table
CREATE TABLE IF NOT EXISTS logs (
	table_name VARCHAR(10), 					-- table name of insert operation
	orig_table_prim_key_id BIGINT UNSIGNED, 	-- primary key identifier of inserted object in original table
	inserted_name VARCHAR(255), 				-- the content of field 'name' of inserted data
	insert_time DATETIME 						-- time of isert operation
) ENGINE = Archive; 
SELECT * FROM logs;
DESC products;

-- creating triggers to fill logs table
-- the task doesn't say about the update statements, but the solution would be the same.
CREATE TRIGGER logging_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, orig_table_prim_key_id, inserted_name, insert_time)
	VALUES ('users',NEW.id, NEW.name, NEW.created_at);
END; -- is that good idea to set NEW.name to lower case before sending to logs?

CREATE TRIGGER logging_catalog AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, orig_table_prim_key_id, inserted_name, insert_time)
	VALUES ('catalogs',NEW.id, NEW.name, CURRENT_TIMESTAMP);
END;

CREATE TRIGGER logging_products AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs(table_name, orig_table_prim_key_id, inserted_name, insert_time)
	VALUES ('products',NEW.id, NEW.name, NEW.created_at);
END;

INSERT INTO users(name, birthday_at) VALUES ('Helga', '2001-01-01');
INSERT INTO catalogs (name) VALUES ('Android');
INSERT INTO products (name, description, price, catalog_id)
VALUES (
	'OnePlus 8 Pro', 
	'Высокопроизводительная конфигурация на основе Qualcomm, большой ресурс памяти, оптика топ-уровня, аккумулятор с увеличенным ресурсом, защита девайса и внутренних данных, сбалансированная акустика, NFC - с этим смартфоном владелец получает только лучшее.',
	62500,
	7);

SELECT * FROM logs;

-- #11-2
-- Создайте SQL-запрос, который помещает в таблицу users миллион записей.

SELECT  CONCAT ('me', CHAR( FLOOR(65 + (RAND() * 25))));
SELECT LENGTH('Name') AS LengthOfString;


DROP FUNCTION name_insert;
CREATE FUNCTION name_insert (rows_num BIGINT)
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
	SET @name_length = 5;
	SET @curr_row_num = 0;
	SET @curr_name = '';
	SET @curr_name_length = 0;

	row_cycle: WHILE (@curr_row_num < rows_num ) DO
		SET @curr_name_length = 0;
		cycle : WHILE @curr_name_length < @name_length DO 
			SET @curr_name = CONCAT(@curr_name, CHAR( FLOOR(65 + (RAND() * 25))));
			SET @curr_name_length = LENGTH(@curr_name);
		END WHILE cycle ;
		INSERT INTO aliens (name) VALUES(@curr_name);
		SET @curr_name = '';
		SET @curr_row_num = @curr_row_num + 1;
	END WHILE row_cycle ;
	RETURN 'Well done!';
END

DROP TABLE aliens;
CREATE TABLE IF NOT EXISTS aliens (
	name VARCHAR(10),
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
);

-- creating of logs table for aliens
DROP TABLE aliens_logs;
CREATE TABLE IF NOT EXISTS aliens_logs (
	table_name VARCHAR(10), 					-- table name of insert operation
	orig_table_prim_key_id BIGINT UNSIGNED, 	-- primary key identifier of inserted object in original table
	inserted_name VARCHAR(255), 				-- the content of field 'name' of inserted data
	insert_time DATETIME 						-- time of isert operation
) ENGINE = Archive; 
SELECT * FROM aliens_logs;

-- create same trigger as 11-1 task for aliens
DROP TRIGGER logging_aliens;
CREATE TRIGGER logging_aliens AFTER INSERT ON aliens
FOR EACH ROW
BEGIN
	INSERT INTO aliens_logs(table_name, orig_table_prim_key_id, inserted_name, insert_time)
	VALUES ('aliens',NEW.id, NEW.name, CURRENT_TIMESTAMP);
END;

-- check if everything works correct
SELECT name_insert (10);
SELECT COUNT(id) FROM aliens a ;
SELECT * FROM aliens_logs;
-- real call of name_insert(1000000) drops my vm down for unknown reason (RAM maybe?)
-- so I did 250k per call and called function 4 times
SELECT name_insert (250000);





