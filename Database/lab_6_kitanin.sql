USE master
GO

-- Отключаем все соединения с базой данных перед удалением
IF DB_ID (N'lab6') IS NOT NULL 
BEGIN
    ALTER DATABASE lab6 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE lab6
END
GO

CREATE DATABASE lab6 ON (
	NAME = lab6_dat,
	FILENAME = 'C:\DB\lab6\lab6_dat.mdf',
	SIZE = 20MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
)	
GO

---1-2---
USE lab6
GO

IF OBJECT_ID(N'CLIENTS') IS NOT NULL
	DROP TABLE CLIENTS
GO

CREATE TABLE CLIENTS (
	PersonID int IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	Age int NOT NULL CHECK (Age >= 14 AND Age <= 110),
	PassportNumber char(10) NOT NULL,
	FirstName varchar(255) NOT NULL,
	Surname varchar(255) NOT NULL, 
	MiddleName varchar(255) NULL,
	PhoneNumber char(11) NULL CHECK (PhoneNumber LIKE '89%'),
	Email varchar(255) NULL CHECK (Email LIKE '%@%.%'), 
	MemberType tinyint NOT NULL CHECK (MemberType >= 1 AND MemberType <= 8) DEFAULT 1,
	RegistrationDate date DEFAULT GETDATE(),
	MemberSinceDays AS (DATEDIFF(DAY, RegistrationDate, GETDATE()))
)
GO

SELECT 
    SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
    @@IDENTITY AS [@@IDENTITY],
    IDENT_CURRENT('CLIENTS') AS [IDENT_CURRENT]
GO

---3---
IF OBJECT_ID(N'WORKOUT') IS NOT NULL
	DROP TABLE WORKOUT 
GO

CREATE TABLE WORKOUT (
	WorkoutID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	Type tinyint NOT NULL CHECK (Type <= 20 AND Type >= 1),
	DateAndTime datetime NOT NULL, 
	Floor tinyint NOT NULL,
	DifficultyLevel tinyint NOT NULL CHECK (DifficultyLevel <= 5 AND DifficultyLevel >= 1)
) 
GO

---4---
-- Сначала удаляем таблицу, которая использует последовательность
IF OBJECT_ID(N'SUBSCRIPTION') IS NOT NULL
    DROP TABLE SUBSCRIPTION;
GO

IF OBJECT_ID(N'SEQ_SubscriptionID') IS NOT NULL
    DROP SEQUENCE SEQ_SubscriptionID
GO

CREATE SEQUENCE SEQ_SubscriptionID
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 1000000000
    NO CYCLE
GO

CREATE TABLE SUBSCRIPTION (
    SubscriptionID int PRIMARY KEY DEFAULT (NEXT VALUE FOR SEQ_SubscriptionID),
    PersonID int NOT NULL,
    StartDate datetime DEFAULT GETDATE(),
    EndDate datetime NOT NULL, 
    Price decimal(10,2) NOT NULL CHECK (Price > 0)
)
GO

---5---
-- Сначала удаляем таблицу EQUIPMENT, которая ссылается на ROOMS
IF OBJECT_ID(N'EQUIPMENT') IS NOT NULL
    DROP TABLE EQUIPMENT
GO

IF OBJECT_ID(N'ROOMS') IS NOT NULL
    DROP TABLE ROOMS
GO

CREATE TABLE ROOMS (
    RoomID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RoomName varchar(255) NOT NULL,
    Area int NOT NULL,
    Floor tinyint NOT NULL CHECK (Floor >= 1 AND Floor < 100),
    Capacity smallint NOT NULL,
    CONSTRAINT AK_RoomName UNIQUE (RoomName)
)
GO

IF OBJECT_ID(N'EQUIPMENT') IS NOT NULL
    DROP TABLE EQUIPMENT
GO

CREATE TABLE EQUIPMENT (
    EquipmentID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RoomID int NOT NULL FOREIGN KEY REFERENCES ROOMS(RoomID),
    PurchaseDate date NOT NULL,
    ManufactureDate date NOT NULL,
    Manufacture varchar(255) NOT NULL,
    Model varchar(255) NOT NULL,
    RoomLocation varchar(255) NOT NULL
)
GO

