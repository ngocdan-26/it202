CREATE DATABASE baithuchanh;
USE baithuchanh;

-- 1. BẢNG USERS
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. BẢNG POSTS
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_posts_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 3. BẢNG COMMENTS
CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
    ON DELETE CASCADE,

    CONSTRAINT fk_comments_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 4. BẢNG FRIENDS
CREATE TABLE friends (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, friend_id),
    
    CONSTRAINT fk_friends_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

    CONSTRAINT fk_friends_friend
    FOREIGN KEY (friend_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

    CONSTRAINT chk_friend_status
    CHECK (status IN ('pending', 'accepted')),

    CONSTRAINT chk_not_self_friend
    CHECK (user_id <> friend_id)
);

-- 5. BẢNG LIKES
CREATE TABLE likes (
    user_id INT NOT NULL,
    post_id INT NOT NULL,

    PRIMARY KEY (user_id, post_id),

    CONSTRAINT fk_likes_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,

    CONSTRAINT fk_likes_post
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
    ON DELETE CASCADE
);

-- REQ-06: INDEX TỐI ƯU NEWSFEED
CREATE INDEX idx_post_created_at
ON posts(created_at);

-- REQ-01: VIEW HỒ SƠ NGƯỜI DÙNG AN TOÀN
CREATE VIEW vw_userinfo AS
SELECT
    user_id,
    username,
    email,
    created_at
FROM users;

-- REQ-02: VIEW THỐNG KÊ TƯƠNG TÁC BÀI VIẾT
CREATE VIEW vw_poststatistics AS
SELECT
    p.post_id,
    p.content,
    u.username AS author_name,
    COUNT(DISTINCT l.user_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM posts p
INNER JOIN users u
    ON p.user_id = u.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY
    p.post_id,
    p.content,
    u.username;

-- REQ-03: STORED PROCEDURE ĐĂNG KÝ USER
DELIMITER //
CREATE PROCEDURE sp_register_user (
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE email_count INT;
    SELECT COUNT(*)
    INTO email_count
    FROM users
    WHERE email = p_email;
    IF email_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email đã được sử dụng';
    ELSE
        INSERT INTO users (
            username,
            password,
            email
        )
        VALUES (
            p_username,
            p_password,
            p_email
        );
    END IF;
END //
DELIMITER ;

-- REQ-04: STORED PROCEDURE ĐĂNG BÀI VIẾT
DELIMITER //
CREATE PROCEDURE sp_create_post (
    IN p_user_id INT,
    IN p_content TEXT,
    OUT p_post_id INT
)
BEGIN
    INSERT INTO posts (
        user_id,
        content
    )
    VALUES (
        p_user_id,
        p_content
    );
    SET p_post_id = LAST_INSERT_ID();
END //
DELIMITER ;

-- REQ-05: LẤY DANH SÁCH BẠN BÈ PHÂN TRANG
DELIMITER //

CREATE PROCEDURE sp_get_friends_paginated (
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT
        u.username,
        u.email
    FROM friends f
    INNER JOIN users u
        ON f.friend_id = u.user_id
    WHERE f.user_id = p_user_id
    AND f.status = 'accepted'
    LIMIT p_limit OFFSET p_offset;
END //

DELIMITER ;

-- DỮ LIỆU MẪU TEST
INSERT INTO users (username, password, email)
VALUES
('admin', '123456', 'admin@gmail.com'),
('john', '123456', 'john@gmail.com'),
('alice', '123456', 'alice@gmail.com');

INSERT INTO posts (user_id, content)
VALUES
(1, 'Xin chào mạng xã hội'),
(2, 'Hôm nay trời đẹp');

INSERT INTO comments (post_id, user_id, content)
VALUES
(1, 2, 'Hay quá'),
(1, 3, 'Chào bạn');

INSERT INTO likes (user_id, post_id)
VALUES
(2, 1),
(3, 1);

INSERT INTO friends (user_id, friend_id, status)
VALUES
(1, 2, 'accepted'),
(1, 3, 'pending');

-- TEST PROCEDURE
-- Đăng ký user
CALL sp_register_user(
    'new_user',
    '123456',
    'new@gmail.com'
);

-- Đăng bài viết
SET @new_post_id = 0;
CALL sp_create_post(
    1,
    'Bài viết mới',
    @new_post_id
);
SELECT @new_post_id;

-- Danh sách bạn bè phân trang
CALL sp_get_friends_paginated(
    1,
    10,
    0
);

-- Xem View user
SELECT * FROM vw_userinfo;
-- Xem thống kê bài viết
SELECT * FROM vw_poststatistics;