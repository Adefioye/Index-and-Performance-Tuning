-------------------------------------------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location: http://bit.ly/2r6BR1g
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Demo: Let's create ALL of the filtered indexes discussed
-------------------------------------------------------------------------------

USE [EmployeeCaseStudy];
GO

-- When you upgrade a database, you should always 
-- UPDATE STATISTICS! 
UPDATE STATISTICS [dbo].[Employee];
GO

-- Filtering on Status
CREATE INDEX [EmployeeStatusCoveringFilteredIX]
ON [dbo].[Employee] ([State], [City])
INCLUDE ([EmployeeID], [Phone])
WHERE ([Status]) = 9;
GO

-- Filtering on State
CREATE INDEX [EmployeeWestCoastCoveringFilteredIX]
ON [dbo].[Employee] ([State])
INCLUDE ([EmployeeID], [Address], [Status])
WHERE [State] IN ('AK', 'WA', 'OR', 'CA');
GO

-- Not really filtering on status...
CREATE INDEX [EmployeeStatusFilteredIX]
ON [dbo].[Employee] ([Status])
INCLUDE ([LastName], [FirstName])
WHERE [Status] IN (1, 2, 3, 4, 5, 6, 7, 8, 9);
GO

-- Scenario: EmployeeID ranges (range 1)
CREATE INDEX [EmployeeIDRange1FilteredIX]
ON [dbo].[Employee] ([EmployeeID])
INCLUDE ([State], [City], [Zip])
WHERE [EmployeeID] >= 0 AND [EmployeeID] <= 1000;
GO

-- Scenario: EmployeeID ranges (range 2)
CREATE INDEX [EmployeeIDRange2FilteredIX]
ON [dbo].[Employee] ([EmployeeID])
INCLUDE ([State], [City], [Zip])
WHERE [EmployeeID] >= 1000 AND [EmployeeID] <= 2000;
GO

-- Scenario: Zip ranges (range1)
CREATE INDEX [EmployeeZipRange1FilteredIX]
ON [dbo].[Employee] ([Zip])
INCLUDE ([State], [City])
WHERE [Zip] >= '10000' AND [Zip] <= '20000';
GO

-- Scenario: Zip ranges (range2)
CREATE INDEX [EmployeeZipRange2FilteredIX]
ON [dbo].[Employee] ([Zip])
INCLUDE ([State], [City])
WHERE [Zip] >= '20000' AND [Zip] <= '30000';
GO

-- Review table definition and indexes
EXEC [sp_helpindex] '[dbo].[Employee]';
GO

-- To help, I wrote a generic / updated version of sp_helpindex
-- called sp_SQLskills_helpindex
-- Download location: http://bit.ly/2sIyRW4

EXEC [sp_SQLskills_helpindex] '[dbo].[Employee]';
GO

-- What about statistics?
DBCC SHOW_STATISTICS ('Employee', 'EmployeeZipRange1FilteredIX');
GO

-- Does that tell us better information than a table-level
-- statistic? ESPECIALLY in much larger tables, yes...
CREATE INDEX [EmployeeZipIX]
ON [dbo].[Employee] ([Zip])
INCLUDE ([State], [City]);
GO

-- What about statistics?
DBCC SHOW_STATISTICS ('Employee', 'EmployeeZipIX');
GO -- only 20 steps to describe each range where the FI
   -- has 200 just for that filtered set

-- There's some VERY good info out there on filtered statistics
-- that I did for PASS a few years ago. Check it out here:
-- http://bit.ly/2rVvCKV
-- (note: they were recording BEFORE my session officially started
--        and never removed any of it. The session really starts 
--        at 4min 16seconds. Just move your cursor there and start!)