/* -- Исправленные данные для ROOMS (уникальные названия)
INSERT INTO ROOMS (RoomName, Area, Floor, Capacity) 
VALUES 
    ('Бассейн', 120, 1, 30),
    ('Боксёрский ринг', 35, 2, 10),
    ('Кардио-зона', 75, 2, 25),
    ('Зал единоборств', 50, 3, 20),
    ('Студия пилатес', 30, 4, 12)
GO

-- Исправленные данные для EQUIPMENT (только существующие RoomID)
INSERT INTO EQUIPMENT (RoomID, PurchaseDate, ManufactureDate, Manufacture, Model)
VALUES
    (1, '2023-05-10', '2023-03-15', 'Hammer Strength', 'Bench Press'),
    (2, '2022-11-05', '2022-09-01', 'Life Fitness', 'Treadmill T5'),
    (1, '2023-04-18', '2023-02-20', 'Manduka', 'PRO Lite'),
    (2, '2023-01-22', '2022-12-10', 'Lululemon', 'Reversible Mat'),
    (5, '2022-09-30', '2022-08-01', 'Harlequin', 'Studio Floor'),
    (5, '2023-06-14', '2023-04-05', 'Balanza', 'Sound System X3'),
    (4, '2023-07-01', '2023-05-10', 'Speedo', 'Lane Marker Set'),
    (4, '2022-12-15', '2022-10-22', 'AquaPure', 'Water Filter AP-2'),
    (4, '2023-03-25', '2023-01-30', 'Everlast', 'Pro Style Boxing Ring'),
    (3, '2023-08-12', '2023-07-01', 'Ringside', 'Training Bag Set'),
    (3, '2023-02-28', '2022-12-15', 'Precor', 'Elliptical EFX445'),
    (2, '2023-09-05', '2023-06-20', 'TechnoGym', 'Bike Cycle'),
    (1, '2023-04-05', '2023-02-14', 'Tatami', 'Judо Mat'),
    (5, '2022-10-20', '2022-08-05', 'Fairtex', 'Muay Thai Bags'),
    (2, '2023-05-30', '2023-04-18', 'Balanced Body', 'Reformer Studio'),
    (3, '2023-07-22', '2023-05-01', 'Merrithew', 'SPX Max Mat')
GO

-- Тестирование CASCADE DELETE
BEGIN TRY
    DELETE FROM ROOMS WHERE RoomID = 1
END TRY
BEGIN CATCH
    PRINT 'Ошибка при удалении RoomID = 1: ' + ERROR_MESSAGE()
END CATCH
GO

-- Добавляем CASCADE DELETE
ALTER TABLE EQUIPMENT 
ADD CONSTRAINT FK_EQUIP_ROOMS_CASCADE FOREIGN KEY (RoomID) REFERENCES ROOMS(RoomID)
ON DELETE CASCADE
GO

-- Теперь должно работать
DELETE FROM ROOMS WHERE RoomID = 1
GO

SELECT * FROM ROOMS
SELECT * FROM EQUIPMENT
GO

-- Восстанавливаем данные для следующих тестов
INSERT INTO ROOMS (RoomName, Area, Floor, Capacity) 
VALUES ('Бассейн', 120, 1, 30)
GO

-- Удаляем CASCADE и добавляем SET NULL
ALTER TABLE EQUIPMENT DROP CONSTRAINT FK_EQUIP_ROOMS_CASCADE
GO

ALTER TABLE EQUIPMENT ALTER COLUMN RoomID int NULL
GO

ALTER TABLE EQUIPMENT 
ADD CONSTRAINT FK_EQUIP_ROOMS_SET_NULL 
FOREIGN KEY (RoomID) REFERENCES ROOMS(RoomID)
ON DELETE SET NULL
GO

DELETE FROM ROOMS WHERE RoomID = 3
GO

SELECT * FROM ROOMS
SELECT * FROM EQUIPMENT
GO

-- Восстанавливаем данные для следующего теста
INSERT INTO ROOMS (RoomName, Area, Floor, Capacity) 
VALUES ('Кардио-зона', 75, 2, 25)
GO

-- Обновляем Equipment с NULL RoomID на существующий RoomID
UPDATE EQUIPMENT SET RoomID = 6 WHERE RoomID IS NULL
GO

-- Удаляем SET NULL и добавляем SET DEFAULT
ALTER TABLE EQUIPMENT DROP CONSTRAINT FK_EQUIP_ROOMS_SET_NULL
GO

ALTER TABLE EQUIPMENT 
ADD CONSTRAINT DF_EQUIPMENT_RoomID 
DEFAULT 5 FOR RoomID  
GO

ALTER TABLE EQUIPMENT 
ADD CONSTRAINT FK_EQUIP_ROOMS_SET_DEFAULT 
FOREIGN KEY (RoomID) REFERENCES ROOMS(RoomID)
ON DELETE SET DEFAULT
GO

DELETE FROM ROOMS WHERE RoomID = 4
GO

SELECT * FROM ROOMS
SELECT * FROM EQUIPMENT
GO */