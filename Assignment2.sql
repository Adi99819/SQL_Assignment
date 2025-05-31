----- InsertOrderDetails Procedure ---------

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    DECLARE @StockQty INT, @ReorderLevel INT;

    IF @UnitPrice IS NULL
    BEGIN
        SELECT @UnitPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;
    END

    
    SELECT @StockQty = Quantity, @ReorderLevel = ReorderPoint
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    IF @StockQty IS NULL
    BEGIN
        PRINT 'Failed to place the order. Product not found in inventory.';
        RETURN;
    END

    IF @StockQty < @Quantity
    BEGIN
        PRINT 'Insufficient stock. Order not placed.';
        RETURN;
    END

    
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    
    SELECT @StockQty = Quantity FROM Production.ProductInventory WHERE ProductID = @ProductID;

    IF @StockQty < @ReorderLevel
    BEGIN
        PRINT 'Warning: Quantity in stock has dropped below Reorder Level.';
    END
END;


------------ UpdateOrderDetails Procedure ---------------

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
  
    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'OrderID or ProductID does not exist.';
        RETURN;
    END

    DECLARE @OldQuantity INT;

    
    SELECT @OldQuantity = OrderQty
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    
    UPDATE Sales.SalesOrderDetail
    SET 
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        OrderQty = ISNULL(@Quantity, OrderQty),
        UnitPriceDiscount = ISNULL(@Discount, UnitPriceDiscount)
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

   
    IF @Quantity IS NOT NULL AND @OldQuantity IS NOT NULL
    BEGIN
        DECLARE @CurrentQty INT;
        SET @CurrentQty = @OldQuantity - @Quantity;

        
        UPDATE Production.ProductInventory
        SET Quantity = Quantity + @CurrentQty
        WHERE ProductID = @ProductID;
    END

    PRINT 'Order detail updated successfully.';
END;


---------------- GetOrderDetails Procedure ---------------

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist';
        RETURN 1;
    END

    SELECT *
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;


----------------- DeleteOrderDetails Procedure ---------------------------

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    -- Validate if the OrderID and ProductID exist in that combination
    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Invalid parameters: No such OrderID and ProductID combination found.';
        RETURN -1;
    END

    -- Delete the record
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail deleted successfully.';
END;

---------------------- Views -----------------------------------

CREATE VIEW vwCustomerOrders AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;


CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate = CAST(GETDATE() - 1 AS DATE);  

CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0;



----------------------- Triggers --------------------------------


CREATE TRIGGER trg_DeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE od
    FROM [Order Details] od
    INNER JOIN deleted d ON od.OrderID = d.OrderID;

    DELETE o
    FROM Orders o
    INNER JOIN deleted d ON o.OrderID = d.OrderID;

    PRINT 'Order and related order details deleted successfully.';
END;


CREATE TRIGGER trg_CheckStockBeforeInsert
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @Stock INT;

    SELECT @ProductID = ProductID, @Quantity = Quantity FROM inserted;

    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @Stock >= @Quantity
    BEGIN
        -- Insert the order detail
        INSERT INTO [Order Details]
        SELECT * FROM inserted;

        -- Deduct stock
        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;

        PRINT 'Order placed and stock updated.';
    END
    ELSE
    BEGIN
        PRINT 'Order could not be placed due to insufficient stock.';
    END
END;


