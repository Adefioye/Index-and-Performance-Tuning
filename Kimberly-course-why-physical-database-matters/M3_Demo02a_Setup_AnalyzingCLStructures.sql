-- Setup script for Analyzing Clustered Table 
-- Structures demo.

-- Demo databases can be downloaded from
-- http://bit.ly/10fKpbS (that's a zero).

-- Download the 2008 IndexInternals sample database 
-- from the link above and unzip into D:\Pluralsight.

-- Restore as follows:
USE [master];
GO

/*
IF DATABASEPROPERTYEX (N'IndexInternals', N'Version') > 0
BEGIN
	ALTER DATABASE [IndexInternals] 
		SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [IndexInternals];
END
GO

RESTORE DATABASE [IndexInternals]
FROM DISK = N'D:\Pluralsight\IndexInternals2008.bak'
WITH
    MOVE N'IndexInternalsData'
		TO N'D:\Pluralsight\IndexInternalsData.mdf',
	MOVE N'IndexInternalsLog' 
		TO N'D:\Pluralsight\IndexInternalsLog.ldf';
GO
*/

-- NOTE: If you're interested in internals, this is the same 
-- index internals sample database that was created 
-- for the MSPress title: SQL Server 2008 Internals 
-- You can download it from http://bit.ly/1cWvIUp

-- CREATE COPIES OF THE Employee Table
-- Each with different clustering keys

USE [IndexInternals];
GO

-- Create a copy of Employee to be CL on Lastname
SELECT [EmployeeID]
      ,[LastName]
      ,[FirstName]
      ,[MiddleInitial]
      ,[SSN]
      ,[OtherColumns]
INTO [dbo].[EmployeeCLLastName]
FROM [dbo].[Employee];
GO

-- Add the clustered index
CREATE CLUSTERED INDEX [EmployeeCLLastNameCL]
ON [dbo].[EmployeeCLLastName] (LastName);
GO

-- Create a copy of Employee to be CL on GUID-based
-- EmployeeID
SELECT NEWID () AS [EmployeeGUID]
      ,[LastName]
      ,[FirstName]
      ,[MiddleInitial]
      ,[SSN]
      ,[OtherColumns]
INTO [dbo].[EmployeeCLGUID]
FROM [dbo].[Employee];
GO

-- Modify the newly created table with the function
-- and make the column non-nullable
ALTER TABLE [dbo].[EmployeeCLGUID]
ALTER COLUMN [EmployeeGUID] 
	UNIQUEIDENTIFIER NOT NULL;
GO

ALTER TABLE [dbo].[EmployeeCLGUID]
ADD CONSTRAINT EmployeeCLGUIDDflt
	DEFAULT NEWID() FOR [EmployeeGUID];
GO

-- Add the clustered index
ALTER TABLE [dbo].[EmployeeCLGUID]
	ADD CONSTRAINT EmployeeCLGUIDPK
		PRIMARY KEY CLUSTERED (EmployeeGUID);
GO

-- Remove the NC index on Employee to create
-- just 3 tables, each with a clustered index
-- and no nonclustered indexes.
ALTER TABLE [Employee]
	DROP CONSTRAINT [EmployeeSSNUK];
GO