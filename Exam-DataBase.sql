CREATE DATABASE NTB_DB
GO
USE NTB_DB
GO

--CREATE TABLE 
--TABLE Location
CREATE TABLE Location(
LocationID char(6) PRIMARY KEY,
Name nvarchar(50) NOT NULL,
Description nvarchar(100)
);

--CREATE TABLE 
--TABLE Land
CREATE TABLE Land(
LandID int PRIMARY KEY,
Title nvarchar(100) NOT NULL,
LocationID char(6),
Detail nvarchar(1000),
StartDate DATETIME NOT NULL,
EndDate DATETIME NOT NULL,
CONSTRAINT LocationID_FK FOREIGN KEY(LocationID) REFERENCES Location(LocationID)
);

--CREATE TABLE
--TABLE Building
CREATE TABLE Building(
BuildingID int identity,
LandID int,
BuildingType nvarchar(50),
Area int,
Floors int,
Rooms int,
Cost money,
PRIMARY KEY (BuildingID),
CONSTRAINT LandID_FK FOREIGN KEY(LandID) REFERENCES Land(LandID)
);


--INSERT INTO
--Location
INSERT INTO Location(LocationID, Name, Description)
			VALUES  ('112345', 'My Dinh', 'phan lo ban nen'),
					('112346', 'Ba Dinh', 'gan cong vien Thu Le'),
					('112347', 'Hoan Kiem', 'gan ho Guom, pho di bo');
--Land
INSERT INTO Land(LandID, Title, LocationID, Detail, StartDate, EndDate)
		VALUES ('1', 'A', '112345', 'dat tho cu', '2015-5-5', '2020-6-6'),
				('2', 'B', '112346', 'dat nha nuoc', '2018-2-1', '2022-4-1'),
				('3', 'C', '112347', 'dat xay dung', '2020-4-9', '2024-5-10');
--Building
INSERT INTO Building(LandID, BuildingType, Area, Floors, Rooms, Cost)
			VALUES  (1, 'Biet thu', 100, 4, 12, 35000000),
					(2, 'Can ho', 70, 3, 6, 20000000),
					(3, 'Sieu thi', 1000, 3, 40, 100000000);

-- SELECT
SELECT * FROM Location;
SELECT * FROM Land;
SELECT * FROM Building;

-- 4. List all the buildings with a floor area of 100m2 or more.
SELECT *  FROM Building WHERE Area >= 100;

-- 5. List the construction land will be completed before January 2013.
SELECT * FROM Land WHERE EndDate < '2013-01-01';

-- 6. List all buildings to be built in the land of title "My Dinh”
SELECT b.BuildingType
FROM Building b
INNER JOIN Land z ON b.LandID = z.LandID
INNER JOIN Location r ON r.LocationID = z.LocationID
WHERE r.Name = 'My Dinh';

-- 7. Create a view v_Buildings contains the following information (BuildingID, Title, Name,
-- BuildingType, Area, Floors) from table Building, Land and Location.
CREATE VIEW v_Buildings AS
SELECT b.BuildingID, z.Title, r.Name, b.BuildingType, b.Area, b.Floors
FROM Building b
INNER JOIN Land z ON b.LandID = z.LandID
INNER JOIN Location r ON r.LocationID = z.LocationID;
-- TEST
SELECT * FROM v_Buildings;

-- 8. Create a view v_TopBuildings about 5 buildings with the most expensive price per m2.
CREATE VIEW v_TopBuildings AS
SELECT TOP 5 b.BuildingID, b.LandID, b.BuildingType, z.Detail
FROM Building b
INNER JOIN Land z ON z.LandID = b.LandID
ORDER BY b.Cost DESC
-- TEST
SELECT * FROM v_TopBuildings;

-- 9. Create a store called sp_SearchLandByLocation with input parameter is the area code and retrieve planned land for this area.
CREATE PROCEDURE sp_SearchLandByLocation 
	@LocationID NVARCHAR(6) 
AS 
BEGIN
	IF EXISTS (
				SELECT *
				FROM Land z
				WHERE LocationID = @LocationID
	)
	BEGIN
		SELECT *
		FROM Land z
		WHERE LocationID = @LocationID
	END
	ELSE
	BEGIN
		PRINT 'The requested information could not be found'
	END
END;
-- TEST
SELECT * FROM Land
EXEC sp_SearchLandByLocation @LocationID = '100000';
EXEC sp_SearchLandByLocation @LocationID = '123';

-- 10. Create a store called sp_SearchBuidingByLand procedure input parameter is the land code and retrieve the buildings built on that land.
CREATE PROCEDURE sp_SearchBuidingByLand 
	@LandID INT
AS 
BEGIN
	IF EXISTS (
				SELECT b.BuildingID, b.BuildingType
				FROM Building b
				WHERE LandID = @LandID
	)
	BEGIN
		SELECT b.BuildingID, b.BuildingType
		FROM Building b
		WHERE LandID = @LandID
	END
	ELSE
	BEGIN
		PRINT 'The requested information could not be found'
	END
END;
--TEST
SELECT * FROM Building
EXEC sp_SearchBuidingByLand @LandID = '2';
EXEC sp_SearchBuidingByLand @LandID = '6';

-- 11. Create a trigger tg_RemoveLand allows to delete only lands which have not any buildings built on it.
CREATE TRIGGER tg_RemoveLand
ON Land
INSTEAD OF DELETE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Building WHERE LandID IN (SELECT LandID FROM deleted))
    BEGIN
        DELETE FROM Land WHERE LandID IN (SELECT LandID FROM deleted);
    END
    ELSE
    BEGIN
        RAISERROR('Cannot delete lands with buildings built on them.', 16, 1);
    END
END;

-- TEST TRIGGER tg_RemoveLand
SELECT * FROM Land;
DELETE FROM Land WHERE LandID = 1;
DELETE FROM Land WHERE LandID = 4;


