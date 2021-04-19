-- Demo script for Analyzing Clustered Table 
-- Structures demo.

-- NOTE: This script requires the completion of
-- script M2_Demo02a_Setup_AnalyzingCLStructures.sql

USE [IndexInternals];
GO

-- Let's check out the total space allocated to all 
-- three tables
EXEC sp_spaceused N'EmployeeCLLastName';
EXEC sp_spaceused N'EmployeeCLGUID';
EXEC sp_spaceused N'Employee';
GO

-- Just to be clear, let's check the indexes:
EXEC sp_helpindex N'EmployeeCLLastName';
EXEC sp_helpindex N'EmployeeCLGUID';
EXEC sp_helpindex N'Employee';
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

-- Not much of a difference in the CL sizes except
-- for the clustered index on lastname

-- Why? The addition of the uniquifier

-- Part of it is that sp_helpindex doesn't tell the
-- whole story...

-- How can you get more information?
-- use sp_SQLskills_SQL2012_helpindex