USE lab6
GO

---1---
DELETE FROM CLIENTS
GO

INSERT INTO CLIENTS (Age, PassportNumber, FirstName, Surname, MiddleName, 
					 PhoneNumber, Email, MemberType, RegistrationDate) VALUES
	(25, '4510123456', 'Иван', 'Иванов', 'Иванович', '89123456789', 'ivanov@mail.ru', 1, '2023-01-15'),
	(30, '4511123456', 'Мария', 'Петрова', 'Сергеевна', '89123456780', 'petrova@gmail.com', 2, '2022-02-20'),
	(22, '4512123456', 'Алексей', 'Сидоров', 'Алексеевич', '89123456781', 'sidorov@yandex.ru', 1, '2023-03-10'),
	(35, '4513123456', 'Елена', 'Кузнецова', 'Владимировна', '89123456782', 'kuznetsova@mail.ru', 3, '2022-01-05'),
	(28, '4514123456', 'Дмитрий', 'Смирнов', 'Петрович', '89123456783', 'smirnov@gmail.com', 1, '2023-04-18'),
	(40, '4515123456', 'Ольга', 'Васильева', NULL, '89123456784', 'vasileva@yandex.ru', 4, '2022-12-01'),
	(19, '4516123456', 'Сергей', 'Попов', 'Александрович', '89123456785', 'popov@mail.ru', 1, '2023-05-22'),
	(32, '4517123456', 'Анна', 'Новикова', 'Дмитриевна', '89123456786', 'novikova@gmail.com', 2, '2023-03-30'),
	(27, '4518123456', 'Павел', 'Федоров', NULL, '89123456787', 'fedorov@yandex.ru', 1, '2023-06-10'),
	(45, '4519123456', 'Наталья', 'Морозова', 'Игоревна', '89123456788', 'morozova@mail.ru', 5, '2022-11-15'),
	(23, '4520123456', 'Артем', 'Волков', 'Сергеевич', '89123456790', 'volkov@gmail.com', 1, '2023-07-05'),
	(38, '4521123456', 'Юлия', 'Алексеева', 'Борисовна', '89123456791', 'alekseeva@yandex.ru', 3, '2022-02-28'),
	(29, '4522123456', 'Кирилл', 'Лебедев', 'Олегович', '89123456792', 'lebedev@mail.ru', 1, '2022-08-12'),
	(33, '4523123456', 'Татьяна', 'Семенова', 'Викторовна', '89123456793', 'semenova@gmail.com', 2, '2023-04-05'),
	(26, '4524123456', 'Максим', 'Егоров', 'Вадимович', '89123456794', 'egorov@yandex.ru', 1, '2023-09-20'),
	(42, '4525123456', 'Ирина', 'Павлова', NULL, '89123456795', 'pavlova@mail.ru', 6, '2022-10-10'),
	(31, '4526123456', 'Андрей', 'Козлов', 'Валерьевич', '89123456796', 'kozlov@gmail.com', 1, '2023-10-15'),
	(36, '4527123456', 'Светлана', 'Орлова', NULL, '89123456797', 'orlova@yandex.ru', 4, '2023-01-25'),
	(24, '4528123456', 'Владимир', 'Андреев', 'Михайлович', '89123456798', 'andreev@mail.ru', 1, '2023-11-08'),
	(39, '4529123456', 'Екатерина', 'Захарова', 'Сергеевна', '89123456799', 'zaharova@gmail.com', 7, '2022-09-30');
GO

IF OBJECT_ID(N'CLIENTS_VIEW') IS NOT NULL
	DROP VIEW CLIENTS_VIEW
GO

CREATE VIEW CLIENTS_VIEW AS
	SELECT * FROM CLIENTS
	WHERE RegistrationDate >= '2023-01-01'
	WITH CHECK OPTION
GO

INSERT INTO CLIENTS_VIEW (Age, PassportNumber, FirstName, Surname, MiddleName, 
					      PhoneNumber, Email, MemberType, RegistrationDate)
	VALUES (65, '4510123456', 'Иван', 'Иванов', 'Иванович', '89123456789', 'ivanov@mail.ru', 1, '2023-01-15')

/*INSERT INTO CLIENTS_VIEW (Age, FirstName, Surname, MiddleName, PhoneNumber, Email, RegistrationDate)
	VALUES (69, '4529123456', 'Екатерина', 'Захарова', 'Сергеевна', '89123456799', 'zaharova@gmail.com', 7, '2022-09-30')*/

SELECT * FROM CLIENTS_VIEW
GO


