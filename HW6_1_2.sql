USE vk;

-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes 
  SELECT 
    message_id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Проверим
SELECT * FROM likes LIMIT 10;

-- Создадим таблицу постов
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DESC profiles;
DESC users;
ALTER TABLE profiles MODIFY COLUMN photo_id BIGINT UNSIGNED;
SELECT * FROM profiles;
-- Добавляем внешние ключи
ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
DESC media;
DESC profiles;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;

DESC profiles;
DESC countries;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_country_id_fk
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE;
DESC statuses;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_status_id_fk
    FOREIGN KEY (status_id) REFERENCES statuses(status_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;
     
DESC chats;
DESC users;
ALTER TABLE chats
  ADD CONSTRAINT chats_init_user_id_fk
    FOREIGN KEY (init_user_id) REFERENCES users(id)
      ON DELETE CASCADE;
 ALTER TABLE chats
  ADD CONSTRAINT chats_to_user_id_fk
    FOREIGN KEY (to_user_id) REFERENCES users(id)
      ON DELETE CASCADE;
      
 DESC communities_users;
ALTER TABLE communities_users DROP FOREIGN KEY communities_users_user_id_fk;

  ALTER TABLE communities_users 
  ADD CONSTRAINT communities_users_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE;
  ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE RESTRICT;
      
DESC friendship;
ALTER TABLE friendship
ADD CONSTRAINT friendship_user_id_fk
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE;
ALTER TABLE friendship
ADD CONSTRAINT friendship_friend_id_fk
  FOREIGN KEY (friend_id) REFERENCES users(id)
    ON DELETE CASCADE;
ALTER TABLE friendship
ADD CONSTRAINT friendship_status_id_fk
  FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

DESC messages;
ALTER TABLE messages
  ADD CONSTRAINT messages_chat_id_fk
    FOREIGN KEY (chat_id) REFERENCES chats(chat_id)
      ON DELETE CASCADE;

DESC posts ;
UPDATE posts SET community_id = community_id MOD 25;
UPDATE posts SET community_id = NULL WHERE community_id = 0;
UPDATE posts SET created_at = NOW();
UPDATE posts SET updated_at = NOW();
DESC communities;
ALTER TABLE posts MODIFY user_id BIGINT UNSIGNED NOT NULL;
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE RESTRICT;
ALTER TABLE posts
  ADD CONSTRAINT posts_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE RESTRICT;

DESC media;
ALTER TABLE media
  ADD CONSTRAINT media_owner_id_fk
    FOREIGN KEY (owner_id) REFERENCES users(id)
      ON DELETE CASCADE;
ALTER TABLE media
  ADD CONSTRAINT media_media_type_id_fk
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE;
  
DESC likes;
ALTER TABLE likes MODIFY user_id BIGINT UNSIGNED NOT NULL;
ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk
  	FOREIGN KEY (user_id) REFERENCES users(id)
  	  ON DELETE RESTRICT;
 ALTER TABLE likes
   ADD CONSTRAINT likes_target_type_id_fk
     FOREIGN KEY (target_type_id) REFERENCES target_types(id)
       ON DELETE CASCADE
       ON UPDATE CASCADE;