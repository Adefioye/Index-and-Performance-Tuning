/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Main Query window for this module. Spans the usage of
	Missing Index, UnUsed Index, Duplicate Index

****************************************************************/


USE [AdventureWorks2019]
GO

-- Create New Table Empty Table
SELECT *
INTO [Sales].[MainSalesOrderDetail]
FROM [Sales].[SalesOrderDetail]
WHERE 1 = 2
GO

-- Measure the Insert time in New Table
INSERT INTO [Sales].[MainSalesOrderDetail]
([SalesOrderID],[CarrierTrackingNumber],[OrderQty]
,[ProductID],[SpecialOfferID],[UnitPrice]
,[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate])
SELECT	[SalesOrderID],[CarrierTrackingNumber],[OrderQty]
		,[ProductID],[SpecialOfferID],[UnitPrice]
		,[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate]
FROM [Sales].[SalesOrderDetail]
GO

----------------------------------------------------------------------------------
-- Duplicate Index Creation
-- Create Non-Clustered Index
CREATE NONCLUSTERED INDEX [IX_NewSalesOrderDetail_CarrierTrackingNumber] 
	ON [Sales].[MainSalesOrderDetail]
	([CarrierTrackingNumber] ASC) ON [PRIMARY]
GO
-- Create Non-Clustered Index
CREATE NONCLUSTERED INDEX [IX_NewSalesOrderDetail_CarrierTrackingNumber1] 
	ON [Sales].[MainSalesOrderDetail]
	([CarrierTrackingNumber] ASC) ON [PRIMARY]
GO

----------------------------------------------------------------------------------
-- Run Duplicate Index Script and Identify Duplicate Index
----------------------------------------------------------------------------------
-- Clean up the Duplicate
DROP INDEX [IX_NewSalesOrderDetail_CarrierTrackingNumber1] 
ON [Sales].[MainSalesOrderDetail]
GO


----------------------------------------------------------------------------------
-- CTRL + M
-- Run following query

SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty]
FROM [Sales].[MainSalesOrderDetail]
WHERE [ProductID] = 717
GO
----------------------------------------------------------------------------------
-- Run Missing Index Script and Identify Missing Index
----------------------------------------------------------------------------------
-- Create Missing Index
CREATE INDEX [IX_MainSalesOrderDetail_ProductID] 
ON [MyAdventureWorks].[Sales].[MainSalesOrderDetail] ([ProductID]) 
INCLUDE ([SalesOrderID], [CarrierTrackingNumber], [OrderQty])
GO

-- Running Missing Index will not bring Missing index again in query
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Run Unused Index Script and Identify Unused Index
----------------------------------------------------------------------------------
-- Drop Unused Index
DROP INDEX [IX_NewSalesOrderDetail_CarrierTrackingNumber] ON [Sales].[MainSalesOrderDetail]
GO

-- Running Unused Index will not bring Unused index again in query
----------------------------------------------------------------------------------
-- Clean up
DROP TABLE [Sales].[MainSalesOrderDetail]
GO