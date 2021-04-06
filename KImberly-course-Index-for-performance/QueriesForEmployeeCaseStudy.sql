---------------------------------------------------------
-- Supplemental script for Index Consolidation demo
-- Queries for the EmployeeCaseStudy database
-- Download location: http://bit.ly/2r6BR1g
---------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- Use this to get some insight into what's happening:
SET STATISTICS IO ON;
GO

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan

-- Some queries do bookmark lookups because the
-- query (SELECT *) is too wide to consider covering. 
-- Remember, you just can't cover everything!
-- And, since most of the executions are HIGHLY 
-- selective it's OK!

-- Imagine LOTS of these requests:
SELECT [e].*
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] = N'Anderson'
	AND [e].[FirstName] = N'Tkim';
GO

-- Imagine FEWER of these requests:
SELECT [e].*
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] = N'Illmann'
	AND [e].[FirstName] = N'Kim'
	AND [e].[MiddleInitial] = N'M';
GO

-- Imagine a large number of these requests:
-- (users [us, too] are lazy!)
SELECT [e].*
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] = N'Liu';
GO

-- Imagine personnel specialists want a list of those in their
-- "span of control" with their phone numbers:
SELECT [e].[LastName], [e].[FirstName], [e].[Phone]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[S-Z]%'
ORDER BY [e].[LastName], [e].[FirstName];
GO

-- Imagine personnel specialists want a list of those in their
-- "span of control" with their SSNs:
SELECT [e].[LastName], [e].[FirstName], [e].[SSN]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[A-E]%'
ORDER BY [e].[LastName], [e].[FirstName];
GO

-- Some reports use their full name
SELECT [e].[LastName], [e].[FirstName], [e].[MiddleInitial]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[S-Z]%'
ORDER BY [e].[LastName], [e].[FirstName], [e].[MiddleInitial];
GO

-- What if they just want to see their "span of control" count
SELECT COUNT(*) AS [Number of Employees]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[A-E]%';
GO

SELECT COUNT(*) AS [Number of Employees]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[F-M]%';
GO

SELECT COUNT(*) AS [Number of Employees]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[N-R]%';
GO

SELECT COUNT(*) AS [Number of Employees]
FROM [dbo].[Employee] AS [e]
WHERE [e].[LastName] LIKE '[S-Z]%';
GO