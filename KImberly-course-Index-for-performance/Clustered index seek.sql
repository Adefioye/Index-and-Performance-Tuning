/*	CLUSTERED INDEX SEEK	

Sometimes Index seek might end up outputing more data than expected. That is, Seek 
might not necessarily selected a limited amount of data. It might in reality scan
all of the data. The following demo will help shed more light on this kind of scenario.


*/

-------------------------------------------------------------------------------
-- Demo: Clustered index seek
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

-- Obvious case where a seek can be performed
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[EmployeeID] = 35678;
GO

-- A "clustered index seek" can be misleading
SELECT [e].* 
FROM [dbo].[Employee] AS [e]
WHERE [e].[EmployeeID] > 0;
GO
