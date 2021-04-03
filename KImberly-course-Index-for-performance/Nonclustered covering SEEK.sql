-------------------------------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
-------------------------------------------------------------------------------


ALTER DATABASE [EmployeeCaseStudy]
		SET COMPATIBILITY_LEVEL = 120; -- SQL Server 2014
GO

-------------------------------------------------------------------------------
-- Demo: Nonclustered covering seekable query
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! 
UPDATE STATISTICS [dbo].[Employee];
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


-- The example we saw before used the SSNUK index - but
-- with bookmark lookups:
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-43-4550' AND '123-67-0000';
GO  

-- The following query is covered by the index ALONE - no 
-- bookmark lookups are necessary.
-- The big difference is in the limited select list:
SELECT [e].[EmployeeID], [e].[SSN]
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-43-4550' AND '123-67-0000';
GO 

-------------------------------------------------------------------------------
-- But even range queries benefit!
-------------------------------------------------------------------------------

-- If a query is not selective enough then the index
-- won't be used (when it's not covered):
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-43-4550' AND '200-00-0000';
GO  

-- Again, it's all about the limited select list:
SELECT [e].[EmployeeID], [e].[SSN]
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '123-43-4550' AND '200-00-0000';
GO 

-- Even if the entire data set is required:
SELECT [e].[EmployeeID], [e].[SSN]
FROM [dbo].[Employee] AS [e]
WHERE [e].[SSN] BETWEEN '000-00-0001' AND '999-99-9999';
GO 

-- It's even useful without a WHERE clause:
SELECT [e].[EmployeeID], [e].[SSN]
FROM [dbo].[Employee] AS [e]
GO 