-------------------------------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Demo: Plan caching
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
-- Scenario: States
-----------------------------------------------------------

-- Let's use the same "state" scenario from the prior demo
CREATE INDEX [EmployeeWestCoastCoveringFilteredIX]
ON [dbo].[Employee] ([State])
INCLUDE ([EmployeeID], [Address], [Status])
WHERE [State] IN ('AK', 'WA', 'OR', 'CA');
GO

-- Check the query plan for adhoc queries
-- Does the query use the filtered index?
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] = ('AK');
GO

-- Does the query use the filtered index?
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] = ('WA');
GO

-- Does the query use the filtered index?
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] IN ('MI');
GO

--------------------------------------------
-- Stored procedure with state PARAMETER
--------------------------------------------
CREATE PROCEDURE [GetDataByState] (@State char(2)) 
AS
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e]
WHERE [e].[State] = @State;
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- NONE of them use the filtered index!

--------------------------------------------
-- What about EXECUTE with RECOMPILE??
--------------------------------------------

EXECUTE [GetDataByState] 'AK' WITH RECOMPILE;
EXECUTE [GetDataByState] 'WA' WITH RECOMPILE;
EXECUTE [GetDataByState] 'MI' WITH RECOMPILE;
GO

-- Nope, NONE of them use the filtered index!

--------------------------------------------
-- What about forcing the index?
--------------------------------------------
ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
	WITH (INDEX ([EmployeeWestCoastCoveringFilteredIX]))
WHERE [e].[State] = @State;
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- Can't even execute it now... 

--------------------------------------------
-- What about CREATE with RECOMPILE??
--------------------------------------------

ALTER PROCEDURE [GetDataByState] (@State char(2)) 
WITH RECOMPILE
AS
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[State] = @State;
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- NONE of them use the filtered index!

--------------------------------------------
-- What about OPTION (OPTIMIZE FOR ...)??
--------------------------------------------

ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[State] = @State
OPTION (OPTIMIZE FOR (@State = 'AK'));
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- NONE of them use the filtered index!

--------------------------------------------
-- What about OPTION RECOMPILE??
--------------------------------------------

ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[State] = @State
OPTION (RECOMPILE);
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- Finally, success!

--------------------------------------------
-- Stored procedure with state VARIABLE (UNKNOWN)
--------------------------------------------

-- Variable is UNKNOWN so SQL Server can't trust it
ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
DECLARE @StateVar	char(2) = @State
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[State] = @StateVar;
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

-- CAN use OPTION (RECOMPILE) for variables too!
ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
DECLARE @StateVar	char(2) = @State
SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
FROM [dbo].[Employee] AS [e] 
WHERE [e].[State] = @StateVar
OPTION (RECOMPILE);
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO

--------------------------------------------
-- Stored procedure with state LITERAL (trick!)
--------------------------------------------

ALTER PROCEDURE [GetDataByState] (@State char(2)) 
AS
IF @State IN ('AK', 'WA', 'OR', 'CA')
	SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
	FROM [dbo].[Employee] AS [e] 
	WHERE [e].[State] = @State
		AND [e].[State] IN ('AK', 'WA', 'OR', 'CA')
ELSE
	SELECT [e].[EmployeeID], [e].[Address], [e].[Status]
	FROM [dbo].[Employee] AS [e] 
	WHERE [e].[State] = @State;
GO

EXECUTE [GetDataByState] 'AK';
EXECUTE [GetDataByState] 'WA';
EXECUTE [GetDataByState] 'MI';
GO