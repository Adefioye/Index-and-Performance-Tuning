---------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
---------------------------------------------------------
---------------------------------------------------------
-- Demo: Setup
---------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! 
UPDATE STATISTICS [dbo].[Employee];
GO

-- Imagine these exists already exist:
CREATE INDEX [EmployeeLnIX]
ON [Employee] ([LastName]);
GO

CREATE INDEX [EmployeeNameIX]
ON [Employee] ([LastName], [FirstName], [MiddleInitial]);
GO

CREATE INDEX [EmployeeLnIncludePhoneIX]
ON [Employee] ([LastName], [FirstName])
INCLUDE ([Phone]);
GO

CREATE INDEX [EmployeeLnFnIncludeSSNIX]
ON [Employee] ([LastName], [FirstName])
INCLUDE ([SSN]);
GO

---------------------------------------------------------
-- Review the existing indexes
---------------------------------------------------------

-- Review index definitions with my sp_SQLskills_helpindex
-- Download location: http://bit.ly/2sIyRW4

EXEC [sp_SQLskills_helpindex] '[dbo].[Employee]';
GO

-- ****************************
-- EXECUTE SEPARATE SCRIPT STEP
-- ****************************
-- Use the "QueriesForEmployeeCaseStudy.sql" script to 
-- confirm that the above indexes are used by these
-- queries (STATISTICS IO and Showplan)

-- Yes, all of the indexes are being used...

---------------------------------------------------------
-- How much storage is required:
---------------------------------------------------------

SELECT [index_id] AS [ID]
	, [index_depth] AS [D]
    , [index_level] AS [L]
    , [record_count] AS [Rows]
    , [page_count] AS [Pages]
    , [avg_page_space_used_in_percent] AS [Page:Percent Full]
    , [min_record_size_in_bytes] AS [Row:MinLen]
    , [max_record_size_in_bytes] AS [Row:MaxLen]
    , [avg_record_size_in_bytes] AS [Row:AvgLen]
FROM [sys].[dm_db_index_physical_stats]
    (DB_ID (N'EmployeeCaseStudy')					-- Database ID
    , OBJECT_ID (N'EmployeeCaseStudy.dbo.Employee') -- Object ID
    , NULL											-- Index ID
    , NULL											-- Partition ID
    , 'DETAILED');									-- Mode
GO

-- SELECT 709 + 1320 + 1433 + 1409 = 4871 PAGES
-- SELECT 4871 * 8192 / 1024 / 1024 = 38MB

EXEC [sp_spaceused] N'EmployeeCaseStudy.dbo.Employee';
GO

---------------------------------------------------------
-- "Best uses for INCLUDE"
-- Option 3 => science
---------------------------------------------------------

-- Query Tuning for THIS query:
SELECT [e].[LastName], [e].[FirstName], 
  [e].[MiddleInitial], [e].[Phone]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[S-Z]%';
GO

-- Option 3: The answer to QUERY TUNING
--CREATE INDEX [EmployeeLNinKeyInclude3OtherColsIX] 
--ON [dbo].[Employee] ([LastName])
--INCLUDE ([FirstName], [MiddleInitial], [Phone]);
--GO

---------------------------------------------------------
-- Server Tuning
---------------------------------------------------------

-- Determine the best index for the server
-- Look to see if you might be able to create a better index

-- Copy the index_keys and included_columns from:
EXEC [sp_SQLskills_helpindex] '[dbo].[Employee]';
GO

-- EXISTING INDEXES
--index_keys									included_columns
--[LastName]									NULL
--[LastName], [FirstName], [MiddleInitial]		NULL
--[LastName], [FirstName]						[Phone]
--[LastName], [FirstName]						[SSN]

-- QUERY TUNING: Option 3
-- LastName										FirstName, MiddleInitial, Phone

-- Review index keys that are a LEFT-BASED SUBSET of
-- [LastName], [FirstName], [MiddleInitial]

-- This must be your key!
--CREATE INDEX [ServerTuningIX] 
--ON [dbo].[Employee] ([LastName], [FirstName], [MiddleInitial])

-- All other columns can be added to INCLUDE (in any order):
--INCLUDE ([Phone], [SSN]);
GO

CREATE INDEX [ServerTuningIX] 
ON [dbo].[Employee] ([LastName], [FirstName], [MiddleInitial])
INCLUDE ([Phone], [SSN]);
GO

-- Now, you can drop the other indexes!
-- (or disable now, drop later - after testing!)

ALTER INDEX [EmployeeLnIX] ON [dbo].[Employee] DISABLE;
ALTER INDEX [EmployeeNameIX] ON [dbo].[Employee] DISABLE;
ALTER INDEX [EmployeeLnIncludePhoneIX] ON [dbo].[Employee] DISABLE;
ALTER INDEX [EmployeeLnFnIncludeSSNIX] ON [dbo].[Employee] DISABLE;
GO

EXEC [sp_SQLskills_helpindex] '[dbo].[Employee]';
GO

-- What about storage?
SELECT [index_id] AS [ID]
	, [index_depth] AS [D]
    , [index_level] AS [L]
    , [record_count] AS [Rows]
    , [page_count] AS [Pages]
    , [avg_page_space_used_in_percent] AS [Page:Percent Full]
    , [min_record_size_in_bytes] AS [Row:MinLen]
    , [max_record_size_in_bytes] AS [Row:MaxLen]
    , [avg_record_size_in_bytes] AS [Row:AvgLen]
FROM [sys].[dm_db_index_physical_stats]
    (DB_ID (N'EmployeeCaseStudy')					-- Database ID
    , OBJECT_ID (N'EmployeeCaseStudy.dbo.Employee') -- Object ID
    , NULL											-- Index ID
    , NULL											-- Partition ID
    , 'DETAILED');									-- Mode
GO

-- SELECT 1576 PAGES
-- SELECT 1576 * 8192 / 1024 / 1024 = 12 (instead of 38MB!)


EXEC [sp_spaceused] N'EmployeeCaseStudy.dbo.Employee';
GO  -- (Total was: ~41MB, now < ~15MB)


-- Do the queries use it?

-- ****************************
-- EXECUTE SEPARATE SCRIPT STEP
-- ****************************
-- Use the "QueriesForEmployeeCaseStudy.sql" script to 
-- confirm that the above indexes are used by these
-- queries (STATISTICS IO and Showplan)

-- Yes, THEY ALL USE THIS ONE INDEX!!!

-- But, even better - there are even more queries that can use it:
SELECT [e].[LastName], [e].[FirstName], [e].[SSN], [e].[Phone]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[A-E]%'
ORDER BY [e].[LastName], [e].[FirstName];
GO

-- Now you can drop those redundant indexes...

-- There's a science to QUERY TUNING
-- SERVER TUNING is more of an art...

-- Test, test, test, test, test, ... ;-)