---2---
DELETE FROM EQUIPMENT
GO

DELETE FROM ROOMS
GO

DBCC CHECKIDENT ('ROOMS', RESEED, 0)
GO

INSERT INTO ROOMS(RoomName, Area, Floor, Capacity) VALUES 
    ('Бассейн', 120, 1, 30),
    ('Боксёрский ринг', 35, 2, 10),
    ('Кардио-зона', 75, 2, 25),
    ('Зал единоборств', 50, 3, 20),
    ('Студия пилатес', 30, 4, 12)
GO

INSERT INTO EQUIPMENT(RoomID, PurchaseDate, ManufactureDate, Manufacture, Model, RoomLocation) VALUES
    (1, '2023-05-10', '2023-03-15', 'Hammer Strength', 'Bench Press', 'Бассейн'),
    (2, '2022-11-05', '2022-09-01', 'Life Fitness', 'Treadmill T5', 'Боксёрский ринг'),
    (1, '2023-04-18', '2023-02-20', 'Manduka', 'PRO Lite', 'Бассейн'),
    (2, '2023-01-22', '2022-12-10', 'Lululemon', 'Reversible Mat', 'Боксёрский ринг'),
    (5, '2022-09-30', '2022-08-01', 'Harlequin', 'Studio Floor', 'Студия пилатес'),
    (5, '2023-06-14', '2023-04-05', 'Balanza', 'Sound System X3', 'Студия пилатес'),
    (4, '2023-07-01', '2023-05-10', 'Speedo', 'Lane Marker Set', 'Зал единоборств'),
    (4, '2022-12-15', '2022-10-22', 'AquaPure', 'Water Filter AP-2', 'Зал единоборств'),
    (4, '2023-03-25', '2023-01-30', 'Everlast', 'Pro Style Boxing Ring', 'Зал единоборств'),
    (3, '2023-08-12', '2023-07-01', 'Ringside', 'Training Bag Set', 'Кардио-зона'),
    (3, '2023-02-28', '2022-12-15', 'Precor', 'Elliptical EFX445', 'Кардио-зона'),
    (2, '2023-09-05', '2023-06-20', 'TechnoGym', 'Bike Cycle', 'Боксёрский ринг'),
    (1, '2023-04-05', '2023-02-14', 'Tatami', 'Judо Mat', 'Бассейн'),
    (5, '2022-10-20', '2022-08-05', 'Fairtex', 'Muay Thai Bags', 'Студия пилатес'),
    (2, '2023-05-30', '2023-04-18', 'Balanced Body', 'Reformer Studio', 'Боксёрский ринг'),
    (3, '2023-07-22', '2023-05-01', 'Merrithew', 'SPX Max Mat', 'Кардио-зона')
GO

IF OBJECT_ID(N'ROOMS_EQUIPMENT_VIEW') IS NOT NULL
	DROP VIEW ROOMS_EQUIPMENT_VIEW
GO

CREATE VIEW ROOMS_EQUIPMENT_VIEW AS
	SELECT 
		r.RoomID,
		r.RoomName,
		r.Area,
		r.Floor,
		r.Capacity,
		e.EquipmentID,
		e.PurchaseDate,
		e.ManufactureDate,
		e.Manufacture,
		e.Model
	FROM ROOMS AS r INNER JOIN EQUIPMENT AS e ON r.RoomID = e.RoomID
GO

SELECT * FROM ROOMS_EQUIPMENT_VIEW

---3---
DROP INDEX IF EXISTS CLIENT_IDX ON CLIENTS
GO

CREATE INDEX CLIENT_IDX ON CLIENTS (Surname, FirstName, MiddleName)
	INCLUDE (PhoneNumber, Email)
GO

SELECT FirstName, Surname, MiddleName, PhoneNumber, Email FROM CLIENTS 
WHERE Surname = 'Андреев' AND FirstName = 'Владимир' 

---4---
IF OBJECT_ID(N'CLIENTS_IDX_VIEW') IS NOT NULL
    DROP VIEW CLIENTS_IDX_VIEW
GO

CREATE VIEW CLIENTS_IDX_VIEW WITH SCHEMABINDING AS
    SELECT Age, FirstName, Surname, MiddleName, PhoneNumber, Email 
    FROM dbo.CLIENTS
    WHERE Email LIKE '%yandex%'
GO

CREATE UNIQUE CLUSTERED INDEX CIV_IDX 
    ON CLIENTS_IDX_VIEW(Surname, FirstName, MiddleName)
GO

SELECT * FROM CLIENTS_IDX_VIEW
GO