-- Setup script for Analyzing Heap Structures demo.

-- Create a "scratch" database with multiple files
-- and 1GB of free space 
-- Note: your test hardware and specific settings 
-- in this script might require more or less space.

-- Be sure to correctly set your filename and path.

-- Cleanup from any previous demo
USE [master];
GO

IF DATABASEPROPERTYEX (N'JunkDB', N'Version') > 0
BEGIN
	ALTER DATABASE [JunkDB] 
		SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [JunkDB];
END
GO

CREATE DATABASE [JunkDB]
ON PRIMARY 
	( NAME = N'JunkDBData1'
		, FILENAME = N'D:\Pluralsight\JunkDBData1.mdf'
		, SIZE = 250MB
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 250MB), 
	( NAME = N'JunkDBData2'
		, FILENAME = N'D:\Pluralsight\JunkDBData2.ndf' 
		, SIZE = 250MB
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 250MB), 
	( NAME = N'JunkDBData3'
		, FILENAME = N'D:\Pluralsight\JunkDBData3.ndf'
		, SIZE = 250MB
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 250MB), 
	( NAME = N'JunkDBData4'
		, FILENAME = N'D:\Pluralsight\JunkDBData4.ndf' 
		, SIZE = 250MB
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 250MB)
LOG ON 
	( NAME = N'JunkDBLog'
		, FILENAME = N'D:\Pluralsight\JunkDBLog.ldf'
		, SIZE = 250MB
		, MAXSIZE = UNLIMITED
		, FILEGROWTH = 250MB); 
GO

USE [JunkDB];
GO

-- This stops the "done in proc[ess]" messages
-- from being returned for every row (1 row affected...)
SET NOCOUNT ON;
GO

-- This checks for the table and if it exists, 
-- drops it.
IF OBJECTPROPERTY (OBJECT_ID (N'dbo.DemoTableHeap')
		, N'IsUserTable') = 1
	DROP TABLE [dbo].[DemoTableHeap];
GO

CREATE TABLE [dbo].[DemoTableHeap]
(
 [col1]	INT	 		 IDENTITY(100,10),
 [col2]	DATETIME 	 CONSTRAINT [DemoTableHeapCol2Default] 
						DEFAULT GETDATE (), -- niladic
 [col3]	DATETIME2 	 CONSTRAINT [DemoTableHeapCol3Default]
						DEFAULT SYSDATETIME (),
 [col4]	CHAR(30) 	 CONSTRAINT [DemoTableHeapCol4Default]
						DEFAULT SUSER_NAME (),
 [col5]	CHAR(30)  	 CONSTRAINT [DemoTableHeapCol5Default]
						DEFAULT USER_NAME (),
 [col6]	CHAR(100)  	 CONSTRAINT [DemoTableHeapCol6Default]
						DEFAULT 'Wide value of "Now is the time for all good men to come to the aid of their country."',
 [col7]	VARCHAR(200) CONSTRAINT [DemoTableHeapCol7Default]
						DEFAULT 'Narrow value'
);
GO

-- The longer you let this run, the larger the table
-- will be. The larger the table (3-10 mins) the more
-- interesting the results are:
-- Script default: 360 ss (seconds) is 6 minutes
DECLARE @EndTime	DATETIME;
SELECT @EndTime = DATEADD (SS, 360, GETDATE ());
WHILE GETDATE () <= @EndTime
BEGIN
	INSERT [dbo].[DemoTableHeap]
		DEFAULT VALUES
END;
GO