-- Demo script for Analyzing Nonclustered indexes demo.

-- If you are unsure of how to setup AdventureWorksDW2012,
-- please see Joe Sack's course
-- 'SQL Server: Transact-SQL Basic Data Retrieval'

USE [AdventureWorksDW2019];
GO

EXEC sp_help N'FactInternetSales';
GO

-- Just in case fragmentation affects rows/pages
ALTER TABLE [dbo].[FactInternetSales] REBUILD;
GO

-- This checks for the table and if it exists, 
-- drops it.
IF OBJECTPROPERTY (OBJECT_ID (N'dbo.FactInternetSales2')
		, N'IsUserTable') = 1
	DROP TABLE [dbo].[FactInternetSales2];
GO

SELECT [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      ,[PromotionKey]
      ,[CurrencyKey]
      ,[SalesTerritoryKey]
      , CONVERT (INT, 
			SUBSTRING ([SalesOrderNumber], 3, 5) ) 
				AS [SalesOrderNumber]
      ,[SalesOrderLineNumber]
	  ,[RevisionNumber]
      ,[OrderQuantity]
      ,[UnitPrice]
      ,[ExtendedAmount]
      ,[UnitPriceDiscountPct]
      ,[DiscountAmount]
      ,[ProductStandardCost]
      ,[TotalProductCost]
      ,[SalesAmount]
      ,[TaxAmt]
      ,[Freight]
      ,[CarrierTrackingNumber]
      ,[CustomerPONumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
INTO [dbo].[FactInternetSales2]
FROM [dbo].[FactInternetSales];
GO

-- Modify the newly created table to make it 
-- non-nullable (required for a PK)
ALTER TABLE [dbo].[FactInternetSales2]
ALTER COLUMN [SalesOrderNumber] 
	INT NOT NULL;
GO

-- Create the clustered index
ALTER TABLE [dbo].[FactInternetSales2]
ADD CONSTRAINT [FactInternetSales2_PK] 
	PRIMARY KEY CLUSTERED 
		( [SalesOrderNumber] ASC,
		  [SalesOrderLineNumber] ASC );
GO

-- Create the (7) nonclustered indexes
CREATE NONCLUSTERED INDEX [IX_FactIneternetSales2_ShipDateKey] 
ON [dbo].[FactInternetSales2] ([ShipDateKey]); 
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CurrencyKey] 
ON [dbo].[FactInternetSales2] ([CurrencyKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_CustomerKey] 
ON [dbo].[FactInternetSales2] ([CustomerKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_DueDateKey] 
ON [dbo].[FactInternetSales2] ([DueDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_OrderDateKey] 
ON [dbo].[FactInternetSales2] ([OrderDateKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_ProductKey] 
ON [dbo].[FactInternetSales2] ([ProductKey]);
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales2_PromotionKey] 
ON [dbo].[FactInternetSales2] ([PromotionKey]);
GO

EXEC sp_SQLskills_SQL2012_helpindex N'FactInternetSales';
EXEC sp_SQLskills_SQL2012_helpindex N'FactInternetSales2';
GO

-- Only 60,398 rows
SELECT TOP 100 * 
FROM [dbo].[FactInternetSales];

SELECT TOP 100 * 
FROM [dbo].[FactInternetSales2];
GO

SELECT OBJECT_NAME ([si].[object_id]) AS [Table Name] 
	, [si].[name] AS [Index Name]
	, [ps].[index_id] AS [Index ID] 
	, [ps].[alloc_unit_type_desc] AS [Data Structure]
	, [ps].[page_count] AS [Pages]
	, [ps].[record_count] AS [Rows]
	, [ps].[min_record_size_in_bytes] AS [Min Row]
	, [ps].[max_record_size_in_bytes] AS [Max Row]
FROM [sys].[indexes] AS [si]
	CROSS APPLY sys.dm_db_index_physical_stats 
		(DB_ID ()
		, [si].[object_id]
		, NULL
		, NULL
		, N'DETAILED') AS [ps]
WHERE [si].[object_id] = [ps].[object_id]
		AND [si].[index_id] = [ps].[index_id]
		AND [si].[object_id] 
			IN (OBJECT_ID (N'FactInternetSales')
				, OBJECT_ID (N'FactInternetSales2'))
		AND [ps].[index_level] = 0
ORDER BY [Table Name], [Index ID];
GO

-- Compare the total index amount using sp_spaceused
EXEC sp_spaceused N'FactInternetSales';
EXEC sp_spaceused N'FactInternetSales2';
GO

-- This is only worse on much larger tables
-- This is AdentureWorksDW2008 (largely the same structure)
-- Created the same scenario but then greatly increased
-- the number of rows from 60,398 to 30,923,776
USE AdventureWorksDW2008_ModifiedSalesKey
GO

EXEC sp_help N'FactInternetSales';
EXEC sp_help N'FactInternetSales2';
GO

EXEC sp_SQLskills_SQL2012_helpindex N'FactInternetSales';
EXEC sp_SQLskills_SQL2012_helpindex N'FactInternetSales2';
GO

SET STATISTICS TIME ON;
GO

-- Solely running these as two queries so that we can
-- see the time that it takes to execute

SELECT [index_depth] AS [Depth]
    , [index_level] AS [Level]
    , [record_count] AS [Rows]
    , [page_count] AS [Pages]
    , [avg_page_space_used_in_percent] AS [PgPercentFull]
    , [min_record_size_in_bytes] AS [MinLen]
    , [max_record_size_in_bytes] AS [MaxLen]
    , [avg_record_size_in_bytes] AS [AvgLen]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
	, OBJECT_ID (N'FactInternetSales')
	, NULL
	, NULL
	, N'DETAILED');
GO

SELECT [index_depth] AS [Depth]
    , [index_level] AS [Level]
    , [record_count] AS [Rows]
    , [page_count] AS [Pages]
    , [avg_page_space_used_in_percent] AS [PgPercentFull]
    , [min_record_size_in_bytes] AS [MinLen]
    , [max_record_size_in_bytes] AS [MaxLen]
    , [avg_record_size_in_bytes] AS [AvgLen]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
	, OBJECT_ID (N'FactInternetSales2')
	, NULL
	, NULL
	, N'DETAILED');
GO

-- Compare the total index amount using sp_spaceused
EXEC sp_spaceused N'FactInternetSales';
EXEC sp_spaceused N'FactInternetSales2';
GO
