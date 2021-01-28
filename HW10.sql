USE vk_10; -- I created replica of initian DB to prevent crash or anything bad with original DB
SHOW tables;
DESC users;
-- CREATE INDEX users_email_idx ON users(email);

-- #1 Проанализировать какие запросы могут выполняться наиболее часто 
-- в процессе работы приложения и добавить необходимые индексы.

-- If I correctly understand the essence of indexes so we should give indexex to those fields from tables
-- where it is possibly often querries to the non-id-fields. 
-- Especially text fields. So I'm not sure about messages(body). Is it worth to index it??
-- In other case we should use primary_key_index of tables 

-- This is to make faster password resrtoring, logging in
CREATE INDEX users_email_idx ON users(email);
CREATE INDEX users_phone_idx ON users(phone);

-- These are to make searching by name faster
CREATE INDEX users_first_name_idx ON users(first_name); 
CREATE INDEX users_last_name_idx ON users(last_name);

-- These are to make search faster, there could be different places 
-- where it is required if DB contain more table and entities
CREATE INDEX profile_city_idx ON profiles(city); -- This is to narrow down search area
CREATE INDEX media_filename_idx ON media(filename); -- This is to search video or audio files, it seems to be very useful
CREATE INDEX communities_name_idx ON communities(name); -- This is last for HW10. It's enough current DB is not specified enough to operate
														-- more complicated things. 
														-- Of course I'm wrong with the message above, but I don't know what else


-- #2 Задание на оконные функции (it is done, but I'm not satisfied with the solution)
-- Построить запрос, который будет выводить следующие столбцы: 
-- - имя группы 
-- - среднее количество пользователей в группах 
-- - самый молодой пользователь в группе 
-- - самый старший пользователь в группе 
-- - общее количество пользователей в группе 
-- - всего пользователей в системе 
-- - отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100


-- Check the situation
DESC communities;
DESC communities_users;
SELECT DISTINCT p2.user_id AS system_total_users FROM communities_users cu JOIN profiles p2;
SELECT * FROM communities_users cu;
SELECT * FROM communities c;

-- Get the quantity of users in groups
SELECT 
	DISTINCT COUNT(cu2.user_id) OVER (PARTITION BY cu2.community_id) AS users_in_group,
	cu2.community_id AS single_community_id 
	FROM communities_users cu2;

-- Here I'm getting names by group?but can't do it only for youngest user
SELECT DISTINCT CONCAT (u.first_name, " ", u.last_name) AS young_name, 
	MAX(p.birthday) OVER (PARTITION BY cu.community_id) AS birth,
	cu.community_id
FROM users u 
RIGHT JOIN profiles p
ON p.user_id = u.id
RIGHT JOIN communities_users cu
ON p.user_id = cu.user_id;

-- I'm not able to write more clear code to get the same result, so I,m curious how to get same result in two rows of code. I'm sure there is the way.
-- The problem is that I can't get link to users.id after getting the youngest/oldest group member with max/min window function
SELECT u.first_name AS old_name, old_age.c_id, old_age.oldest FROM profiles p 
JOIN users u 
	ON p.user_id = u.id 
JOIN
	(SELECT DISTINCT cu2.community_id AS c_id, 
		MAX(p2.birthday) OVER (PARTITION BY cu2.community_id) AS oldest
		FROM communities_users cu2 JOIN profiles p2 
		ON cu2.user_id = p2.user_id) AS old_age 
	ON p.birthday = old_age.oldest
;

-- This gives me the age of the youngest user by group
SELECT
	DISTINCT cu.community_id, 
	MIN(FLOOR(DATEDIFF(NOW(),p.birthday)/365.25)) OVER (PARTITION BY cu.community_id) AS youngest
FROM profiles p
JOIN communities_users cu
ON cu.user_id = p.user_id 
;
-- Check how the FLOOR operates
SELECT birthday, FLOOR(DATEDIFF(NOW(), birthday)/365.25) FROM profiles p;

-- That was a fighting with aliases of derived tables
SELECT AVG(avg_tot.average_total) 
FROM 
	(SELECT COUNT(cu2.user_id) OVER (PARTITION BY cu2.community_id) AS average_total 
	FROM communities_users cu2) AS avg_tot;


-- This is my working query, I know it is very big and looks very heavy and not optimized at all I guess.
-- But it works, and I can't make it smaller or easier. I was honestly trying to fix it for 3 days, probably I'm the worst student here=)
SELECT DISTINCT c.name,
AVG(user_count.users_in_group) OVER () AS average_group_users,										-- This is average quantity of users in the group.
-- MIN(FLOOR(DATEDIFF(NOW(),p.birthday)/365.25)) OVER (PARTITION BY cu.community_id) AS youngest, 	-- This is the age of youngest user. It was quite easy.
-- MAX(FLOOR(DATEDIFF(NOW(),p.birthday)/365.25)) OVER (PARTITION BY cu.community_id) AS oldest,		-- This is the age of oldest user.
AVG(FLOOR(DATEDIFF(NOW(), p.birthday)/365.25)) OVER (PARTITION BY cu.community_id) AS average_age,	-- This is average age of users in the group.
COUNT(cu.user_id) OVER (PARTITION BY cu.community_id) AS users_in_group,							-- This is quantity of user in group.
old_users_by_group.old_name,																		-- This is the name of the oldest user in the group.
young_users_by_group.young_name, 																	-- This is the name of the youngest user in the group.
(SELECT COUNT(users.id) FROM users) AS system_total_users,											-- THis is total quantity of users in system.
CONCAT(COUNT(cu.user_id) OVER (PARTITION BY cu.community_id)/(SELECT COUNT(users.id) FROM users)*100, "%") AS members_of_users
FROM users u 
RIGHT JOIN profiles p
ON p.user_id = u.id
LEFT JOIN communities_users cu
ON p.user_id = cu.user_id
RIGHT JOIN communities c 
ON cu.community_id = c.id
LEFT JOIN -- Joining the total quantity of members by group, because can't AVG(count/count) or smth like that
		(SELECT 
		DISTINCT COUNT(cu2.user_id) OVER (PARTITION BY cu2.community_id) AS users_in_group,
		cu2.community_id AS single_community_id 
		FROM communities_users cu2) 
		AS user_count
	ON user_count.single_community_id = c.id		
JOIN -- Joining oldest users by group
	(SELECT u.first_name AS old_name, old_age.c_id AS com_id, old_age.oldest FROM profiles p 
		JOIN users u 
			ON p.user_id = u.id 
		JOIN
			(SELECT DISTINCT cu2.community_id AS c_id, 
				MIN(p2.birthday) OVER (PARTITION BY cu2.community_id) AS oldest
				FROM communities_users cu2 JOIN profiles p2 
				ON cu2.user_id = p2.user_id) AS old_age 
			ON p.birthday = old_age.oldest) AS old_users_by_group
	ON old_users_by_group.com_id = c.id
JOIN -- joining youngest users by group
	(SELECT u.first_name AS young_name, young_age.c_id AS com_id, young_age.youngest FROM profiles p 
		JOIN users u 
			ON p.user_id = u.id 
		JOIN
			(SELECT DISTINCT cu2.community_id AS c_id, 
				MAX(p2.birthday) OVER (PARTITION BY cu2.community_id) AS youngest
				FROM communities_users cu2 JOIN profiles p2 
				ON cu2.user_id = p2.user_id) AS young_age 
			ON p.birthday =young_age.youngest) AS young_users_by_group
	ON young_users_by_group.com_id = c.id
;





