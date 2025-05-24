----1-----
SELECT * FROM Sales.Customer;

----2-----
SELECT * FROM Sales.Customer 
WHERE CompanyName LIKE '%N';

----3----
SELECT c.CustomerID, a.City
FROM Sales.Customer c
JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN Person.Address a ON ca.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

-----4----
SELECT c.CustomerID, sp.CountryRegionCode
FROM Sales.Customer c
JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN Person.Address a ON ca.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode IN ('GB', 'US');

-----5-----
SELECT * FROM Production.Product
ORDER BY Name;

-----6------
SELECT * FROM Production.Product 
WHERE Name LIKE 'A%';

------7-------
SELECT DISTINCT c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID;


------8-------

SELECT DISTINCT c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN Person.Address a ON ca.AddressID = a.AddressID
WHERE a.City = 'London' AND p.Name = 'Mountain-100 Silver, 42';

-------9--------
SELECT CustomerID
FROM Sales.Customer
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader
);


-------10-------
SELECT DISTINCT c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE p.Name = 'Mountain-100 Silver, 42';

--------11--------
SELECT TOP 1 * FROM Sales.SalesOrderHeader 
ORDER BY OrderDate ASC;

---------12--------
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

---------13--------
SELECT SalesOrderID, AVG(OrderQty) AS AvgQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


---------14--------
SELECT SalesOrderID, MIN(OrderQty) AS MinQty, MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


----------15--------
SELECT ManagerID, COUNT(*) AS NumEmployees
FROM HumanResources.Employee
WHERE ManagerID IS NOT NULL
GROUP BY ManagerID;


-----------16--------
SELECT SalesOrderID, SUM(OrderQty) AS TotalQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

------------17-----------
SELECT * 
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


-----------18-----------
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'CA';


-----------19------------
SELECT * 
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

-------20------------
SELECT sp.CountryRegionCode, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY sp.CountryRegionCode;

-------------21-------------
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(*) AS NumOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;

-------------22-------------
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(*) AS NumOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(*) > 3;

-----------23------------
SELECT DISTINCT p.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.SellEndDate IS NOT NULL 
AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

---------24--------------
SELECT e.BusinessEntityID, 
       pe.FirstName AS EmpFirst, pe.LastName AS EmpLast, 
       pm.FirstName AS MgrFirst, pm.LastName AS MgrLast
FROM HumanResources.Employee e
JOIN Person.Person pe ON e.BusinessEntityID = pe.BusinessEntityID
JOIN HumanResources.Employee m ON e.ManagerID = m.BusinessEntityID
JOIN Person.Person pm ON m.BusinessEntityID = pm.BusinessEntityID;


---------------25-------------
SELECT sp.BusinessEntityID, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY sp.BusinessEntityID;

--------------26-------------
SELECT * 
FROM Person.Person 
WHERE FirstName LIKE '%a%';

-------------27-----------
SELECT ManagerID, COUNT(*) AS ReportCount
FROM HumanResources.Employee
WHERE ManagerID IS NOT NULL
GROUP BY ManagerID
HAVING COUNT(*) > 4;

------------28-------------
SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

----------29-------------
SELECT TOP 1 CustomerID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY COUNT(*) DESC;


-----------30----------
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
WHERE pp.PhoneNumber NOT LIKE '%fax%';

-----------31-----------
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Mountain-100 Silver, 42';

-------32------------
SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'FR';

----33----------
SELECT DISTINCT p.Name AS ProductName, pc.Name AS CategoryName
FROM Purchasing.ProductVendor pv
JOIN Production.Product p ON pv.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.'; 

-----34-------
SELECT p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

-----35-------
SELECT p.Name, pi.Quantity AS UnitsInStock
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
WHERE pi.Quantity < 10;

--------36----------
SELECT TOP 10 sp.CountryRegionCode, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY sp.CountryRegionCode
ORDER BY TotalSales DESC;

------37----------
SELECT SalesPersonID, COUNT(*) AS NumOrders
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 1 AND 40 
GROUP BY SalesPersonID;


-------38--------
SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

---------39----------
SELECT p.Name, SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;


----------40------------
SELECT pv.BusinessEntityID AS SupplierID, COUNT(DISTINCT pv.ProductID) AS ProductsOffered
FROM Purchasing.ProductVendor pv
GROUP BY pv.BusinessEntityID;

-----------41------------
SELECT TOP 10 soh.CustomerID, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.SalesOrderHeader soh
GROUP BY soh.CustomerID
ORDER BY TotalSpent DESC;


----------42-----------
SELECT SUM(TotalDue) AS TotalCompanyRevenue
FROM Sales.SalesOrderHeader;









  
