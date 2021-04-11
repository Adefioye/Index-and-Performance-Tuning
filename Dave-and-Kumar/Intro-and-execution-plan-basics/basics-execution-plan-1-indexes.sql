USE AdventureWorks2019
GO

-- Build Sample DB
SELECT *
INTO MySalesOrderDetail
FROM [Sales].[SalesOrderDetail]
GO

----------------------------------------------------------------------------------
-- Clustered Index Scan and Clustered Index Seek
----------------------------------------------------------------------------------
-- CTRL+M
-- Build Sample DB
SET STATISTICS IO ON
GO

SELECT *
FROM MySalesOrderDetail
-- logical reads 1494
GO

SELECT *
FROM MySalesOrderDetail
WHERE SalesOrderID = 60726 AND SalesOrderDetailID = 74616
-- logical reads 1494
GO

-- Create Clustered Index
ALTER TABLE MySalesOrderDetail 
ADD CONSTRAINT [PK_MySalesOrderDetail_SalesOrderID_SalesOrderDetailID] 
PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] ASC,
	[SalesOrderDetailID] ASC
)
GO

SELECT *
FROM MySalesOrderDetail
-- logical reads 1501
GO

SELECT *
FROM MySalesOrderDetail
WHERE SalesOrderID = 60726 AND SalesOrderDetailID = 74616
-- logical reads 3
GO

-- Clean up
/*
ALTER TABLE [dbo].[MySalesOrderDetail] 
DROP CONSTRAINT [PK_MySalesOrderDetail_SalesOrderID_SalesOrderDetailID]
GO
*/
SET STATISTICS IO OFF
GO

----------------------------------------------------------------------------------
-- Non-Clustered Index Scan
----------------------------------------------------------------------------------
-- Create a sample non clustered index

CREATE NONCLUSTERED INDEX [IX_MySalesOrderDetail_OrderQty_ProductID] 
ON MySalesOrderDetail
([OrderQty],[ProductID])
GO

SET STATISTICS IO ON
GO

-- Sample Query
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM MySalesOrderDetail
GO

-- Sample Query with Where clause
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM MySalesOrderDetail
WHERE ProductID = 799
GO

-- Method 1: Add OrderQty in WHERE clause
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM MySalesOrderDetail
WHERE ProductID = 799 AND OrderQty > 0 
GO

-- Method 2: Create Index with ProductID as first col
CREATE NONCLUSTERED INDEX [IX_MySalesOrderDetail_ProductID_OrderQty] 
ON MySalesOrderDetail
([ProductID],[OrderQty])
GO

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM MySalesOrderDetail
WHERE ProductID = 799 
GO

-- Clean up
SET STATISTICS IO OFF
GO
/*
DROP INDEX [IX_MySalesOrderDetail_OrderQty_ProductID] ON [dbo].[MySalesOrderDetail]
GO
DROP INDEX [IX_MySalesOrderDetail_ProductID_OrderQty] ON [dbo].[MySalesOrderDetail]
GO 
*/

----------------------------------------------------------------------------------
-- Bookmark Lookup
----------------------------------------------------------------------------------
SET STATISTICS IO ON
GO
-- Sample Query
SELECT	SalesOrderID, SalesOrderDetailID, 
		ProductID, OrderQty,
		SpecialOfferID
FROM MySalesOrderDetail
WHERE ProductID = 789
GO

-- Option 1: Add column to Index
CREATE NONCLUSTERED INDEX [IX_MySalesOrderDetail_ProductID_OrderQty_SpecialOfferID] 
ON MySalesOrderDetail
([ProductID],[OrderQty],[SpecialOfferID])
GO

-- Sample Query (check again)
SELECT	SalesOrderID, SalesOrderDetailID, 
		ProductID, OrderQty,
		SpecialOfferID
FROM MySalesOrderDetail
WHERE ProductID = 789
GO

-- Clean up
DROP INDEX [IX_MySalesOrderDetail_ProductID_OrderQty_SpecialOfferID] 
ON [dbo].[MySalesOrderDetail]
GO

-- Option 2: Add column as Included Column
CREATE NONCLUSTERED INDEX [IX_MySalesOrderDetail_ProductID_OrderQty_SpecialOfferID] 
ON MySalesOrderDetail
([ProductID])
INCLUDE ([OrderQty],[SpecialOfferID])
GO

-- Sample Query
SELECT	SalesOrderID, SalesOrderDetailID, 
		ProductID, OrderQty,
		SpecialOfferID
FROM MySalesOrderDetail
WHERE ProductID = 789
GO

-- Clean up
DROP INDEX [IX_MySalesOrderDetail_ProductID_OrderQty_SpecialOfferID] 
ON [dbo].[MySalesOrderDetail]
GO

SET STATISTICS IO OFF
GO