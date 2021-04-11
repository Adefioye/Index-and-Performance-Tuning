/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Lookup Vs Seek Vs Scan - what went wrong.

****************************************************************/

USE AdventureWorks2019
GO

-- CTRL + M 
-- Enforces Key Lookup
-- Step 0
SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807
GO

-- Create Non clustered Index
CREATE NONCLUSTERED INDEX [IX_HumanResources_Employee_Example]
		 ON HumanResources.Employee 
(
	NationalIDNumber ASC, HireDate, MaritalStatus 
) ON [PRIMARY]
GO

-- Removes Key Lookup, but it still enforces Index Scan
-- Step 1
SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807
GO

-- Removes Key Lookup and it enforces Index Seek
-- Step 2
SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807'
GO

/* Removes Key Lookup and it enforces Index Seek 
	and no CONVERT_IMPLICIT */
-- Step 3

SELECT NationalIDNumber, HireDate, MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = N'14417807'
GO

-- Clean up
-- Drop Index

DROP INDEX [IX_HumanResources_Employee_Example] 
			ON HumanResources.Employee  WITH ( ONLINE = OFF )
GO