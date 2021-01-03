-- practice for data aggregation
	-- #1
		USE shop;
		SELECT * FROM users;
		SELECT
			FLOOR(AVG(FLOOR((TO_DAYS(NOW()) - TO_DAYS(birthday_at))/365.25))) AS mean_age -- we can set FLOOR before or after AVG or in bith cases and get 31, 30.5 or 30, it is debatable,
		FROM
			users;
	
	-- #2
		USE shop;
		-- creating temporary table for counting birthdays
		DROP TABLE birth_at_weekday;
		CREATE TEMPORARY TABLE IF NOT EXISTS birth_at_weekday(
			day_id INT UNSIGNED,
			day_name VARCHAR(10) UNIQUE,
			number_of_births INT UNSIGNED DEFAULT 0
		);
		DESC birth_at_weekday;
		-- fill temporary table with day names
		INSERT INTO birth_at_weekday(day_id,day_name)
		VALUES
			(0,DATE_FORMAT('2017-01-01', '%W')),(1,DATE_FORMAT('2017-01-02', '%W')),(2,DATE_FORMAT('2017-01-03', '%W')),(3,DATE_FORMAT('2017-01-04', '%W')),(4,DATE_FORMAT('2017-01-05', '%W')),
			(5,DATE_FORMAT('2017-01-06', '%W')),(6,DATE_FORMAT('2017-01-07', '%W'));
		-- count dirthdays by days of the week (it is not the best but the only one working querry I've been able to build \_(0o)_/). How it is to make it less complicated?
		UPDATE birth_at_weekday 
		SET number_of_births = 
			(SELECT COUNT(DAYOFWEEK(CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d')))) FROM users 
			 WHERE DATE_FORMAT((CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d'))),'%W')=day_name);
		-- check the result
		SELECT * FROM birth_at_weekday;
		-- selfcontrol querries (helpess to unite them into single querry)
		SELECT COUNT(DAYOFWEEK(CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d')))) AS num FROM users GROUP BY DATE_FORMAT((CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d'))),'%W'); 
		SELECT DATE_FORMAT((CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d'))),'%W') AS days FROM users GROUP BY DATE_FORMAT((CONCAT(YEAR(NOW()),'-',DATE_FORMAT(birthday_at, '%m-%d'))),'%W');
		
	-- #3
		USE shop;
		-- this is to calculate product of multipying of not null value in a particular storehouse (it is obviously 0 when there is at least 1 null value).
		-- tried to create a solution without additional variables, search for how to implement the idea of logarithm and potentiate back. Had similar task in university.
		SELECT ROUND(EXP(SUM(LOG(value))),0) FROM storehouses_products sp WHERE storehouse_id = 1 & value !=0;
		-- this is to calculate product of multipying of users id
		SELECT ROUND(EXP(SUM(LOG(id))),0) FROM users;
		