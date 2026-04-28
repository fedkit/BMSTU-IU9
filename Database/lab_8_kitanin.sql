USE master
GO

IF DB_ID(N'lab8') IS NOT NULL
	DROP DATABASE lab8
GO

CREATE DATABASE lab8 ON(
	NAME = lab8_dat,
	FILENAME = 'C:\DB\lab8\lab8_dat.mdf',
	SIZE = 20MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
)	
GO

USE lab8
GO

IF OBJECT_ID(N'SUBSCRIPTION') IS NOT NULL
	DROP TABLE SUBSCRIPTION
GO

CREATE TABLE SUBSCRIPTION(
    SubscriptionID int PRIMARY KEY NOT NULL,
    Type tinyint NOT NULL,
    PassportNumber char(10) NULL,
	StartDate date DEFAULT GETDATE(),
    EndDate date NOT NULL,
    Price decimal(10,2) NOT NULL CHECK (Price > 0)
)
GO

INSERT INTO SUBSCRIPTION (SubscriptionID, Type, PassportNumber, StartDate, EndDate, Price) VALUES
	(1, 1, '4501123456', '2025-01-01', '2025-02-01', 2500.00),
	(2, 5, '4502987654', '2025-01-10', '2025-03-10', 5500.00),
	(3, 3, '4503345678', '2025-02-01', '2025-05-01', 1200.00),
	(4, 1, '4504123987', '2025-02-15', '2025-03-15', 2743.50),
	(5, 2, '4505567890', '2025-03-01', '2025-06-01', 800.00),
	(6, 1, '4506234578', '2025-03-20', '2025-04-20', 293.90),
	(7, 3, '4507123499', '2025-04-01', '2025-07-01', 2500.00),
	(8, 2, '4508456123', '2025-04-15', '2025-07-15', 1200.00),
	(9, 4, '4509345671', '2025-05-01', '2025-06-01', 2500.00),
	(10, 4, '4509987612', '2025-05-20', '2025-08-20', 2500.00),
	(11, 1, '4501789456', '2025-06-01', '2025-07-01', 1200.00),
	(12, 2, '4502678945', '2025-06-15', '2025-09-15', 2342.74),
	(13, 5, '4503567894', '2025-07-01', '2025-10-01', 5500.00),
	(14, 5, '4504456789', '2025-07-20', '2025-10-20', 5500.00),
	(15, 1, '4505345698', '2025-08-01', '2025-09-01', 1200.50)
GO

---1---
IF OBJECT_ID(N'get_days') IS NOT NULL
	DROP PROCEDURE get_days
GO

CREATE PROCEDURE get_days
	@currently_cursor CURSOR VARYING OUTPUT
AS
	SET @currently_cursor = CURSOR
	FORWARD_ONLY STATIC FOR
		SELECT SubscriptionID, DATEDIFF(DAY, StartDate, EndDate) + 1 AS Days FROM SUBSCRIPTION
	OPEN @currently_cursor
GO

/*DECLARE @SubscriptionID INT, @Days INT

DECLARE @MyCursor CURSOR
EXEC get_days @currently_cursor = @MyCursor OUTPUT

FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @SubscriptionID AS SubscriptionID, @Days AS Days
    FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days
END

CLOSE @MyCursor
DEALLOCATE @MyCursor*/

---2---
IF OBJECT_ID(N'ñost_per_day') IS NOT NULL
    DROP FUNCTION ñost_per_day
GO

CREATE FUNCTION ñost_per_day(@Price decimal(10,2), @Days int) RETURNS decimal(10,2) AS
BEGIN
    RETURN( 
		CASE WHEN @Days > 0 THEN 
			@Price / @Days 
		ELSE 
			0 
		END
	)
END
GO

IF OBJECT_ID(N'get_days_with_cost') IS NOT NULL
    DROP PROCEDURE get_days_with_cost
GO

CREATE PROCEDURE get_days_with_cost
    @currently_cursor CURSOR VARYING OUTPUT AS
