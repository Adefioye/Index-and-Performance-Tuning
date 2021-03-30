/*	CLUSTERING KEY COLUMN IN NONCLUSTERED INDEXES	*/

-------------------------------------------------------------------------------
-- Setup IndexPagesOutput table
-------------------------------------------------------------------------------

-- Many examples use the DBCC IND command but change the output 
-- in some way (e.g. change the sort or only look at one level). 
-- To do this easily, use the IndexPagesOutput table in master to
-- store the output from DBCC IND.

USE [EmployeeCaseStudy];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'IndexPagesOutput'), 'IsUserTable') IS NOT NULL
    DROP TABLE [IndexPagesOutput];
GO

CREATE TABLE [IndexPagesOutput]
(
    [PageFID]			tinyint,
    [PagePID]			int,
    [IAMFID]			tinyint,
    [IAMPID]			int,
    [ObjectID]			int,
    [IndexID]			tinyint,
    [PartitionNumber]	tinyint,
    [PartitionID]		bigint,
    [iam_chain_type]	varchar(30),
    [PageType]			tinyint,
    [IndexLevel]		tinyint,
    [NextPageFID]		tinyint,
    [NextPagePID]		int,
    [PrevPageFID]		tinyint,
    [PrevPagePID]		int,
    CONSTRAINT [IndexPagesOutput_PK]
        PRIMARY KEY ([PageFID], [PagePID])
);
GO

-------------------------------------------------------------------------------
-- Demo: Clustering key columns in nonclustered indexes
-------------------------------------------------------------------------------

-- Review table definition and indexes
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

-- The SSNUK index is a UNIQUE nonclustered
-- What if we create the same index as non-unique?
CREATE INDEX [TestNonuniqueSSNUK] 
ON [dbo].[Employee] ([SSN]);
GO

-- Using sp_helpindex, they look similar (except description)
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

--What about the index structures?
SELECT OBJECT_NAME([i].[object_id]) AS [Object Name]
    , [i].[index_id] AS [Index ID]
    , [i].[name] AS [Index Name]
    , [i].[type_desc] AS [Type Description]
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID(N'Employee');
GO

-- Compare BOTH index ID 2 and 3 (highlight / execute everything 
-- from line 101 to line 131 at the same time)
SELECT [index_depth] AS [D]
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
    , 2												-- Index ID
    , NULL											-- Partition ID
    , 'DETAILED');									-- Mode
GO

SELECT [index_depth] AS [D]
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
    , 3												-- Index ID
    , NULL											-- Partition ID
    , 'DETAILED');									-- Mode
GO

-- Let's look at the intermediate/tree structure
-- (highlight / execute everything from line 135 to line 165
--  at the same time and then get the first intermediate page for each)
TRUNCATE TABLE [IndexPagesOutput];
INSERT [IndexPagesOutput]
EXEC ('DBCC IND ([EmployeeCaseStudy], ''[dbo].[Employee]'', 2)');
GO

SELECT [IndexLevel]
    , [PageFID]
    , [PagePID]
    , [PrevPageFID]
    , [PrevPagePID]
    , [NextPageFID]
    , [NextPagePID]
FROM [IndexPagesOutput]
ORDER BY [IndexLevel] DESC, [PrevPagePID];
GO

TRUNCATE TABLE [IndexPagesOutput];
INSERT [IndexPagesOutput]
EXEC ('DBCC IND ([EmployeeCaseStudy], ''[dbo].[Employee]'', 3)');
GO

SELECT [IndexLevel]
    , [PageFID]
    , [PagePID]
    , [PrevPageFID]
    , [PrevPagePID]
    , [NextPageFID]
    , [NextPagePID]
FROM [IndexPagesOutput]
ORDER BY [IndexLevel] DESC, [PrevPagePID];
GO

-- Let's compare the structure of those rows:
DBCC TRACEON (3604); 
GO

-- Analyze the tree / root level (only 1 intermediate level, only 1 page)
DBCC PAGE (EmployeeCaseStudy, 1, 4376, 3);
DBCC PAGE (EmployeeCaseStudy, 1, 8872, 3);
GO

-- And, it doesn't matter if you explicitly state a clustering
-- key column, SQL Server only adds it once
CREATE INDEX [Test2NonuniqueSSNUK] 
ON [dbo].[Employee] ([SSN], [EmployeeID]);
GO

-- Now things are even more interesting (and confusing!) using 
-- sp_helpindex
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

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

