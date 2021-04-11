USE AdventureWorks2019
GO

  /**********************************/
 /***   Order of Tables No Hint  ***/
/**********************************/

-- Query 1
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 6
GO
-- Query 2
SELECT *
FROM Production.Product p
INNER JOIN Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 6
GO

  /**********************************/
 /***  Order of Tables With Hint ***/
/**********************************/

-- Query 1
SELECT *
FROM Sales.SalesOrderDetail sod
INNER HASH JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 6
GO
-- Query 2
SELECT *
FROM Production.Product p
INNER HASH JOIN Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 6
GO


  /************************************/
 /*** Order of Tables FORCED Hint ****/
/************************************/

-- Option 1
SELECT p.ProductID
FROM [Production].[Product] p
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
INNER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
GO
-- Option 2
SELECT p.ProductID
FROM [Production].[Product] p
INNER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
OPTION (FORCE ORDER);
GO
-- Option 3
SELECT p.ProductID
FROM [Production].[WorkOrder] wo
INNER JOIN [Production].[Product] p ON p.ProductID = wo.ProductID
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
OPTION (FORCE ORDER);
GO