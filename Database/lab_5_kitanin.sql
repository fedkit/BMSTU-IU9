USE master
GO

---1---

IF DB_ID(N'lab5') IS NOT NULL
	DROP DATABASE lab5
GO

CREATE DATABASE lab5 ON (
	NAME = lab5_dat,
	FILENAME = 'C:\DB\lab5\lab5_dat.mdf',
	SIZE = 20MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
)	
LOG ON (
	NAME = lab5_log,
	FILENAME = 'C:\DB\lab5\lab5_log.ldf',
	SIZE = 10MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)
GO

---2---

USE lab5
GO

IF OBJECT_ID(N'CLIENTS') IS NOT NULL
	DROP TABLE CLIENTS
GO

CREATE TABLE CLIENTS(
	PersonID int PRIMARY KEY NOT NULL, 
	PassportNumber char(10) NOT NULL,
	FirstName varchar(255) NOT NULL,
	Surname varchar(255) NOT NULL, 
	MiddleName varchar(255) NULL,
	PhoneNumber char(11) NULL,
	Email varchar(255) NULL, 
	BirthDate date NOT NULL,
	MemberType tinyint NOT NULL
)

/*INSERT INTO CLIENTS (PersonID, PassportNumber, FirstName, Surname, MiddleName, PhoneNumber, Email, BirthDate, MemberType)
VALUES
	(1, '4512456789', 'Иван',      'Белый',      'Павлович',    '89991234567', 'ivan_sidorov@mail.ru',      '1990-04-15', 1),
	(2, '4523678910', 'Мария',     'Петрова',    'Игоревна',    '89777654001', 'maria.petrova@gmail.com',   '2005-07-08', 2),
	(3, '4534598723', 'Алексей',   'Кузнецов',   'Владимирович','89993451234',  NULL,                       '1978-02-21', 1),
	(4, '4545689312', 'Мария',     'Соколова',   'Олеговна',    '89034567891', 'daria_sokolova223@mail.ru', '1999-11-02', 3),
	(5, '4556987431', 'Никита',    'Воронов',    'Андреевич',   '89214567890',  NULL,                       '2002-03-25', 2),
	(6, '4267812398', 'Анна',      'Кузьмина',   'Михайловна',  '89123457890', 'anna_kuz@mail.ru',          '1998-08-14', 1),
	(7, '4578923145', 'Павел',     'Романов',     NULL,         '89857893412',  NULL,                       '1985-05-30', 2),
	(8, '4589345123', 'Екатерина', 'Миронова',   'Сергеевна',   '89154561234', 'ekm0919@mail.ru',           '1993-09-19', 4),
	(9, '4591456234', 'Максим',    'Галь',       'Олегович',    '89873450123', 'max.fed@gmail.com',         '2001-12-11', 1),
	(10,'4102789345', 'Ольга',     'Алексеева',  'Витальевна',   NULL,         'olga.alekseeva@yandex.ru',  '1986-06-07', 2);

SELECT * FROM CLIENTS
GO*/

---3---

ALTER DATABASE lab5
	ADD FILEGROUP lab5_fg
GO

ALTER DATABASE lab5
	ADD FILE(
		NAME = another_file,
		FILENAME = 'C:\DB\lab5\another_file.ndf',
		SIZE = 10MB,
		MAXSIZE = 100MB,
		FILEGROWTH = 5MB
	) TO FILEGROUP lab5_fg
GO

---4---

ALTER DATABASE lab5
	MODIFY FILEGROUP lab5_fg DEFAULT
GO

---5---

IF OBJECT_ID(N'ROOMS') IS NOT NULL
	DROP TABLE ROOMS 
GO

CREATE TABLE ROOMS(
	RoomID int PRIMARY KEY NOT NULL, 
	RoomName varchar(255) NOT NULL,
	Area int NOT NULL, 
	Floor tinyint NOT NULL,
	Capacity smallint NOT NULL
) 
GO

/*INSERT INTO ROOMS(RoomID, RoomName, Area, Floor, Capacity)
VALUES
	(1, 'Тренажёрный зал',          250, 3, 60),
	(2, 'Кардио-зона',              180, 1, 35),
	(3, 'Зал групповых тренировок', 150, 2, 40),
	(4, 'Зал йоги',                 120, 2, 25),
	(5, 'Боксёрский зал',           200, 1, 30),
	(6, 'Зал кроссфита',            220, 1, 45),
	(7, 'Зал растяжки',             100, 2, 20);

SELECT * FROM ROOMS
GO*/

---6---
DROP TABLE ROOMS
GO

ALTER DATABASE lab5
	MODIFY FILEGROUP [primary] DEFAULT
GO

ALTER DATABASE lab5
	REMOVE FILE another_file
GO

ALTER DATABASE lab5
	REMOVE FILEGROUP lab5_fg
GO

---7---

CREATE SCHEMA lab5_schema
GO

ALTER SCHEMA lab5_schema TRANSFER CLIENTS
GO

IF OBJECT_ID(N'lab5_schema.CLIENTS') IS NOT NULL
    DROP TABLE lab5_schema.CLIENTS
GO

DROP SCHEMA lab5_schema
GO
