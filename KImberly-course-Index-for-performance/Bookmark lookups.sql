/*	BOOKMARK LOOKUP	

Bookmark lookup for point queries are usually very cheap when just about 1 or few rows
match the query. When many rows are to be selected, this could become an expensive 
process.

*/

-------------------------------------------------------------------------------
-- Demo: Nonclustered index seek with a bookmark lookup
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- Review table definition and indexes
EXEC [sp_help] '[dbo].[Employee]';
GO

-- Use this to get some insight into what's happening:
SET STATISTICS IO ON;
GO

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan


-- Think like an index in the back of a book... you
-- reference one thing (the index key) but then have
-- to go to the data to get more information.

-- The table (i.e. the "book") is structured by the 
-- clustering key of EmployeeID 

-- The reference (i.e. the index in the back of the book)
-- is SSN (the nonclustered index)

SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] = '749-21-9445';
GO

-------------------------------------------------------------------------------
-- Bookmark lookups allow you to find data based
-- on secondary index keys
-- This is OK when the set is small...
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Demo: Nonclustered index seek with multiple bookmark
--       lookups
-------------------------------------------------------------------------------

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan

SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-45-6789' AND '123-45-6800';
GO  -- 0 rows so only the nonclustered seek is performed
 

-- What if we actually have a set of 12 SSNs? 
-- 12 rows and on only 1 page in the NC leaf-level
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-43-4550' AND '123-67-0000';
GO  

-- What if we actually have a set of 12 SSNs?
-- 12 rows and over 2 pages in the NC leaf-level
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-83-7970' AND '123-95-0000';
GO  

-------------------------------------------------------------------------------
-- Bookmark lookups allow you to find data based
-- on secondary index keys
-- This is OK when the set is small...
-------------------------------------------------------------------------------
