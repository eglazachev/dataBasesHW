USE vk;
SHOW TABLES;
SELECT * FROM likes LIMIT 10;
SELECT COUNT(*) FROM likes;

-- #3
-- Unable to invent query to get only the gender letter as result.
-- MAX() operator applying was full of errors, hope to get explanation (just a few words) on lesson.
SELECT COUNT(*) AS likes FROM profiles p
WHERE
	user_id IN (SELECT user_id FROM likes) 
GROUP BY 
	gender
ORDER BY
	likes DESC
LIMIT 1;

-- #4
-- the most conviniet way leads to the error:
-- SQL Error [1235] [42000]: This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'
SELECT COUNT(*) AS total_likes FROM likes l
WHERE
	user_id IN (SELECT user_id FROM profiles ORDER BY birthday LIMIT 10);

-- so I've found the 10th youth user and used its id to compare birthdays in WHERE condition
SELECT user_id, birthday FROM profiles ORDER BY birthday DESC LIMIT 10;
SELECT COUNT(*) AS total_likes FROM likes l
WHERE
	user_id IN (SELECT user_id FROM profiles WHERE birthday >= (SELECT birthday FROM profiles WHERE user_id = 85));


-- # 5
-- my criteria were the total amount of likes, friendships and posts

DESC friendship;
DESC friendship_statuses;
SELECT * FROM friendship_statuses fs ;
SELECT user_id FROM profiles p LIMIT 10;

-- firstly I decided to count every activity

SELECT COUNT(*) AS posts, user_id FROM posts GROUP BY user_id ORDER BY posts DESC;

SELECT COUNT(*) AS friendships_quantity, user_id FROM friendship f2 
WHERE status_id < 5
GROUP BY user_id
ORDER BY friendships_quantity DESC;

SELECT COUNT(*) AS friendships_quantity, friend_id FROM friendship f2 
WHERE status_id < 5
GROUP BY friend_id
ORDER BY friendships_quantity DESC;

SELECT COUNT(*) AS likes_quantity FROM likes GROUP BY user_id ORDER BY likes_quantity  DESC;

SELECT COUNT(*) AS chat_activity, init_user_id FROM chats c 
GROUP BY init_user_id 
ORDER BY chat_activity DESC;

SELECT COUNT(*) AS chat_activity, to_user_id FROM chats c 
GROUP BY to_user_id 
ORDER BY chat_activity DESC;

-- then I wanted to count every select_count result of above for each user. BUT I FAILED HARD to construct it  =(((



-- further, there was the idea of some table with rankings in every area of activity.
-- the total sum of activity points will be sorted so we get the activity leaders
-- unfortunately I haven't found a working query to take row 

CREATE TEMPORARY TABLE activity (
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	likes_given INT UNSIGNED DEFAULT 0,
	chats_participation INT UNSIGNED DEFAULT 0,
	friendships INT UNSIGNED DEFAULT 0,
	postings INT UNSIGNED DEFAULT 0
);

INSERT INTO activity(user_id) SELECT id FROM users;

SELECT * FROM activity;


-- friendship activity
UPDATE 
	activity 
SET 
	friendships = 
		(SELECT COUNT(*) FROM friendship 
		WHERE (user_id = activity.user_id OR friend_id = activity.user_id) AND status_id < 5);

-- chat activity
UPDATE 
	activity 
SET 
	chats_participation = 
		(SELECT COUNT(*) 
		FROM chats 
		WHERE init_user_id = activity.user_id OR to_user_id = activity.user_id);

-- likes activity
UPDATE 
	activity 
SET 
	likes_given = 
		(SELECT COUNT(*) FROM likes WHERE user_id = activity.user_id);

-- post activity
UPDATE 
	activity 
SET 
	postings = 
		(SELECT COUNT(*) FROM posts WHERE user_id = activity.user_id);


SELECT 
	(likes_given + chats_participation + postings + friendships) AS sum_activity, user_id, first_name, last_name 
FROM 
	activity 
JOIN 
	users 
ON 
	user_id = id 
ORDER BY 
	sum_activity DESC 
LIMIT 10;


-- FINALLY!!! I've done it in a single select query!

SELECT (
(SELECT COUNT(*) FROM posts WHERE user_id = users.id)
+
(SELECT COUNT(*) FROM friendship f2 
WHERE user_id = users.id AND status_id != 5)
+
(SELECT COUNT(*) FROM friendship f2 
WHERE friend_id = users.id AND  status_id != 5)
+
(SELECT COUNT(*) FROM likes WHERE user_id = users.id)
+
(SELECT COUNT(*) FROM chats c 
WHERE init_user_id = users.id)
+
(SELECT COUNT(*) FROM chats c 
WHERE to_user_id = users.id)) 
AS activity, first_name, last_name 
FROM users ORDER BY activity DESC LIMIT 10;

SELECT COUNT(*) FROM friendship f2 
WHERE user_id = 13;

