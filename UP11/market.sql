-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 17 2025 г., 12:14
-- Версия сервера: 8.0.19
-- Версия PHP: 7.1.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `market`
--
CREATE DATABASE IF NOT EXISTS `market` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `market`;

-- --------------------------------------------------------

--
-- Структура таблицы `author`
--

CREATE TABLE `author` (
  `idAuthor` int NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `country` varchar(30) NOT NULL DEFAULT 'Россия '
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `author`
--

INSERT INTO `author` (`idAuthor`, `surname`, `name`, `country`) VALUES
(1, 'Толстой', 'Алексей', 'Россия'),
(2, 'Достоевский', 'Мяу', 'Россия'),
(3, 'Шекспир', 'Уильям', 'Англия'),
(4, 'Гете', 'Иоганн Вольфганг', 'Германия'),
(5, 'Бальзак', 'Оноре де', 'Франция'),
(6, 'Пушкин', 'Александр', 'Россия');

-- --------------------------------------------------------

--
-- Структура таблицы `author_2`
--

CREATE TABLE `author_2` (
  `idAuthor` int NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `country` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `author_2`
--

INSERT INTO `author_2` (`idAuthor`, `surname`, `name`, `country`) VALUES
(1, 'Булгаков', 'Михаил', 'Россия'),
(2, 'Толстой', 'Лев', 'Россия');

-- --------------------------------------------------------

--
-- Структура таблицы `book`
--

CREATE TABLE `book` (
  `idBook` int NOT NULL,
  `idAuthor` int NOT NULL,
  `title` varchar(50) NOT NULL,
  `genre` enum('проза','поэзия','другое') NOT NULL DEFAULT 'проза',
  `price` decimal(6,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `weight` decimal(4,3) UNSIGNED NOT NULL DEFAULT '0.000',
  `page` smallint UNSIGNED NOT NULL DEFAULT '0',
  `release` year DEFAULT NULL,
  `count` int DEFAULT '100'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `book`
--

INSERT INTO `book` (`idBook`, `idAuthor`, `title`, `genre`, `price`, `weight`, `page`, `release`, `count`) VALUES
(1, 1, 'Война и мир', 'другое', '100.00', '1.000', 1200, 1969, 49),
(2, 2, 'Преступление и наказание', 'другое', '630.00', '0.900', 800, 1970, 49),
(3, 3, 'Гамлет', 'другое', '420.00', '0.300', 200, 1971, 50),
(4, 4, 'Фауст', 'другое', '525.00', '0.400', 300, 1972, 50),
(5, 5, 'Папа Горьот', 'другое', '5775.00', '0.600', 500, 1973, 50),
(6, 1, 'Анна Каренина', 'другое', '735.00', '1.000', 900, 1969, 50),
(7, 2, 'Игрок', 'другое', '1470.00', '0.400', 200, 1973, 50),
(8, 6, 'Сказка о рыбаке и рыбки', 'другое', '210.00', '0.100', 20, 1975, 50),
(9, 1, 'Детство', 'другое', '6000.00', '0.123', 56, 1980, 50);

--
-- Триггеры `book`
--
DELIMITER $$
CREATE TRIGGER `before_insert_book` BEFORE INSERT ON `book` FOR EACH ROW BEGIN
  IF NEW.price > 5000 THEN
    SET NEW.price = 5000;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_book` AFTER DELETE ON `book` FOR EACH ROW BEGIN
    INSERT INTO logs (_table, operation, dateTime, currentUser)
    VALUES ('book', 'DELETE', NOW(), CURRENT_USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_book` AFTER INSERT ON `book` FOR EACH ROW BEGIN
    INSERT INTO logs (_table, operation, dateTime, currentUser)
    VALUES ('book', 'INSERT', NOW(), CURRENT_USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_book` AFTER UPDATE ON `book` FOR EACH ROW BEGIN
    INSERT INTO logs (_table, operation, dateTime, currentUser)
    VALUES ('book', 'UPDATE', NOW(), CURRENT_USER());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `composition`
--

CREATE TABLE `composition` (
  `Order_idOrder` int NOT NULL,
  `Book_idBook` int NOT NULL,
  `Count` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `composition`
--

INSERT INTO `composition` (`Order_idOrder`, `Book_idBook`, `Count`) VALUES
(1, 1, 9),
(1, 2, 3),
(1, 3, 1),
(2, 3, 3),
(2, 6, 1),
(4, 6, 2),
(4, 7, 2),
(5, 1, 1),
(5, 5, 1);

--
-- Триггеры `composition`
--
DELIMITER $$
CREATE TRIGGER `before_insert_composition` BEFORE INSERT ON `composition` FOR EACH ROW BEGIN
  UPDATE Book
  SET count = count - NEW.count
  WHERE idBook = NEW.Book_idBook;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_composition` AFTER INSERT ON `composition` FOR EACH ROW SELECT SUM(composition.count * price) INTO @orderCost
	FROM composition
    LEFT JOIN book ON composition.Book_idBook = book.idBook
    WHERE Order_idOrder = NEW.Order_idOrder
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `customer`
--

CREATE TABLE `customer` (
  `idCustomer` int NOT NULL,
  `login` varchar(20) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `customer`
--

INSERT INTO `customer` (`idCustomer`, `login`, `surname`, `name`, `address`, `phoneNumber`) VALUES
(1, 'dianaka', 'Казанцева', 'Диана', 'ул Воронина д30к3', '+79006003020'),
(2, 'sonya', 'Миклякова', 'София', 'ул Воронина д30к3', '');

--
-- Триггеры `customer`
--
DELIMITER $$
CREATE TRIGGER `before_delete_customer` BEFORE DELETE ON `customer` FOR EACH ROW BEGIN
DECLARE idX INT;
set idX =OLD.idCustomer;
  DELETE FROM composition 
  WHERE composition.Order_idOrder in 
  (select idOrder from `order` where `order`.idCustomer = idX);
  DELETE FROM marcket.order  WHERE idCustomer = idX;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `customer_2`
--

CREATE TABLE `customer_2` (
  `idCustomer` int NOT NULL,
  `login` varchar(20) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `customer_2`
--

INSERT INTO `customer_2` (`idCustomer`, `login`, `surname`, `name`, `address`, `phoneNumber`) VALUES
(1, 'amnyam228', 'Амнямов', 'Амням', 'ул Амняма Великого', '+79112349834');

-- --------------------------------------------------------

--
-- Структура таблицы `games`
--

CREATE TABLE `games` (
  `idGame` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `price` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `games`
--

INSERT INTO `games` (`idGame`, `name`, `description`, `category`, `price`) VALUES
(1, 'SimCity', 'Градостроительный симулятор снова с вами! Создайте город своей мечты', 'Симулятор', '1499.00'),
(2, 'TITANFALL', 'Эта игра перенесет вас во вселенную, где малое противопоставляется большому, природа – индустрии, а человек – машине', 'Шутер', '2299.00'),
(3, 'Battlefield 4', 'Battlefield 4 – это определяющий для жанра, полный экшена боевик, известный своей разрушаемостью, равных которой нет', 'Шутер', '899.40'),
(4, 'The Sims 4', 'В реальности каждому человеку дано прожить лишь одну жизнь. Но с помощью The Sims 4 это ограничение можно снять! Вам решать — где, как и с кем жить, чем заниматься, чем украшать и обустраивать свой дом', 'Симулятор', '15.00'),
(5, 'Dark Souls 2', 'Продолжение знаменитого ролевого экшена вновь заставит игроков пройти через сложнейшие испытания. Dark Souls II предложит нового героя, новую историю и новый мир. Лишь одно неизменно – выжить в мрачной вселенной Dark Souls очень непросто.', 'RPG', '949.00'),
(6, 'The Elder Scrolls V: Skyrim', 'После убийства короля Скайрима империя оказалась на грани катастрофы. Вокруг претендентов на престол сплотились новые союзы, и разгорелся конфликт. К тому же, как предсказывали древние свитки, в мир вернулись жестокие и беспощадные драконы. Теперь будущее Скайрима и всей империи зависит от драконорожденного — человека, в жилах которого течет кровь легендарных существ.', 'RPG', '1399.00'),
(7, 'FIFA 14', 'Достоверный, красивый, эмоциональный футбол! Проверенный временем геймплей FIFA стал ещё лучше благодаря инновациям, поощряющим творческую игру в центре поля и позволяющим задавать её темп.', 'Симулятор', '699.00'),
(8, 'Need for Speed Rivals', 'Забудьте про стандартные режимы игры. Сотрите грань между одиночным и многопользовательским режимом в постоянном соперничестве между гонщиками и полицией. Свободно войдите в мир, в котором ваши друзья уже участвуют в гонках и погонях. ', 'Симулятор', '15.00'),
(9, 'Crysis 3', 'Действие игры разворачивается в 2047 году, а вам предстоит выступить в роли Пророка.', 'Шутер', '1299.00'),
(10, 'Dead Space 3', 'В Dead Space 3 Айзек Кларк и суровый солдат Джон Карвер отправляются в космическое путешествие, чтобы узнать о происхождении некроморфов.', 'Шутер', '499.00');

-- --------------------------------------------------------

--
-- Структура таблицы `logs`
--

CREATE TABLE `logs` (
  `id` int NOT NULL,
  `_table` varchar(50) DEFAULT NULL,
  `operation` varchar(50) DEFAULT NULL,
  `dateTime` datetime DEFAULT NULL,
  `currentUser` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `logs`
--

INSERT INTO `logs` (`id`, `_table`, `operation`, `dateTime`, `currentUser`) VALUES
(1, 'book', 'INSERT', '2025-04-15 10:43:10', 'root@127.0.0.1'),
(2, 'book', 'UPDATE', '2025-04-15 10:43:42', 'root@127.0.0.1'),
(3, 'book', 'DELETE', '2025-04-15 10:44:08', 'root@127.0.0.1'),
(4, 'order', 'UPDATE', '2025-04-15 10:45:40', 'root@127.0.0.1'),
(7, 'order', 'INSERT', '2025-04-15 10:53:50', 'root@127.0.0.1'),
(8, 'order', 'UPDATE', '2025-04-15 10:53:50', 'root@127.0.0.1'),
(10, 'order', 'UPDATE', '2025-04-15 10:54:51', 'root@127.0.0.1'),
(13, 'oredr', 'DELETE', '2025-04-15 10:58:03', 'root@127.0.0.1'),
(14, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(15, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(16, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(17, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(18, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(19, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(20, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(21, 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1'),
(23, 'order', 'INSERT', '2025-04-15 11:41:10', 'root@127.0.0.1'),
(24, 'book', 'UPDATE', '2025-04-15 11:41:29', 'root@127.0.0.1'),
(25, 'book', 'UPDATE', '2025-04-15 11:41:29', 'root@127.0.0.1'),
(28, 'book', 'INSERT', '2025-04-15 11:50:04', 'root@127.0.0.1'),
(29, 'book', 'UPDATE', '2025-04-15 11:59:59', 'root@127.0.0.1'),
(30, 'book', 'INSERT', '2025-04-15 12:01:01', 'root@127.0.0.1'),
(31, 'book', 'UPDATE', '2025-04-16 10:12:04', 'root@127.0.0.1'),
(32, 'book', 'UPDATE', '2025-04-16 10:22:55', 'root@127.0.0.1'),
(33, 'book', 'DELETE', '2025-04-16 10:41:15', 'root@127.0.0.1'),
(34, 'book', 'UPDATE', '2025-04-16 10:55:53', 'root@127.0.0.1'),
(35, 'book', 'INSERT', '2025-04-16 11:19:34', 'root@127.0.0.1'),
(36, 'book', 'INSERT', '2025-04-16 11:20:07', 'root@127.0.0.1'),
(37, 'book', 'INSERT', '2025-04-16 11:25:20', 'root@127.0.0.1'),
(38, 'book', 'DELETE', '2025-04-16 11:25:36', 'root@127.0.0.1'),
(39, 'book', 'DELETE', '2025-04-16 11:25:40', 'root@127.0.0.1'),
(40, 'book', 'UPDATE', '2025-04-16 12:02:08', 'root@127.0.0.1'),
(41, 'book', 'DELETE', '2025-04-17 08:08:44', 'root@127.0.0.1');

-- --------------------------------------------------------

--
-- Структура таблицы `marcket`
--

CREATE TABLE `marcket` (
  `COL 1` varchar(13) DEFAULT NULL,
  `COL 2` varchar(11) DEFAULT NULL,
  `COL 3` varchar(24) DEFAULT NULL,
  `COL 4` varchar(19) DEFAULT NULL,
  `COL 5` varchar(18) DEFAULT NULL,
  `COL 6` varchar(12) DEFAULT NULL,
  `COL 7` varchar(19) DEFAULT NULL,
  `COL 8` varchar(7) DEFAULT NULL,
  `COL 9` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `marcket`
--

INSERT INTO `marcket` (`COL 1`, `COL 2`, `COL 3`, `COL 4`, `COL 5`, `COL 6`, `COL 7`, `COL 8`, `COL 9`) VALUES
('idAuthor', 'surname', 'name', 'country', NULL, NULL, NULL, NULL, NULL),
('1', 'Толстой', 'Алексей', 'Россия', NULL, NULL, NULL, NULL, NULL),
('2', 'Достоевский', 'Мяу', 'Россия', NULL, NULL, NULL, NULL, NULL),
('3', 'Шекспир', 'Уильям', 'Англия', NULL, NULL, NULL, NULL, NULL),
('4', 'Гете', 'Иоганн Вольфганг', 'Германия', NULL, NULL, NULL, NULL, NULL),
('5', 'Бальзак', 'Оноре де', 'Франция', NULL, NULL, NULL, NULL, NULL),
('6', 'Пушкин', 'Александр', 'Россия', NULL, NULL, NULL, NULL, NULL),
('idAuthor', 'surname', 'name', 'country', NULL, NULL, NULL, NULL, NULL),
('1', 'Булгаков', 'Михаил', 'Россия', NULL, NULL, NULL, NULL, NULL),
('2', 'Толстой', 'Лев', 'Россия', NULL, NULL, NULL, NULL, NULL),
('idBook', 'idAuthor', 'title', 'genre', 'price', 'weight', 'page', 'release', 'count'),
('1', '1', 'Война и мир', 'другое', '100.00', '1.000', '1200', '1969', '49'),
('2', '2', 'Преступление и наказание', 'другое', '630.00', '0.900', '800', '1970', '49'),
('3', '3', 'Гамлет', 'другое', '420.00', '0.300', '200', '1971', '50'),
('4', '4', 'Фауст', 'другое', '525.00', '0.400', '300', '1972', '50'),
('5', '5', 'Папа Горьот', 'другое', '5775.00', '0.600', '500', '1973', '50'),
('6', '1', 'Анна Каренина', 'другое', '735.00', '1.000', '900', '1969', '50'),
('7', '2', 'Игрок', 'другое', '1470.00', '0.400', '200', '1973', '50'),
('8', '6', 'Сказка о рыбаке и рыбки', 'другое', '210.00', '0.100', '20', '1975', '50'),
('9', '1', 'Детство', 'другое', '6000.00', '0.123', '56', '1980', '50'),
('10', '2', 'sfsdfsdf', 'другое', '456.00', '1.000', '45', '', '100'),
('Order_idOrder', 'Book_idBook', 'Count', NULL, NULL, NULL, NULL, NULL, NULL),
('1', '1', '9', NULL, NULL, NULL, NULL, NULL, NULL),
('1', '2', '3', NULL, NULL, NULL, NULL, NULL, NULL),
('1', '3', '1', NULL, NULL, NULL, NULL, NULL, NULL),
('2', '3', '3', NULL, NULL, NULL, NULL, NULL, NULL),
('2', '6', '1', NULL, NULL, NULL, NULL, NULL, NULL),
('4', '6', '2', NULL, NULL, NULL, NULL, NULL, NULL),
('4', '7', '2', NULL, NULL, NULL, NULL, NULL, NULL),
('5', '1', '1', NULL, NULL, NULL, NULL, NULL, NULL),
('5', '5', '1', NULL, NULL, NULL, NULL, NULL, NULL),
('idCustomer', 'login', 'surname', 'name', 'address', 'phoneNumber', NULL, NULL, NULL),
('1', 'dianaka', 'Казанцева', 'Диана', 'ул Воронина д30к3', '+79006003020', NULL, NULL, NULL),
('2', 'sonya', 'Миклякова', 'София', 'ул Воронина д30к3', '', NULL, NULL, NULL),
('idCustomer', 'login', 'surname', 'name', 'address', 'phoneNumber', NULL, NULL, NULL),
('1', 'amnyam228', 'Амнямов', 'Амням', 'ул Амняма Великого', '+79112349834', NULL, NULL, NULL),
('id', '_table', 'operation', 'dateTime', 'currentUser', NULL, NULL, NULL, NULL),
('1', 'book', 'INSERT', '2025-04-15 10:43:10', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('2', 'book', 'UPDATE', '2025-04-15 10:43:42', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('3', 'book', 'DELETE', '2025-04-15 10:44:08', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('4', 'order', 'UPDATE', '2025-04-15 10:45:40', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('7', 'order', 'INSERT', '2025-04-15 10:53:50', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('8', 'order', 'UPDATE', '2025-04-15 10:53:50', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('10', 'order', 'UPDATE', '2025-04-15 10:54:51', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('13', 'oredr', 'DELETE', '2025-04-15 10:58:03', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('14', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('15', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('16', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('17', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('18', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('19', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('20', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('21', 'book', 'UPDATE', '2025-04-15 11:18:28', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('23', 'order', 'INSERT', '2025-04-15 11:41:10', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('24', 'book', 'UPDATE', '2025-04-15 11:41:29', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('25', 'book', 'UPDATE', '2025-04-15 11:41:29', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('28', 'book', 'INSERT', '2025-04-15 11:50:04', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('29', 'book', 'UPDATE', '2025-04-15 11:59:59', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('30', 'book', 'INSERT', '2025-04-15 12:01:01', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('31', 'book', 'UPDATE', '2025-04-16 10:12:04', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('32', 'book', 'UPDATE', '2025-04-16 10:22:55', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('33', 'book', 'DELETE', '2025-04-16 10:41:15', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('34', 'book', 'UPDATE', '2025-04-16 10:55:53', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('35', 'book', 'INSERT', '2025-04-16 11:19:34', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('36', 'book', 'INSERT', '2025-04-16 11:20:07', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('37', 'book', 'INSERT', '2025-04-16 11:25:20', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('38', 'book', 'DELETE', '2025-04-16 11:25:36', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('39', 'book', 'DELETE', '2025-04-16 11:25:40', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('40', 'book', 'UPDATE', '2025-04-16 12:02:08', 'root@127.0.0.1', NULL, NULL, NULL, NULL),
('idOrder', 'idCustomer', 'orderDateTime', NULL, NULL, NULL, NULL, NULL, NULL),
('1', '1', '2025-05-11 12:31:00', NULL, NULL, NULL, NULL, NULL, NULL),
('2', '2', '2025-06-16 18:51:21', NULL, NULL, NULL, NULL, NULL, NULL),
('4', '1', '2024-09-28 09:12:34', NULL, NULL, NULL, NULL, NULL, NULL),
('5', '2', '2023-06-26 11:43:12', NULL, NULL, NULL, NULL, NULL, NULL),
('idCustomer', 'login', 'surname', 'name', 'address', 'phoneNumber', 'dateDelition', NULL, NULL),
('4', 'admin228', 'Вепрев', 'Саша', 'ул Мяу', '+83894853905', '2025-04-15 10:04:54', NULL, NULL),
('5', 'gerg', 'egrerg', 'ergrg', 'egerge', 'egeg', '2025-04-15 10:58:03', NULL, NULL),
('4', 'jhyukx', 'khyu', 'huyki', 'kijukju', 'wxxwce', '2025-04-15 10:58:03', NULL, NULL),
('idSupply', 'idBook', 'bookCount', 'supplyDate', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `order`
--

CREATE TABLE `order` (
  `idOrder` int NOT NULL,
  `idCustomer` int NOT NULL,
  `orderDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `order`
--

INSERT INTO `order` (`idOrder`, `idCustomer`, `orderDateTime`) VALUES
(1, 1, '2025-05-11 12:31:00'),
(2, 2, '2025-06-16 18:51:21'),
(4, 1, '2024-09-28 09:12:34'),
(5, 2, '2023-06-26 11:43:12');

--
-- Триггеры `order`
--
DELIMITER $$
CREATE TRIGGER `before_insert_order` BEFORE INSERT ON `order` FOR EACH ROW BEGIN
  SET NEW.orderDateTime = CURRENT_DATE();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_order` AFTER INSERT ON `order` FOR EACH ROW BEGIN
    INSERT INTO logs (_table, operation, dateTime, currentUser)
    VALUES ('order', 'INSERT', NOW(), CURRENT_USER());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_order` AFTER UPDATE ON `order` FOR EACH ROW BEGIN
    INSERT INTO logs (_table, operation, dateTime, currentUser)
    VALUES ('order', 'UPDATE', NOW(), CURRENT_USER());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `remote_customer`
--

CREATE TABLE `remote_customer` (
  `idCustomer` int NOT NULL,
  `login` varchar(20) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL,
  `dateDelition` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `remote_customer`
--

INSERT INTO `remote_customer` (`idCustomer`, `login`, `surname`, `name`, `address`, `phoneNumber`, `dateDelition`) VALUES
(4, 'admin228', 'Вепрев', 'Саша', 'ул Мяу', '+83894853905', '2025-04-15 10:04:54'),
(5, 'gerg', 'egrerg', 'ergrg', 'egerge', 'egeg', '2025-04-15 10:58:03');

-- --------------------------------------------------------

--
-- Структура таблицы `supply`
--

CREATE TABLE `supply` (
  `idSupply` int NOT NULL,
  `idBook` int NOT NULL,
  `bookCount` tinyint NOT NULL,
  `supplyDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `author`
--
ALTER TABLE `author`
  ADD PRIMARY KEY (`idAuthor`),
  ADD UNIQUE KEY `fullName_UNIQUE` (`surname`,`name`);

--
-- Индексы таблицы `author_2`
--
ALTER TABLE `author_2`
  ADD PRIMARY KEY (`idAuthor`);

--
-- Индексы таблицы `book`
--
ALTER TABLE `book`
  ADD PRIMARY KEY (`idBook`),
  ADD KEY `fk_Book_Author_idx` (`idAuthor`);

--
-- Индексы таблицы `composition`
--
ALTER TABLE `composition`
  ADD PRIMARY KEY (`Order_idOrder`,`Book_idBook`),
  ADD KEY `fk_Order_has_Book_Book1_idx` (`Book_idBook`),
  ADD KEY `fk_Order_has_Book_Order1_idx` (`Order_idOrder`);

--
-- Индексы таблицы `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`idCustomer`),
  ADD UNIQUE KEY `login_UNIQUE` (`login`);

--
-- Индексы таблицы `customer_2`
--
ALTER TABLE `customer_2`
  ADD PRIMARY KEY (`idCustomer`),
  ADD UNIQUE KEY `login_UNIQUE` (`login`);

--
-- Индексы таблицы `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`idGame`);

--
-- Индексы таблицы `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`idOrder`),
  ADD KEY `fk_Order_Customer1_idx` (`idCustomer`);

--
-- Индексы таблицы `remote_customer`
--
ALTER TABLE `remote_customer`
  ADD UNIQUE KEY `login_UNIQUE` (`login`);

--
-- Индексы таблицы `supply`
--
ALTER TABLE `supply`
  ADD PRIMARY KEY (`idSupply`),
  ADD KEY `fk_supply_book1_idx` (`idBook`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `author_2`
--
ALTER TABLE `author_2`
  MODIFY `idAuthor` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `customer_2`
--
ALTER TABLE `customer_2`
  MODIFY `idCustomer` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `games`
--
ALTER TABLE `games`
  MODIFY `idGame` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `logs`
--
ALTER TABLE `logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT для таблицы `supply`
--
ALTER TABLE `supply`
  MODIFY `idSupply` int NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `book`
--
ALTER TABLE `book`
  ADD CONSTRAINT `fk_Book_Author` FOREIGN KEY (`idAuthor`) REFERENCES `author` (`idAuthor`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `composition`
--
ALTER TABLE `composition`
  ADD CONSTRAINT `fk_Order_has_Book_Book1` FOREIGN KEY (`Book_idBook`) REFERENCES `book` (`idBook`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Order_has_Book_Order1` FOREIGN KEY (`Order_idOrder`) REFERENCES `order` (`idOrder`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `fk_Order_Customer1` FOREIGN KEY (`idCustomer`) REFERENCES `customer` (`idCustomer`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `supply`
--
ALTER TABLE `supply`
  ADD CONSTRAINT `fk_supply_book1` FOREIGN KEY (`idBook`) REFERENCES `book` (`idBook`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
