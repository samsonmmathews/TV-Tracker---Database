-- Create tables

CREATE TABLE user_details (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL
);

CREATE TABLE company (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE series (
    series_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    company_id INT,
    release_year INT,
    total_episodes INT,
    imdb_rating DECIMAL(10,2),
    FOREIGN KEY (company_id) REFERENCES company(company_id)
);

CREATE TABLE user_series (
    user_id INT,
    series_id INT,
    watched_episodes INT,
    next_episode_rating DECIMAL(10,2),
    PRIMARY KEY (user_id, series_id),
    FOREIGN KEY (user_id) REFERENCES user_details(user_id),
    FOREIGN KEY (series_id) REFERENCES series(series_id)
);

-- Insert data into 'company' table

INSERT INTO company (name) VALUES
('Showtime'),
('Netflix'),
('AMC'),
('HBO'),
('Hulu');

-- Insert data into 'series' table

INSERT INTO series (title, company_id, release_year, total_episodes, imdb_rating) VALUES
('Dexter', 1, 2006, 96, 8.6),
('Stranger Things', 2, 2016, 34, 8.6),
('Breaking Bad', 3, 2008, 62, 9.5),
('Game of Thrones', 4, 2011, 73, 9.2),
('The Crown', 2, 2016, 60, 8.6),
('The Handmaid''s Tale', 5, 2017, 56, 8.4),
('Westworld', 4, 2016, 36, 8.5),
('Ozark', 2, 2017, 44, 8.5),
('Better Call Saul', 3, 2015, 63, 8.9),
('Mindhunter', 2, 2017, 19, 8.6);

-- Insert data into 'user_details' table

INSERT INTO user_details (name, email) VALUES
('John', 'john@email.com'),
('Morgan', 'morgan@email.com'),
('Melissa', 'melissa@email.com'),
('Daniel', 'daniel@email.com'),
('Sophia', 'sophia@email.com'),
('Ethan', 'ethan@email.com'),
('Isabella', 'isabella@email.com'),
('James', 'james@email.com'),
('Olivia', 'olivia@email.com'),
('Liam', 'liam@email.com');

-- Insert data into 'user_series' table

INSERT INTO user_series (user_id, series_id, watched_episodes, next_episode_rating) VALUES
(1, 1, 42, 8.9),
(1, 4, 20, 9.1),
(1, 7, 10, 8.7),
(2, 2, 34, 0),
(2, 5, 15, 8.5),
(2, 9, 25, 8.9),
(3, 1, 96, 0),
(3, 3, 30, 9.4),
(3, 8, 12, 8.5),
(4, 3, 62, 0),
(4, 4, 73, 0),
(4, 6, 18, 8.1),
(5, 2, 20, 8.3),
(5, 8, 30, 8.6),
(5, 10, 19, 0),
(6, 5, 12, 8.4),
(6, 7, 36, 0),
(6, 9, 40, 8.8),
(7, 1, 50, 8.7),
(7, 6, 56, 0),
(7, 10, 15, 8.5),
(8, 3, 55, 9.2),
(8, 4, 60, 9.0),
(8, 9, 63, 0),
(9, 2, 28, 8.4),
(9, 5, 60, 0),
(9, 8, 44, 0),
(10, 4, 35, 9.0),
(10, 7, 20, 8.6),
(10, 10, 10, 8.3);

-- A function to calculate the series score for a given user and series.

DELIMITER //
CREATE FUNCTION fn_get_series_score(
watched_episodes INT, total_episodes INT, imdb_rating DECIMAL(10,2), next_episode_rating DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
	BEGIN
	DECLARE score DECIMAL(10,2);

	SET score = (((watched_episodes/total_episodes)*100) + (imdb_rating * 10) + (next_episode_rating *10))/3;

	RETURN score;
END //

DELIMITER ;

-- A view called 'user_series_ranking' that calculates the scores of each tv series based on the episodes they have watched, imdb rating and the rating for the next episode they are going to watch. 
-- All the episodes the user has watched will be displayed in the descending order of the score

CREATE VIEW user_series_ranking_view AS
SELECT 
    ud.user_id,
    ud.name,
    s.series_id,
    s.title AS series_title,
    us.watched_episodes,
    s.total_episodes,
    s.imdb_rating,
    us.next_episode_rating,
    fn_get_series_score(us.watched_episodes, s.total_episodes, s.imdb_rating, us.next_episode_rating) AS score
FROM user_series us
JOIN user_details ud ON us.user_id = ud.user_id
JOIN series s ON us.series_id = s.series_id
ORDER BY score DESC;

-- A trigger to check if there are any next episodes to watch and if there aren't any next episodes, make the next episode rating as 0

DELIMITER //

CREATE TRIGGER trg_update_series_rating
BEFORE INSERT ON user_series
FOR EACH ROW
BEGIN
    DECLARE var_total_ep INT;

    SELECT total_episodes INTO var_total_ep
    FROM series
    WHERE series_id = NEW.series_id;

    IF NEW.watched_episodes >= var_total_ep THEN
        SET NEW.next_episode_rating = 0;
    END IF;
END;
//

DELIMITER ;

-- Example values for trigger: 
INSERT INTO user_series (user_id, series_id, watched_episodes, next_episode_rating) VALUES
(1, 2, 34, 8.9);
