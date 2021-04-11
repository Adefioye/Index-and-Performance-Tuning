USE AdventureWorks2019
GO

-- Loop Join
SELECT *
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice BETWEEN 1121 AND 1213
GO

-- Merge Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 2.5
GO

-- Hash Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 3
GO

----------------------------------------------------------------------
-- All Loop Join
-- Loop Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice BETWEEN 1121 AND 1213
GO
-- Merge Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER MERGE JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice BETWEEN 1121 AND 1213
GO
-- Hash Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER HASH JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice BETWEEN 1121 AND 1213
GO
----------------------------------------------------------------------
-- All Merge Join
-- Loop Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER LOOP JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 2.5
GO
-- Merge Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 2.5
GO
-- Hash Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER HASH JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 2.5
GO
----------------------------------------------------------------------
-- All Hash Join
-- Loop Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER LOOP JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 3
GO
-- Merge Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER MERGE JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 3
GO
-- Hash Join
SELECT *
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
WHERE sod.UnitPrice < 3
GO