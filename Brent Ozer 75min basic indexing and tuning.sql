/*
To find the list of AK pages in a table, we use DBCC IND with 3 parameters,
the databasename, the table name, and -1(to list out all indexes)
*/

DBCC IND('StackOverflow2010', Users, -1);

/*
To see the contents of a page, enable trace flag 3604 for your session and then call
DBCC PAGE with 4 parameters:
database name, file name, page number and 3 to see the details
*/

DBCC TRACEON(3604);
DBCC PAGE('StackOverflow2010', 1, 1022481, 3);
DBCC TRACEOFF(3604);

-- Lets query all user records

SELECT * FROM dbo.Users;

-- Another query
SET STATISTICS IO ON;

/*	Add in a sort , but dont parallelize	*/
SELECT Id
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate OPTION (MAXDOP 1);

/* Go parallel by default	*/
SELECT Id
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

/* Let us compare this 2 queries	*/

SELECT Id
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

SELECT *
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

/*
	TAKE HOME

-- Clustered index may only be on one field, but it contains all of the fields in the table.
-- SQL stores the clustered index on 8KB pages
-- DBCC IND and DBCC PAGE show you the pages
-- Off-row data is a little different- we'll deal with that later
-- Filters are not necessarily more expensive, but sorting without indexes is.
-- The more fields you select, the worse sorting get
*/

/* We need relief

Indexes: copies of the table
Stored in the order we want
Include the fields with want

*/

CREATE INDEX IX_LastAccessDate_Id ON dbo.Users(LastAccessDate, Id);


SELECT Id, DisplayName, Age
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

-- Lets add 2 DisplayNAme and Age to the former 2 columns

CREATE INDEX IX_LastAccessDate_Id_DisplayName_Age 
	ON dbo.Users(LastAccessDate, Id, DisplayName, Age);

-- Lets run the query below again

SELECT Id, DisplayName, Age
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

-- Lets add Location to the attributes above

SELECT Id, DisplayName, Age, Location
FROM dbo.Users
WHERE LastAccessDate > '7/1/2010'
ORDER BY LastAccessDate;

/* 
Every index created has its own statistics.

DBCC statistics can be shown using DBCC SHOW_STATISTICS with 2 parameters:
schema.table_name, name_of_index
*/

DBCC SHOW_STATISTICS('dbo.Users', IX_LastAccessDate_Id);
