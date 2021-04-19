-- Demo script for Analyzing Nonclustered indexes demo.

-- NOTE: This script requires the completion of
-- the setup script for M2_Demo02 to be run.
-- Script: M2_Demo02a_Setup_AnalyzingCLStructures.sql
-- And the setup for sp_SQLskills_SQL2012_helpindex

USE [IndexInternals];
GO

-- Add a NC index to [EmployeeCLLastName] 
-- (Clustered by LastName)
-- Add the nonclustered unique key on SSN
ALTER TABLE [dbo].[EmployeeCLLastName] 
	ADD CONSTRAINT [EmployeeCLLastName_UKSSN]
		UNIQUE NONCLUSTERED (SSN);
GO

-- Add a NC index to [EmployeeCLGUID] 
-- (Clustered by GUID)
-- Add the nonclustered unique key on SSN
ALTER TABLE [dbo].[EmployeeCLGUID]
	ADD CONSTRAINT [EmployeeCLGUID_UKSSN]
		UNIQUE NONCLUSTERED (SSN);
GO

-- Add a NC index to [Employee] 
-- (Clustered by EmployeeID)
-- Add the nonclustered unique key on SSN
ALTER TABLE [dbo].[Employee]
	ADD CONSTRAINT [EmployeeUKSSN]
		UNIQUE NONCLUSTERED (SSN);
GO

-- Let's check all of the indexes:
EXEC sp_helpindex N'EmployeeCLLastName';
EXEC sp_helpindex N'EmployeeCLGUID';
EXEC sp_helpindex N'Employee';
GO

-- Let's check out the total space allocated to all 
-- three tables
EXEC sp_spaceused N'EmployeeCLLastName';
EXEC sp_spaceused N'EmployeeCLGUID';
EXEC sp_spaceused N'Employee';
GO

-- Let's use our DMV with some index-related metadata
-- from the sys.indexes view.

SELECT OBJECT_NAME ([si].[object_id]) AS [Table Name] 
	, [si].[name] AS [Index Name]
	, [ps].[index_id] AS [Index ID] 
	, [ps].[alloc_unit_type_desc] AS [Data Structure]
	, [ps].[page_count] AS [Pages]
	, [ps].[record_count] AS [Rows]
	, [ps].[min_record_size_in_bytes] AS [Min Row]
	, [ps].[max_record_size_in_bytes] AS [Max Row]
FROM [sys].[indexes] AS [si]
	CROSS APPLY sys.dm_db_index_physical_stats 
		(DB_ID ()
		, [si].[object_id]
		, NULL
		, NULL
		, N'DETAILED') AS [ps]
WHERE [si].[object_id] = [ps].[object_id]
		AND [si].[index_id] = [ps].[index_id]
		AND [si].[object_id] 
			IN (OBJECT_ID (N'EmployeeCLLastName')
				, OBJECT_ID (N'EmployeeCLGUID')
				, OBJECT_ID (N'Employee'))
		AND [ps].[index_level] = 0;
GO

-- Each one only has one column listed in
-- the index_keys column.

-- These sizes seem to imply that there's more than
-- just this ONE column in these nonclustered indexes.

-- Part of it is that sp_helpindex doesn't tell the
-- whole story
EXEC sp_SQLskills_helpindex N'EmployeeCLLastName';
EXEC sp_SQLskills_helpindex N'EmployeeCLGUID';
EXEC sp_SQLskills_helpindex N'Employee';
GO

