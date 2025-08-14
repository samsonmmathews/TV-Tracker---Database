-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 14, 2025 at 07:40 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tvseries_db`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_get_series_score` (`watched_episodes` INT, `total_episodes` INT, `imdb_rating` DECIMAL(10,2), `next_episode_rating` DECIMAL(10,2)) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
	DECLARE score DECIMAL(10,2);
  
	SET score = (((watched_episodes/total_episodes)*100) + (imdb_rating * 10) + (next_episode_rating *10))/3;

	RETURN score;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`company_id`, `name`) VALUES
(1, 'Showtime'),
(2, 'Netflix'),
(3, 'AMC'),
(4, 'HBO'),
(5, 'Hulu');

-- --------------------------------------------------------

--
-- Table structure for table `series`
--

CREATE TABLE `series` (
  `series_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `release_year` int(11) DEFAULT NULL,
  `total_episodes` int(11) DEFAULT NULL,
  `imdb_rating` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `series`
--

INSERT INTO `series` (`series_id`, `title`, `company_id`, `release_year`, `total_episodes`, `imdb_rating`) VALUES
(1, 'Dexter', 1, 2006, 96, 8.60),
(2, 'Stranger Things', 2, 2016, 34, 8.60),
(3, 'Breaking Bad', 3, 2008, 62, 9.50),
(4, 'Game of Thrones', 4, 2011, 73, 9.20),
(5, 'The Crown', 2, 2016, 60, 8.60),
(6, 'The Handmaid\'s Tale', 5, 2017, 56, 8.40),
(7, 'Westworld', 4, 2016, 36, 8.50),
(8, 'Ozark', 2, 2017, 44, 8.50),
(9, 'Better Call Saul', 3, 2015, 63, 8.90),
(10, 'Mindhunter', 2, 2017, 19, 8.60);

-- --------------------------------------------------------

--
-- Table structure for table `user_details`
--

CREATE TABLE `user_details` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_details`
--

INSERT INTO `user_details` (`user_id`, `user_name`, `email`) VALUES
(1, 'John', 'john@email.com'),
(2, 'Morgan', 'morgam@email.com'),
(3, 'Melissa', 'melissa@email.com'),
(4, 'Daniel', 'daniel@email.com'),
(5, 'Sophia', 'sophia@email.com'),
(6, 'Ethan', 'ethan@email.com'),
(7, 'Isabella', 'isabella@email.com'),
(8, 'James', 'james@email.com'),
(9, 'Olivia', 'olivia@email.com'),
(10, 'Liam', 'liam@email.com');

-- --------------------------------------------------------

--
-- Table structure for table `user_series`
--

CREATE TABLE `user_series` (
  `user_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `watched_episodes` int(11) DEFAULT NULL,
  `next_episode_rating` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_series`
--

INSERT INTO `user_series` (`user_id`, `series_id`, `watched_episodes`, `next_episode_rating`) VALUES
(1, 1, 42, 8.90),
(1, 4, 20, 9.10),
(1, 7, 10, 8.70),
(2, 2, 34, 8.20),
(2, 5, 15, 8.50),
(2, 9, 25, 8.90),
(3, 1, 96, 0.00),
(3, 3, 30, 9.40),
(3, 8, 12, 8.50),
(4, 3, 62, 0.00),
(4, 4, 73, 0.00),
(4, 6, 18, 8.10),
(5, 2, 20, 8.30),
(5, 8, 30, 8.60),
(5, 10, 19, 0.00),
(6, 5, 12, 8.40),
(6, 7, 36, 0.00),
(6, 9, 40, 8.80),
(7, 1, 50, 8.70),
(7, 6, 56, 0.00),
(7, 10, 15, 8.50),
(8, 3, 55, 9.20),
(8, 4, 60, 9.00),
(8, 9, 63, 0.00),
(9, 2, 28, 8.40),
(9, 5, 60, 0.00),
(9, 8, 44, 0.00),
(10, 4, 35, 9.00),
(10, 7, 20, 8.60),
(10, 10, 10, 8.30);

--
-- Triggers `user_series`
--
DELIMITER $$
CREATE TRIGGER `trg_update_series_rating` BEFORE INSERT ON `user_series` FOR EACH ROW BEGIN
    DECLARE var_total_ep INT;

    SELECT total_episodes INTO var_total_ep
    FROM series
    WHERE series_id = NEW.series_id;

    IF NEW.watched_episodes >= var_total_ep THEN
        SET NEW.next_episode_rating = 0;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_series_ranking_view`
-- (See below for the actual view)
--
CREATE TABLE `user_series_ranking_view` (
`user_id` int(11)
,`user_name` varchar(100)
,`series_id` int(11)
,`series_title` varchar(100)
,`watched_episodes` int(11)
,`total_episodes` int(11)
,`imdb_rating` decimal(10,2)
,`next_episode_rating` decimal(10,2)
,`score` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Structure for view `user_series_ranking_view`
--
DROP TABLE IF EXISTS `user_series_ranking_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_series_ranking_view`  AS SELECT `ud`.`user_id` AS `user_id`, `ud`.`user_name` AS `user_name`, `s`.`series_id` AS `series_id`, `s`.`title` AS `series_title`, `us`.`watched_episodes` AS `watched_episodes`, `s`.`total_episodes` AS `total_episodes`, `s`.`imdb_rating` AS `imdb_rating`, `us`.`next_episode_rating` AS `next_episode_rating`, `fn_get_series_score`(`us`.`watched_episodes`,`s`.`total_episodes`,`s`.`imdb_rating`,`us`.`next_episode_rating`) AS `score` FROM ((`user_series` `us` join `user_details` `ud` on(`us`.`user_id` = `ud`.`user_id`)) join `series` `s` on(`us`.`series_id` = `s`.`series_id`)) ORDER BY `fn_get_series_score`(`us`.`watched_episodes`,`s`.`total_episodes`,`s`.`imdb_rating`,`us`.`next_episode_rating`) DESC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`company_id`);

--
-- Indexes for table `series`
--
ALTER TABLE `series`
  ADD PRIMARY KEY (`series_id`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `user_details`
--
ALTER TABLE `user_details`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_series`
--
ALTER TABLE `user_series`
  ADD PRIMARY KEY (`user_id`,`series_id`),
  ADD KEY `series_id` (`series_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `company_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `series`
--
ALTER TABLE `series`
  MODIFY `series_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_details`
--
ALTER TABLE `user_details`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `series`
--
ALTER TABLE `series`
  ADD CONSTRAINT `series_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `company` (`company_id`);

--
-- Constraints for table `user_series`
--
ALTER TABLE `user_series`
  ADD CONSTRAINT `user_series_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_details` (`user_id`),
  ADD CONSTRAINT `user_series_ibfk_2` FOREIGN KEY (`series_id`) REFERENCES `series` (`series_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
