/*	NONCLUSTERED INDEX INTERNALS	*/

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
-- Demo: Nonclustered Index Internals
-------------------------------------------------------------------------------

-- Review table definition and indexes
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

-------------------------------------------------------------------------------
-- Analyze the Employee Table's Nonclustered Index
-------------------------------------------------------------------------------

-- Nonclustered indexes can have an ID between 2 and 31,005. 
-- To use the DMV you need to know the nonclustered index ID.
SELECT OBJECT_NAME([i].[object_id]) AS [Object Name]
    , [i].[index_id] AS [Index ID]
    , [i].[name] AS [Index Name]
    , [i].[type_desc] AS [Type Description]
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID(N'Employee');
GO

-- Now, use the DMV with the appropriate index ID:
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

-------------------------------------------------------------------------------
-- Reviewing that output 
-- The root page will have the highest IndexLevel. Because of 
-- the ORDER BY it will be the first row in the output.

-- The root page will reference all of the pages in the next level down.
-- Each of those pages will reference a number of pages in the next level down
-- until you reach the leaf level. Using DBCC PAGE, you can reverse-engineer 
-- the entire index structure. 
-------------------------------------------------------------------------------

DBCC TRACEON (3604); 
GO

-- Analyze the tree / root level (only 1 intermediate level, only 1 page)
DBCC PAGE (EmployeeCaseStudy, 1, 4376, 3); -- only page of level 1
	-- 7 rows, this shows the 7 pages (in order) of the intermediate level

-- Analyze the leaf level 
DBCC PAGE (EmployeeCaseStudy, 1, 4344, 3); -- first page of level 0 (385 rows)
DBCC PAGE (EmployeeCaseStudy, 1, 4345, 3); -- second page of level 0 (385 rows)
DBCC PAGE (EmployeeCaseStudy, 1, 4346, 3); -- third page of level 0 (385 rows)
-- ...
DBCC PAGE (EmployeeCaseStudy, 1, 4583, 3); -- LAST page of level 0 (305 rows)
GO

-------------------------------------------------------------------------------
-- Navigate the Employee table from the nonclustered SSN Index to find a row
-------------------------------------------------------------------------------

-- WITHOUT RUNNING this query try to visualize the process of accessing
-- this data. How would SQL Server find this row?
SELECT [e].*
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] = '111-43-5682';
GO

-- We already know the root page from above, PageFID = 1, PagePID = 4376
DBCC PAGE (EmployeeCaseStudy, 1, 4376, 3);
GO

-- Review the values. For the 24th row, you can see a low value of 109-17-0885, 
-- and for the 25th row, a low value of 113-87-6792. So if the value 111-43-5682 
-- exists, it has to be on ChildFileId = 1 and ChildPageId = 4367.

DBCC PAGE (EmployeeCaseStudy, 1, 4367, 3);
GO

-- Reviewing the output, does 111-43-5682 exist? 
--
-- Yes! 
--  SSN: 111-43-5682 is for Employee ID: 40938