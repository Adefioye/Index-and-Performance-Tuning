-- Demo script for Analyzing Heap Structures demo.

-- NOTE: This script requires the completion of
-- script M2_Demo01a_Setup_AnalyzingHeapStructures.sql

USE [JunkDB];
GO

-- You can review the space quickly by using this:
EXEC sp_spaceused N'dbo.DemoTableHeap', N'TRUE';
GO
-- Record your RowCount = 

-- Determine the number of pages by dividing "data"
-- value by 8 (SQL Server has 8KB pages and data is
-- described in KB)

-- SELECT /8 = 66985 PAGES (535887 (# of rows) This is wrong)

-- Next, run a query that requires a table scan.
-- The number of I/Os (shown by statistics IO) should
-- match the number of pages you've calculated.

SET STATISTICS IO ON;
GO

SELECT COUNT (*) AS [Rows]
FROM [dbo].[DemoTableHeap];
GO

-- Make sure you go to the messages tab (if using tabs)
-- to see the I/Os

-- Let's also use the DMV to see that this is only
-- IN_ROW_DATA and fixed-width rows
SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'DemoTableHeap')
		, NULL
		, NULL
		, N'DETAILED'); 
GO

-- Modify ~15% of the data
UPDATE [dbo].[DemoTableHeap]
	SET [col7] = 'This is a test to create some fragmentation. The previously small column is now filled to capacity. This is a test to create some fragmentation. The previously small column is now filled to capacity.'
WHERE [col1] % 7 = 0;

SELECT @@ROWCOUNT;
GO

-- Keep track of rows modified = 76555

-- Check the space again and calculate # of Pages
SET STATISTICS IO OFF;
GO

EXEC sp_spaceused N'dbo.DemoTableHeap', N'TRUE';
GO

-- Determine the number of pages by dividing "data"
-- value by 8 (SQL Server has 8KB pages and data is
-- described in KB)

-- SELECT 126528/8 = 15816 50064 PAGES

-- Re-run the query that requires a table scan.
-- Then, check the I/Os - is it what you expect?

SET STATISTICS IO ON;
GO

SELECT COUNT(*) AS [Rows]
FROM [dbo].[DemoTableHeap];
GO

-- The I/Os no longer equal the number of pages in
-- the table...

-- So, what does that number represent?

-- Pages and forwarding pointers
-- Only heaps have forwarded rows

-- Take the number of I/Os that were done
-- Subtract the number of pages in the table

--	SELECT I/Os - Pages = 34248
-- SELECT 50064 - 15816 = 

-- That represents the number of forwarding pointers
-- within the table.

-- When SQL Server encounters a Forwarding Pointer 
-- on a scan, they always honor the lookup/lock
-- by going to the page where the row is located.
-- This can cause additional random I/O activity
-- on a lookup. It's really both a pro and a con.
-- However, for a table scan or for really large
-- tables where the data won't be able to permanently
-- reside in cache, it can be expensive.

SELECT [alloc_unit_type_desc] AS [Data Structure]
	, [page_count] AS [Pages]
	, [record_count] AS [Rows]
	, [min_record_size_in_bytes] AS [Min Row]
	, [max_record_size_in_bytes] AS [Max Row]
	, [forwarded_record_count] AS [Fwded Rows]
FROM sys.dm_db_index_physical_stats
	(DB_ID ()
		, OBJECT_ID (N'DemoTableHeap')
		, NULL
		, NULL
		, N'DETAILED'); 
GO

-- NOTE: Only the detailed and sampled modes of
-- sys.dm_db_index_physical_stats return the
-- value of forwarded_record_count.
