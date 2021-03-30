/*	TIPPING POINT

This has to do with the question of when is it better to do a table scan vs a bookmark
lookup.

*/

-------------------------------------------------------------------------------
-- Demo: The tipping point
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

ALTER DATABASE [EmployeeCaseStudy]
		SET COMPATIBILITY_LEVEL = 120; -- NEW CE
GO


-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! This is the first example
-- where NOT doing this will affect my results.
UPDATE STATISTICS [dbo].[Employee];
UPDATE STATISTICS [dbo].[EmployeeHeap];
GO

-- Review index definitions
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

-- Use this to get some insight into what's happening:
SET STATISTICS IO ON;
GO

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan


-- At what point is a SSN not "selective enough" to warrant
-- using the SSNUK index?

-- What about 100 rows?
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-83-7970' AND '125-15-5000';
GO 

-- What about 400 rows?
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-83-7970' AND '129-67-0000';
GO 

-------------------------------------------------------------------------------
-- Let's estimate the tipping point:
-------------------------------------------------------------------------------

-- How many pages are there in this table? 
-- We need to review the leaf level of the CL index (1)
SELECT [index_depth] AS [D]
    , [index_level] AS [L]
    , [page_count] AS [Pages]
	, [page_count]/4 AS [Selective]   -- = 1,000 (1.25% of the table)
	, [page_count]/3 AS [SCAN]        -- = 1,333 (1.66% of the table)
FROM [sys].[dm_db_index_physical_stats]
    (DB_ID (N'EmployeeCaseStudy')					-- Database ID
    , OBJECT_ID (N'EmployeeCaseStudy.dbo.Employee') -- Object ID
    , 1												-- Index ID
    , NULL											-- Partition ID
    , 'DETAILED')									-- Mode
WHERE [index_level] = 0;									
GO

-- Confirming that Employee has 4,000 pages in the leaf
-- level of the clustered index (index_id = 1)

-- SELECT 4000.0 / 4; -- = 1,000 (1.25% of the table)
-- SELECT 4000.0 / 3; -- = 1,333 (1.66% of the table)
GO

-------------------------------------------------------------------------------
-- Tipping point: SSN
-------------------------------------------------------------------------------

-- What is the exact point?
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] < '012-99-1619';
GO -- 1,123 rows returned, uses the nonclustered index

SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] < '013-01-0380';
GO -- 1,124 rows returned, performs a table scan

SELECT 1124 / 80000.00 * 100; -- = 1.405 % of the table
GO

-------------------------------------------------------------------------------
-- Tipping point: FirstName
-------------------------------------------------------------------------------
ALTER DATABASE [EmployeeCaseStudy]
		SET COMPATIBILITY_LEVEL = 120; -- NEW CE
GO

-- When is an index on FirstName selective enough to be used?
CREATE INDEX [EmployeeFirstNameIX] 
ON [dbo].[Employee] ([FirstName]);
GO

-- What is the exact point?
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[FirstName] BETWEEN N'Poowohmijbdk' AND N'Qnwnqagu'; 
GO -- 1,007 rows returned, uses the nonclustered index

SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[FirstName] BETWEEN N'Poowohmijbdk' AND N'Qognwbzeyvltqr';
GO -- 1,009 rows returned, uses the nonclustered index

SELECT 1008 / 80000.00 * 100; -- = 1.26 % of the table
GO

-------------------------------------------------------------------------------
-- Let's estimate the tipping point: EmployeeHeap
-------------------------------------------------------------------------------

-- How many pages are there in this table? 
SELECT [index_depth] AS [D]
    , [index_level] AS [L]
    , [page_count] AS [Pages]
	, [page_count]/4 AS [Selective]   -- = 1,000 (1.25% of the table)
	, [page_count]/3 AS [SCAN]        -- = 1,333 (1.66% of the table)
FROM [sys].[dm_db_index_physical_stats]
    (DB_ID (N'EmployeeCaseStudy')					    -- Database ID
    , OBJECT_ID (N'EmployeeCaseStudy.dbo.EmployeeHeap') -- Object ID
    , 0												    -- Index ID
    , NULL											    -- Partition ID
    , 'DETAILED')									    -- Mode
WHERE [index_level] = 0;									
GO

-- Confirming that Employee has 4,000 pages in the table

-- SELECT 4000.0 / 4; -- = 1,000 (1.25% of the table)
-- SELECT 4000.0 / 3; -- = 1,333 (1.66% of the table)
GO

-------------------------------------------------------------------------------
-- Tipping point: EmployeeID
-------------------------------------------------------------------------------

-- What is the exact point?
SELECT [e].* 
FROM [dbo].[EmployeeHeap] AS [e]
WHERE [e].[EmployeeID] < 1063;
GO -- 1,062 rows returned, uses the nonclustered index

SELECT [e].* 
FROM [dbo].[EmployeeHeap] AS [e]
WHERE [e].[EmployeeID] < 1064;
GO -- 1,063 rows returned, performs a table scan

SELECT 1063 / 80000.00 * 100; -- = 1.329 % of the table
GO