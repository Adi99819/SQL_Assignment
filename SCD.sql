CREATE TABLE DimCustomer (
    CustomerID INT,
    Name VARCHAR(100),
    City VARCHAR(100),
    PreviousCity VARCHAR(100),    
    EffectiveDate DATE,            
    ExpiryDate DATE,               
    CurrentFlag CHAR(1),         
    Version INT,                  
    PRIMARY KEY (CustomerID, EffectiveDate)
);

CREATE TABLE StagingCustomer (
    CustomerID INT,
    Name VARCHAR(100),
    City VARCHAR(100)
);

--SCD Type 0----
DELIMITER $$
CREATE PROCEDURE SCD_Type_0()
BEGIN
    
    INSERT INTO DimCustomer (CustomerID, Name, City)
    SELECT s.CustomerID, s.Name, s.City
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;

--SCD Type 1-----
DELIMITER $$
CREATE PROCEDURE SCD_Type_1()
BEGIN
    -- Update existing records
    UPDATE DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    SET d.Name = s.Name, d.City = s.City;

    -- Insert new records
    INSERT INTO DimCustomer (CustomerID, Name, City)
    SELECT s.CustomerID, s.Name, s.City
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;

--SCD Type 2-------
DELIMITER $$
CREATE PROCEDURE SCD_Type_2()
BEGIN
    DECLARE today DATE;
    SET today = CURDATE();

    
    UPDATE DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    SET d.ExpiryDate = today - INTERVAL 1 DAY,
        d.CurrentFlag = 'N'
    WHERE d.City != s.City AND d.CurrentFlag = 'Y';

    
    INSERT INTO DimCustomer (CustomerID, Name, City, EffectiveDate, ExpiryDate, CurrentFlag)
    SELECT s.CustomerID, s.Name, s.City, today, '9999-12-31', 'Y'
    FROM StagingCustomer s
    JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.City != s.City AND d.CurrentFlag = 'Y';

    
    INSERT INTO DimCustomer (CustomerID, Name, City, EffectiveDate, ExpiryDate, CurrentFlag)
    SELECT s.CustomerID, s.Name, s.City, today, '9999-12-31', 'Y'
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;

--SCD Type 3---------

DELIMITER $$
CREATE PROCEDURE SCD_Type_3()
BEGIN
    UPDATE DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    SET d.PreviousCity = d.City,
        d.City = s.City
    WHERE d.City != s.City;

    
    INSERT INTO DimCustomer (CustomerID, Name, City, PreviousCity)
    SELECT s.CustomerID, s.Name, s.City, NULL
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;

--SCD Type 4-------
-- History Table
CREATE TABLE CustomerHistory (
    CustomerID INT,
    Name VARCHAR(100),
    City VARCHAR(100),
    ChangeDate DATE
);

DELIMITER $$
CREATE PROCEDURE SCD_Type_4()
BEGIN
    
    INSERT INTO CustomerHistory (CustomerID, Name, City, ChangeDate)
    SELECT d.CustomerID, d.Name, d.City, CURDATE()
    FROM DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    WHERE d.City != s.City;

   
    UPDATE DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    SET d.Name = s.Name, d.City = s.City;

    
    INSERT INTO DimCustomer (CustomerID, Name, City)
    SELECT s.CustomerID, s.Name, s.City
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;

--SCD Type 6--------
DELIMITER $$
CREATE PROCEDURE SCD_Type_6()
BEGIN
    DECLARE today DATE;
    SET today = CURDATE();

    
    UPDATE DimCustomer d
    JOIN StagingCustomer s ON d.CustomerID = s.CustomerID
    SET d.ExpiryDate = today - INTERVAL 1 DAY,
        d.CurrentFlag = 'N'
    WHERE d.City != s.City AND d.CurrentFlag = 'Y';

    
    INSERT INTO DimCustomer (CustomerID, Name, City, PreviousCity, EffectiveDate, ExpiryDate, CurrentFlag, Version)
    SELECT s.CustomerID, s.Name, s.City, d.City, today, '9999-12-31', 'Y', d.Version + 1
    FROM StagingCustomer s
    JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.City != s.City AND d.CurrentFlag = 'Y';

    
    INSERT INTO DimCustomer (CustomerID, Name, City, PreviousCity, EffectiveDate, ExpiryDate, CurrentFlag, Version)
    SELECT s.CustomerID, s.Name, s.City, NULL, today, '9999-12-31', 'Y', 1
    FROM StagingCustomer s
    LEFT JOIN DimCustomer d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END$$
DELIMITER ;







