-- Run this script to follow along with the demo.
USE [ABCCompany];
GO




-- Let's turn on the actual execution plan.
SET STATISTICS IO ON;

SELECT SUM(SalesAmount) AS SalesAmount,
		YEAR(SalesDate) AS SalesYear
FROM Sales.SalesOrder
WHERE SalesDate >= '20190101' AND SalesDate <= '20191231'
GROUP BY YEAR(SalesDate);
GO




-- Information about our segments.
SELECT OBJECT_NAME(i.OBJECT_ID) AS TableName,
		i.[Name] AS IndexName,
		c.[Name] AS ColumnName,
		se.segment_id AS SegmentId,
		se.row_count AS SegmentRowCount,
		se.min_data_id AS MinRowValue,
		se.max_data_id AS MaxRowValue
FROM [sys].[column_store_segments] se
INNER JOIN [sys].[partitions] p ON p.hobt_id = se.hobt_id 
INNER JOIN [sys].[indexes] i on i.OBJECT_ID = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN [sys].[index_columns] ic ON ic.OBJECT_ID = i.OBJECT_ID AND ic.index_column_id = se.column_id
INNER JOIN [sys].[columns] c ON c.OBJECT_ID = ic.OBJECT_ID AND c.column_id = ic.column_id
WHERE c.[Name] = 'SalesDate';
GO





-- Are we able to eliminate segments here?
SELECT SUM(SalesAmount) AS SalesAmount,
		YEAR(SalesDate) AS SalesYear
FROM Sales.SalesOrder
WHERE SalesDate  >= '20140101' AND SalesDate <= '20141231'
GROUP BY YEAR(SalesDate);
GO





SELECT SUM(SalesAmount) AS SalesAmount,
		YEAR(SalesDate) AS SalesYear
FROM Sales.SalesOrder
WHERE Id < 1000000
GROUP BY YEAR(SalesDate);
GO





-- Real-Time Operational Analytics
-- https://docs.microsoft.com/en-us/sql/relational-databases/indexes/get-started-with-columnstore-for-real-time-operational-analytics?view=sql-server-ver15