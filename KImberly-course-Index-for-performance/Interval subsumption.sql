-------------------------------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Demo: Interval subsumption
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! 
UPDATE STATISTICS [dbo].[Employee];
GO

-- Use this to get some insight into what's happening:
SET STATISTICS IO ON;
GO

-- NOTE: I/Os alone are not the ONLY way to understand
-- what's going on. We'll add graphical showplan as well.
-- Use Query, Include Actual Execution Plan

-----------------------------------------------------------
-- Scenario: Status 
-----------------------------------------------------------

-- If you're regularly wanting to see all employees in 
-- a specific status then you'd want just a normal 
-- covering index:
--CREATE INDEX [EmployeeStatusCoveringIX]
--ON [dbo].[Employee] ([Status])
--INCLUDE ([LastName], [FirstName])
--GO

-- What if we created one for a subset of statuses?
CREATE INDEX [EmployeeStatusFilteredIX]
ON [dbo].[Employee] ([Status])
INCLUDE ([LastName], [FirstName])
WHERE [Status] IN (1, 3, 5, 7, 9);
GO

-- Any/all status requests can use it:
SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 1;
GO

SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] = 5;
GO

SELECT [e].[LastName], [e].[FirstName]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Status] > 5; -- Wait? What?
GO

-- Even though YOU know that status > 8 is just status = 9
-- SQL Server doesn't!

-- Every WHERE clause must be a SUBSET of a SINGLE filter
-- predicate. When values are listed indivually OR
-- in more than one index, SQL Server cannot combine
-- the filtered indexes for one query (even when YOU
-- know it should work!).

-----------------------------------------------------------
-- Scenario: EmployeeID ranges
-----------------------------------------------------------

-- What if we created one with ranges?
-- These could be dates, numeric, etc...

CREATE INDEX [EmployeeIDRange1FilteredIX]
ON [dbo].[Employee] ([EmployeeID])
INCLUDE ([State], [City], [Zip])
WHERE [EmployeeID] >= 0 AND [EmployeeID] < 1000;
GO

CREATE INDEX [EmployeeIDRange2FilteredIX]
ON [dbo].[Employee] ([EmployeeID])
INCLUDE ([State], [City], [Zip])
WHERE [EmployeeID] >= 1000 AND [EmployeeID] < 2000;
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[EmployeeID] BETWEEN 900 AND 910; -- This is OK
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[EmployeeID] BETWEEN 910 AND 1090; -- This is NOT
GO

-----------------------------------------------------------
-- Scenario: Zip ranges
-----------------------------------------------------------

CREATE INDEX [EmployeeZipRange1FilteredIX]
ON [dbo].[Employee] ([Zip])
INCLUDE ([State], [City])
WHERE [Zip] >= '10000' AND [Zip] < '20000';
GO

CREATE INDEX [EmployeeZipRange2FilteredIX]
ON [dbo].[Employee] ([Zip])
INCLUDE ([State], [City])
WHERE [Zip] >= '20000' AND [Zip] < '30000';
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Zip] BETWEEN '11000' AND '12000'; -- This is OK
GO

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Zip] BETWEEN '19000' AND '21000'; -- Nope!
GO

-- Are filtered indexes a replacement for partition-level indexes?
-- No, because of these problems with interval subsumption

--  * You could re-write the queries:

SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Zip] >= '19000' AND [e].[Zip] < '20000'
UNION ALL
SELECT [e].[EmployeeID], [e].[State], [e].[City], [e].[Zip]
FROM [dbo].[Employee] AS [e]
WHERE [e].[Zip] >= '20000' AND [e].[Zip] <= '21000'
GO

-- Even that can become complex
--   * to keep track of
--   * to write
--   * to maintain, etc.