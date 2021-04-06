-- Run this script to follow along with the demo.
USE [ABCCompany];
GO



-- Will this syntax work?
CREATE CLUSTERED COLUMNSTORE INDEX CCS_SalesOrder
ON Sales.SalesOrder;
GO






-- Will this work?
CREATE NONCLUSTERED COLUMNSTORE INDEX CS_SalesOrder2
ON Sales.SalesOrder (SalesDate,SalesPerson,SalesAmount);
GO






-- What if we want to add the sales territory column?
DROP INDEX IF EXISTS CS_SalesOrder ON Sales.SalesOrder;
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CS_SalesOrder
ON Sales.SalesOrder (SalesDate,SalesPerson,SalesAmount,SalesTerritory)
--WITH (DROP_EXISTING = ON);
GO






-- What if we want to add the order description?
CREATE NONCLUSTERED COLUMNSTORE INDEX CS_SalesOrder
ON Sales.SalesOrder (SalesDate,SalesPerson,SalesAmount,SalesTerritory,OrderDescription)
WITH (DROP_EXISTING = ON);
GO





-- Rowgroup level information.
SELECT  object_name(i.object_id) AS TableName,   
		i.name AS IndexName,   
		i.type_desc AS IndexType,   
		rg.state_desc AS StateDescription,
		rg.total_rows AS TotalRows,
		rg.trim_reason_desc AS TrimReason
FROM [sys].[indexes] AS i  
JOIN [sys].[dm_db_column_store_row_group_physical_stats] AS rg  
    ON i.object_id = rg.object_id AND i.index_id = rg.index_id;
GO





-- Check how many schedulers we have.
SELECT	scheduler_id AS SchedulerId, 
		cpu_id AS CPUId, 
		status AS CurrentStatus, 
		is_online AS IsOnline
FROM [sys].[dm_os_schedulers]
WHERE status = 'VISIBLE ONLINE'





-- Limit the number of degrees of parallelism.
-- This will override the default server settings.
CREATE NONCLUSTERED COLUMNSTORE INDEX CS_SalesOrder
ON Sales.SalesOrder (SalesDate,SalesPerson,SalesAmount,SalesTerritory)
WITH (MAXDOP = 2, DROP_EXISTING = ON);
GO






-- Rowgroup level information.
SELECT  object_name(i.object_id) AS TableName,   
		i.name AS IndexName,   
		i.type_desc AS IndexType,   
		rg.state_desc AS StateDescription,
		rg.total_rows AS TotalRows,
		rg.trim_reason_desc AS TrimReason
FROM [sys].[indexes] AS i  
JOIN [sys].[dm_db_column_store_row_group_physical_stats] AS rg  
    ON i.object_id = rg.object_id AND i.index_id = rg.index_id;
GO