BEGIN
    SET @currently_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
        SELECT SubscriptionID, DATEDIFF(DAY, StartDate, EndDate) + 1 AS Days, 
			   dbo.ñost_per_day(Price, DATEDIFF(DAY, StartDate, EndDate) + 1) AS CostPerDay
        FROM SUBSCRIPTION
    OPEN @currently_cursor
END
GO

/*DECLARE @SubscriptionID INT, @Days INT, @CostPerDay decimal(10,2)
DECLARE @MyCursor CURSOR
EXEC get_days_with_cost @currently_cursor = @MyCursor OUTPUT

FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @SubscriptionID AS SubscriptionID, @Days AS Days, @CostPerDay AS CostPerDay
    FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay
END

CLOSE @MyCursor
DEALLOCATE @MyCursor*/

---3---
IF OBJECT_ID(N'is_expensive') IS NOT NULL
    DROP FUNCTION is_expensive
GO

CREATE FUNCTION is_expensive(@CostPerDay decimal(10,2)) RETURNS BIT AS
BEGIN
    RETURN( 
		CASE WHEN @CostPerDay > 50 THEN 
			1 
		ELSE  
			0 
		END
	)
END
GO

IF OBJECT_ID(N'expensive_subscriptions') IS NOT NULL
    DROP PROCEDURE expensive_subscriptions
GO

CREATE PROCEDURE expensive_subscriptions
AS
BEGIN
    DECLARE @SubscriptionID INT, @Days INT, @CostPerDay decimal(10,2)
    DECLARE @MyCursor CURSOR

    EXEC get_days_with_cost @currently_cursor = @MyCursor OUTPUT

    FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.is_expensive(@CostPerDay) = 1
            PRINT 'Ïîäïèñêà ñ id ' + CAST(@SubscriptionID AS VARCHAR(10)) + ' äîðîãàÿ'

        FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay
    END

    CLOSE @MyCursor
    DEALLOCATE @MyCursor
END
GO

EXEC expensive_subscriptions
GO

---4---
IF OBJECT_ID(N'subscription_with_cost') IS NOT NULL
    DROP FUNCTION subscription_with_cost
GO

CREATE FUNCTION subscription_with_cost() RETURNS TABLE AS
	RETURN(
		SELECT SubscriptionID, DATEDIFF(DAY, StartDate, EndDate) + 1 AS Days,
			   dbo.ñost_per_day(Price, DATEDIFF(DAY, StartDate, EndDate) + 1) AS CostPerDay
		FROM SUBSCRIPTION
	)
GO

IF OBJECT_ID(N'subscription_with_cost_2') IS NOT NULL
    DROP FUNCTION subscription_with_cost_2
GO

CREATE FUNCTION subscription_with_cost_2()
	RETURNS @result TABLE (
		SubscriptionID INT,
		Days INT,
		CostPerDay DECIMAL(10,2)
	) AS
BEGIN
INSERT INTO @result
SELECT SubscriptionID, DATEDIFF(DAY, StartDate, EndDate) + 1 AS Days, 
		   dbo.ñost_per_day(Price, DATEDIFF(DAY, StartDate, EndDate) + 1) AS CostPerDay FROM SUBSCRIPTION
    RETURN
END
GO

IF OBJECT_ID(N'get_days_with_cost2') IS NOT NULL
    DROP PROCEDURE get_days_with_cost2
GO

CREATE PROCEDURE get_days_with_cost2
	@currently_cursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @currently_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
        SELECT SubscriptionID, Days, CostPerDay
        FROM subscription_with_cost_2()
    OPEN @currently_cursor
END
GO

DECLARE @MyCursor CURSOR
EXEC get_days_with_cost2 @currently_cursor = @MyCursor OUTPUT

DECLARE @SubscriptionID INT, @Days INT, @CostPerDay decimal(10,2)

FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @SubscriptionID AS SubscriptionID, @Days AS Days, @CostPerDay AS CostPerDay
    FETCH NEXT FROM @MyCursor INTO @SubscriptionID, @Days, @CostPerDay
END

CLOSE @MyCursor
DEALLOCATE @MyCursor