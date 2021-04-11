/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Shows how to use INCLUDED Columns to form 
	a covering index. This can be a great performance boost.

****************************************************************/


USE [AdventureWorks2019]
GO

SET NOCOUNT ON

-- Create New Table Empty Table
SELECT *
INTO [Sales].[InclSalesOrderDetail]
FROM [Sales].[SalesOrderDetail]
WHERE 1 = 2
GO

-- Measure the Insert time in New Table
INSERT INTO [Sales].[InclSalesOrderDetail]
([SalesOrderID],[CarrierTrackingNumber],[OrderQty]
,[ProductID],[SpecialOfferID],[UnitPrice]
,[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate])
SELECT	[SalesOrderID],[CarrierTrackingNumber],[OrderQty]
		,[ProductID],[SpecialOfferID],[UnitPrice]
		,[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate]
FROM [Sales].[SalesOrderDetail]
GO

-- Add a column nvarchar
ALTER TABLE [Sales].[InclSalesOrderDetail] 
ADD Col1 NVARCHAR(1000) DEFAULT(REPLICATE('a',1000)) NOT NULL
GO

-- Select statement and distinct (CTRL+M)
SELECT [SalesOrderID],[ProductID],[col1]
FROM [Sales].[InclSalesOrderDetail] sod
WHERE sod.[SalesOrderID] > 40000
		AND sod.[SalesOrderID] < 50000
GO

-- Create Clustered Index
ALTER TABLE [Sales].[InclSalesOrderDetail] 
	ADD CONSTRAINT [PK_InclSalesOrderDetail_SalesOrderDetailID] 
	PRIMARY KEY CLUSTERED 
	([SalesOrderDetailID] ASC
	) ON [PRIMARY]
GO

-- Select statement and distinct (CTRL+M)
SELECT [SalesOrderID],[ProductID],[col1]
FROM [Sales].[InclSalesOrderDetail] sod
WHERE sod.[SalesOrderID] > 40000
		AND sod.[SalesOrderID] < 50000
GO

-- Create Non-Clustered Index
-- This will throw error
CREATE NONCLUSTERED INDEX [IX_InclSalesOrderDetail_Cover] 
	ON [Sales].[InclSalesOrderDetail]
	([SalesOrderID],[ProductID],[col1]) ON [PRIMARY]
GO
-- Create Included-Clustered Index
CREATE NONCLUSTERED INDEX [IX_InclSalesOrderDetail_Included] 
	ON [Sales].[InclSalesOrderDetail]
	([SalesOrderID]) 
	 INCLUDE ([ProductID],[col1])
	 ON [PRIMARY]
GO

-- Select statement (CTRL+M)
SELECT [SalesOrderID],[ProductID],[col1]
FROM [Sales].[InclSalesOrderDetail] sod
WHERE sod.[SalesOrderID] > 40000
		AND sod.[SalesOrderID] < 50000
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Compare performance between Primary Key and Covered Index
-- Select statement (CTRL+M)
SELECT [SalesOrderID],[ProductID],[col1]
FROM [Sales].[InclSalesOrderDetail] sod WITH(INDEX([PK_InclSalesOrderDetail_SalesOrderDetailID]))
WHERE sod.[SalesOrderID] > 40000
		AND sod.[SalesOrderID] < 50000
GO
-- Select statement (CTRL+M)
SELECT [SalesOrderID],[ProductID],[col1]
FROM [Sales].[InclSalesOrderDetail] sod WITH(INDEX([IX_InclSalesOrderDetail_Included]))
WHERE sod.[SalesOrderID] > 40000
		AND sod.[SalesOrderID] < 50000
GO
-------------------------------------------------------------------------------------
-- Clean up
DROP TABLE [Sales].[InclSalesOrderDetail]
GO