/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Order of condition in WHERE clause.

****************************************************************/

USE tempdb
GO
-- Create Table
-- DROP TABLE WhereClause
-- Create Table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WhereClause]') AND type in (N'U'))
	DROP TABLE [dbo].[WhereClause]
GO
CREATE TABLE WhereClause (ID INT, 
						  ID1 VARCHAR(4),
						  ID2 VARCHAR(4),
						FirstName VARCHAR(100), 
						LastName VARCHAR(100), 
						City VARCHAR(100))
GO

-- Insert One Hundred Thousand Records
INSERT INTO WhereClause (ID, ID1, ID2, FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID,
			LEFT(NEWID(),4), LEFT(NEWID(),3),
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
						WHEN ROW_NUMBER() OVER (ORDER BY a.name)%427 = 1 THEN 'Ahmedabad'
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO
INSERT INTO WhereClause (ID, ID1, ID2, FirstName,LastName,City)
SELECT 100001,'A2C4','E67','FirstNameTest','SecondNameTest','CityNameTest'
GO

-- Check Distinct 
SELECT COUNT(DISTINCT ID) ID, 
COUNT(DISTINCT ID1) ID1, COUNT(DISTINCT ID2) ID2, 
COUNT(DISTINCT FirstName) FirstName, 
COUNT(DISTINCT LastName) LastName, COUNT(DISTINCT City) City
FROM WhereClause
GO

-- Create Clustered Index
CREATE CLUSTERED INDEX [IX_WhereClause_ID] ON [dbo].[WhereClause]
(
	[ID] ASC
) ON [PRIMARY]
GO

-- Execute Select on PK
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID = 100001 
GO

-- Execute Selects 
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID1 = 'A2C4' AND ID2 = 'E67'
GO
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67' AND ID1 = 'A2C4'
GO

-- Create Two non clustered index
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID1] ON [dbo].[WhereClause]
(
	[ID1] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID2] ON [dbo].[WhereClause]
(
	[ID2] ASC
) ON [PRIMARY]
GO

-- Execute Selects 
SELECT ID, ID2,ID1 
FROM WhereClause
WHERE ID1 = 'A2C4' AND ID2 = 'E67'
GO
SELECT ID, ID2,ID1 
FROM WhereClause 
WHERE ID2 = 'E67' AND ID1 = 'A2C4'
GO

-- Create Two non clustered index Multi Key 
-- Drop Indexes if they exists
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WhereClause]') AND name = N'IX_WhereClause_ID1_ID2')
DROP INDEX [IX_WhereClause_ID1_ID2] ON [dbo].[WhereClause] WITH ( ONLINE = OFF )
GO
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WhereClause]') AND name = N'IX_WhereClause_ID2_ID1')
DROP INDEX [IX_WhereClause_ID2_ID1] ON [dbo].[WhereClause] WITH ( ONLINE = OFF )
GO

-- Create Indexes
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID2_ID1] ON [dbo].[WhereClause]
(
	[ID2] ASC,[ID1] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID1_ID2] ON [dbo].[WhereClause]
(
	[ID1] ASC, [ID2] ASC
) ON [PRIMARY]
GO

-- Execute Selects 
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID1 = 'A2C4' AND ID2 = 'E67'
GO
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67' AND ID1 = 'A2C4'
GO

-- Create Two non clustered index Multi Key 
-- Drop Indexes if they exists
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WhereClause]') AND name = N'IX_WhereClause_ID1_ID2')
DROP INDEX [IX_WhereClause_ID1_ID2] ON [dbo].[WhereClause] WITH ( ONLINE = OFF )
GO
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WhereClause]') AND name = N'IX_WhereClause_ID2_ID1')
DROP INDEX [IX_WhereClause_ID2_ID1] ON [dbo].[WhereClause] WITH ( ONLINE = OFF )
GO

-- Create Indexes
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID1_ID2] ON [dbo].[WhereClause]
(
	[ID1] ASC, [ID2] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WhereClause_ID2_ID1] ON [dbo].[WhereClause]
(
	[ID2] ASC,[ID1] ASC
) ON [PRIMARY]
GO

-- Execute Selects 
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID1 = 'A2C4' AND ID2 = 'E67'
GO
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67' AND ID1 = 'A2C4'
GO

-- DMV to Figure out the Size of Indexes
SELECT 
object_name(i.object_id) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.object_id = i.object_id and p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP by i.object_id,i.index_id,i.name
ORDER By object_name(i.object_id),i.index_id
GO

-- Bonus 1
-- Execute Selects 
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID1 = 'A2C4'
GO
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67' 
GO

-- Bonus 2
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67' OR ID1 = 'A2C4'
GO

-- Bonus 3
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID2 = 'E67'
UNION
SELECT ID, ID1, ID2
FROM WhereClause
WHERE ID1 = 'A2C4'
GO

-- Clean Up
DROP TABLE WhereClause
GO
