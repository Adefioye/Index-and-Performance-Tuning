/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Query Tuning �Pluralsight.

Description: NOT EXISTS vs NOT IN. With NULLable Columns.

****************************************************************/

USE tempdb
GO
SET NOCOUNT ON
GO
-- Create Table
CREATE TABLE BigTable (ID INT, 
						FirstName VARCHAR(100), 
						LastName VARCHAR(100), 
						City VARCHAR(100))
GO
-- Insert One Hundred Thousand Records
INSERT INTO BigTable (ID,FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID, 
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
						WHEN ROW_NUMBER() OVER (ORDER BY a.name)%427 = 1 THEN 'Hyderabad'
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO

-- Create Indexes 
-- Create Clustered Index
CREATE CLUSTERED INDEX IX_BigTable_ID
ON BigTable(ID)
GO

-- Create Table
CREATE TABLE SmallTable (ID INT, 
						FirstName VARCHAR(100), 
						LastName VARCHAR(100), 
						City VARCHAR(100))
GO
-- Insert One Hundred Thousand Records
INSERT INTO SmallTable (ID,FirstName,LastName,City)
SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY a.name) RowID, 
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
						WHEN ROW_NUMBER() OVER (ORDER BY a.name)%427 = 1 THEN 'Hyderabad'
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO

-- Create Indexes 
-- Create Clustered Index
CREATE CLUSTERED INDEX IX_SmallTable_ID
ON SmallTable(ID)
GO

/* Enable execution plan using CTRL + M
OR 
Menu >> Query >> Include Actual Execution Plan
*/

--Not IN
SELECT ID, City
FROM BigTable 
WHERE ID NOT IN 
(SELECT ID
FROM SmallTable)
GO
-- Not Exists
SELECT ID, City
FROM BigTable 
WHERE NOT EXISTS
(SELECT ID
FROM SmallTable
WHERE SmallTable.ID = BigTable.ID)
GO
-- Using JOIN
SELECT bt.ID, bt.City
FROM BigTable bt
LEFT JOIN SmallTable st ON bt.ID = st.ID
WHERE st.ID IS NULL
GO

/* Question: Which one of the above is best for performance */

-- Clean up Database
DROP TABLE BigTable
DROP TABLE SmallTable
GO