-------------------------------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Demo: Filtered Index
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! 
UPDATE STATISTICS [dbo].[Employee];
GO

-- Review table definition and indexes
EXEC [sp_help] '[dbo].[Employee]';
GO

-- What does the status column look like?
SELECT [e].[Status], COUNT(*) AS [Rows]
FROM [dbo].[Employee] AS [e]
GROUP BY [e].[Status]
ORDER BY [e].[Status];
GO

-- If you want to see all employees in a specific status
-- you might think about creating an index on status?
CREATE INDEX [EmployeeStatusIX]
ON [dbo].[Employee] ([Status]);
GO

-- Use this to get some insight into what's happening:
SET STATISTICS IO ON;
GO

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan


-- Will your queries use it?
SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 1;
GO

-- Will your queries use it?
SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 9;
GO

-- If you're regularly wanting to see all employees in 
-- a specific status (and for all of the different statuses)
-- then you'd want just a normal covering index:
CREATE INDEX [EmployeeStatusCoveringIX]
ON [dbo].[Employee] ([Status])
INCLUDE ([LastName], [FirstName]);
GO

-- Any/all status requests can use it:
SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 1;
GO

SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 8;
GO

SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] > 8;
GO

-------------------------------------------------------------------------------
-- What about more specific requests over just
-- certain statuses (or documents or "types")
-------------------------------------------------------------------------------

-----------------------------------------------------------
-- Scenario: Status (filtering on equality-based criteria)
-----------------------------------------------------------

-- For employees with a status of 9 you want to see their
-- EmployeeID, State, City, Phone
SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 9;
GO

-- Regular unfiltered index
CREATE INDEX [EmployeeStatusCoveringUnfilteredIX]
ON [dbo].[Employee] ([Status])
INCLUDE ([EmployeeID], [State], [City], [Phone]);
GO

-- Filtered index (move Status to the WHERE clause):
-- But, what goes in the key?

--CREATE INDEX [EmployeeStatusCoveringUnfilteredIX]
--ON [dbo].[Employee] 
--INCLUDE ([EmployeeID], [State], [City], [Phone])
--WHERE ([Status]) = 9;
--GO 

-- But, what goes in the key?
-- Lots of considerations? Is there anything else:
--   * on which you might want to search?
--		WHERE [e].[State] = 'WA'
--   * on which you might want to order?
--		ORDER BY [e].[State], [e].[City]

-- These are things to consider for the key!
CREATE INDEX [EmployeeStatusCoveringFilteredIX]
ON [dbo].[Employee] ([State], [City])
INCLUDE ([EmployeeID], [Phone])
WHERE ([Status]) = 9;
GO

-- First, let's review the sizes of the filtered and 
-- unfiltered indexes:

SELECT OBJECT_NAME([i].[object_id]) AS [Object Name]
    , [i].[index_id] AS [Index ID]
    , [i].[name] AS [Index Name]
    , [i].[type_desc] AS [Type Description]
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID(N'Employee');
GO

-- Now, use the DMV (adding index ID) to review all indexes:
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

-- What about the queries
SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 9;
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e] WITH (INDEX ([EmployeeStatusCoveringFilteredIX]))
WHERE [e].[Status] = 9;
GO

-- What really makes the index shine:
SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[Status] = 9 AND [e].[State] = 'AK' AND [e].[City] = 'Anchorage'
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[Status] = 9
ORDER BY [e].[State], [e].[City]
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Phone]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[Status] = 9 AND [e].[State] = 'CA' 
ORDER BY [e].[State], [e].[City]
GO

-----------------------------------------------------------
-- Scenario: State (filtering on inequality-based criteria)
-----------------------------------------------------------

-- For employees on the west coast / coastal states, you want 
-- to see their address and status
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] IN ('AK', 'WA', 'OR', 'CA');
GO

-- Regular unfiltered index
CREATE INDEX [EmployeeWestCoastCoveringUnfilteredIX]
ON [dbo].[Employee] ([State])
INCLUDE ([EmployeeID], [Address], [Status]);
GO

-- Are you wondering why I'm LISTING the clustering
-- key in these indexes?
-- Always create the index that the query needs!
--   * If the query USES EmployeeID
--		LIST IT 
--   * If the query does not use EmployeeID
--		DO NOT LIST IT

-- So, will SQL Server use this index?
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] IN ('AK', 'WA', 'OR', 'CA');
GO

-- What about a filtered index?
CREATE INDEX [EmployeeWestCoastCoveringFilteredIX]
ON [dbo].[Employee] ([State])
INCLUDE ([EmployeeID], [Address], [Status])
WHERE [State] IN ('AK', 'WA', 'OR', 'CA');
GO

-- Does the query use the filtered index?
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] IN ('AK', 'WA', 'OR', 'CA');
GO

SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] IN ('AK', 'CA');
GO

-- Yes, but it doesn't seem to have saved us anything
-- Except index size!

-- Let's review the sizes of the filtered and 
-- unfiltered indexes:

SELECT OBJECT_NAME([i].[object_id]) AS [Object Name]
    , [i].[index_id] AS [Index ID]
    , [i].[name] AS [Index Name]
    , [i].[type_desc] AS [Type Description]
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID(N'Employee');
GO

-- Now, use the DMV (adding index ID) to review all indexes:
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



-- IMPORTANT NOTES: 
--   * You don't need to LIST the filtering column in the 
--     index (except in the WHERE clause) if you're not 
--     returning it AND it's EQUALITY-based (Status = 9)
--   * You SHOULD LIST the filtering column in the 
--     index if it's NOT EQUALITY-based (Status < 3)
--   * Always EXPLICITLY define ONLY the relevant columns
--     needed for an index:
--      - don't needlessly add the clustering key just because
--        SQL Server's going to do it
--      - don't skip adding clustering key columns because SQL
--        Server's going to do it (what if the clustering key were
--        to change at a later date?)


-- Covered numerous scenarios with a smaller and more manageable
-- index!
--  * Saving disk space, memory, logging
--  * Saving maintenance costs
--  * Allowing for more indexes for other filtered scenarios
