/* ROW-BASED INDEX CONCEPTS	*/

/*

- Even though clustered index is preferable to a heap(unordered table), there are times a heap is
desirable, a typical use case is high performnace data loading and staging tables.

- Unordered data means costly scan is required if no nonclustered indexes

- For most cases, clustered index is a better choice but the clustering key to get access to 
data record should be chosen wisely.


*/

/*
	SCAN DEMO
*/

USE EmployeeCaseStudy;
GO

-- Lets see what table exists

SELECT t.*
FROM sys.tables AS t;

-- Review table definition and indexes
EXEC sp_help 'dbo.Employee';
GO

-- To get insight into what is happening
SET STATISTICS IO ON;
GO

-- Use, Include Actual Execuion Plan

-- Obvious case where a scan must be performed
SELECT e.*
FROM dbo.Employee AS e
WHERE e.LastName LIKE N'%e%';
GO

-- Even a more selective query below uses a scan
SELECT e.*
FROM dbo.Employee AS e
WHERE e.LastName LIKE N'E%';
GO

-- Even a more selective query below uses a scan
SELECT e.*
FROM dbo.Employee AS e
WHERE e.LastName = N'Eaton';
GO

------------------------------------------------------------------------------------------
-- Lets explore Employee Table as a Heap
------------------------------------------------------------------------------------------

-- Review table definition and indexes

EXEC sp_help 'dbo.EmployeeHeap';
GO

-- Obvious case where a scan must be performed
SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.LastName LIKE N'%e%';
GO

-- A more selective query below uses a scan. Why?
SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.LastName LIKE N'E%';
GO

-- A very selective query below uses a scan. Why?
SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.LastName = N'Eaton';
GO


------------------------------------------------------------------------------------------
-- Scan is not limited to "table" scans
------------------------------------------------------------------------------------------

-- Review index definitions again
EXEC sp_help 'dbo.Employees';
GO

-- The below code did an Index scan instead of a table scan. This leads to lower number of IOs
-- This is perhaps because a WHERE clause is absent.

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e;
GO

SELECT e.EmployeeID, e.SSN
FROM dbo.EmployeeHeap AS e;
GO

------------------------------------------------------------------------------------------
-- Scan solely refers to an algorithm that exhaustively search a particular data structure
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- DEMO for SEEK operation
------------------------------------------------------------------------------------------

-- Obvious case where a seek can be performed
SELECT e.*
FROM dbo.Employee AS e
WHERE e.EmployeeID = 12345;
GO

-- The following is a less obvious case. yet, a seek is performed. This perhaps could be 
-- because a subset of data of the clustered index is extracted

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e
WHERE e.SSN = '749-21-9445';
GO

------------------------------------------------------------------------------------------
-- Lets explore Employee Table as a Heap
------------------------------------------------------------------------------------------

-- To make EmployeeHeap table perform a seek, we performed higly narrow queries
SELECT e.EmployeeID
FROM dbo.EmployeeHeap AS e
WHERE e.EmployeeID = 12345;
GO

SELECT e.SSN
FROM dbo.Employee AS e
WHERE e.SSN = '749-21-9445';
GO

------------------------------------------------------------------------------------------
-- Seek however is an algorithm to selectively search a particular index structure
------------------------------------------------------------------------------------------


/*
	NONCLUSTERED INDEXES

	DEMO BOOKMARK LOOKUP
*/

-- Thre is nonclustered index on SSN. However, the query info is higher than the info in the index.
-- Hoence there is a key lookup to other info in the actual records.
SELECT e.*
FROM dbo.Employee AS e
WHERE e.SSN = '749-21-9445';
GO

------------------------------------------------------------------------------------------
-- Lets explore Employee Table as a Heap
------------------------------------------------------------------------------------------

-- This results in bookmark(RID) lookup from a nonclustered to a heap
SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.EmployeeID = 12345;
GO

-- This results in bookmark(RID) lookup from a nonclustered to a heap
SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.SSN = '749-21-9445';
GO
