/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Function used in WHERE Clause.

****************************************************************/

USE tempdb
GO

-- Create Table
CREATE TABLE UDFEffect (ID INT, 
						FirstName VARCHAR(100), 
						LastName VARCHAR(100), 
						City VARCHAR(100))
GO

-- Insert One Hundred Thousand Records
INSERT INTO UDFEffect (ID,FirstName,LastName,City)
SELECT TOP 100000 ROW_NUMBER() OVER (ORDER BY a.name) RowID, 
					'Bob', 
					CASE WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%2 = 1 THEN 'Smith' 
					ELSE 'Brown' END,
					CASE WHEN ROW_NUMBER() OVER (ORDER BY a.name)%10 = 1 THEN 'New York' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 5 THEN 'San Marino' 
						WHEN  ROW_NUMBER() OVER (ORDER BY a.name)%10 = 3 THEN 'Los Angeles' 
						WHEN ROW_NUMBER() OVER (ORDER BY a.name)%427 = 1 THEN 'Salk Lake City'
					ELSE 'Houston' END
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
GO

-- Create Indexes 
-- Create Clustered Index
CREATE CLUSTERED INDEX IX_UDFEffect_ID
ON UDFEffect(ID)
GO

-- Create non clustered index
CREATE NONCLUSTERED INDEX IX_UDFEffect_City
ON UDFEffect (City)
GO

-- Create non clustered index
CREATE NONCLUSTERED INDEX IX_UDFEffect_ID_City
ON UDFEffect (ID,City)
GO

/* Enable execution plan using CTRL + M
OR 
Menu >> Query >> Include Actual Execution Plan
*/

/* Run following Two select together and see the execution plan
Compare the execution cost */

-- Select Table
SELECT ID, City
FROM UDFEffect
WHERE City = 'Salk Lake City'
GO
-- Select Table
SELECT ID, City
FROM UDFEffect
WHERE RTRIM(LTRIM(City)) = 'Salk Lake City'
GO

/*	Question : What is the reason for UDF reducing performance? 
	Question : How to solve the issue? */

/* Adding Computed Column can solve the performance degradation problem.*/

-- Add Computed Column
ALTER TABLE dbo.UDFEffect ADD
	CityTrim  AS RTRIM(LTRIM(City))
GO

/* Run following Two select together and see the execution plan
Compare the execution cost */

-- Select Complete Table
SELECT ID, City
FROM UDFEffect
WHERE City = 'Salk Lake City'
GO
-- Select Complete Table
SELECT ID, City
FROM UDFEffect
WHERE CityTrim = 'Salk Lake City'
GO
/* Question : Why computed column only does not reduce performance? */

-- Create non clustered index on Computed Column
CREATE NONCLUSTERED INDEX IX_UDFEffect_CityTrim
ON UDFEffect (CityTrim,ID,City)
GO

/* Run following Two select together and see the execution plan
Compare the execution cost */
-- Select Complete Table
SELECT ID, City
FROM UDFEffect
WHERE City = 'Salk Lake City'
GO
-- Select Complete Table
SELECT ID, City
FROM UDFEffect --WITH(INDEX = IX_UDFEffect_CityTrim)
WHERE CityTrim = 'Salk Lake City'
GO

/* Observation : Usage of UDF can reduce performance, 
	incorporating UDF logic into Computed Column and 
	creating Index on that column improves performance. */

-- Clean up Database
DROP TABLE UDFEffect
GO