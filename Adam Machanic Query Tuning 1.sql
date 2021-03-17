/*	QUERY TUNING 1	*/

/*
To tune queries, one needs to analyze query execution plans and look at performance measures
that difference performance tools give us.

This chapter covers cardinality estimates, indexing features, prioritizing queries for tuning,
index and query information and statistics, temprary tables, set-based versus iterative solutions
query tuning with query revisions and parallel query execution.
*/

/*
	INTERNALS

This section focuses on internal data structures in SQL Server. It starts with a description 
of pages and extents. It then goes into a discussion of organizing tables as a heap versus
as a B-tree and nonclustered indexes

A page is 8KB unit where data is stored. It has the header, body and row offset. The 96-byte
header holds info on pointers to previous and next page, the allocation unit the page belongs to
and the amount of free space on the page.

ROW-OFFSET array is an array of 2-byte pointers that points to every row on the page. The
combination of the previous and next pointers in the page header and the row-offset array enforce
index key order. 

EXTENT is a unit that contains 8 contiguous pages. SQL Server supports 2 types of extents,
called uniform and mixed. For new objects, SQL server allocates one page at a time from mixed 
extents until they reach a size of 8 pages. Hence different pages of the same mixed extents
can belong to  different objects. Once an object reaches a size of 8pages, SQL Server applies
all future allocations of pages for it from uniform extent.

shared global allocation unit(SGAMs) uses bitmap pages to keep track of which extents are 
mixed and make a page available for allocation. global allocation unit(GAMs) uses bitmap pages
to keep track of which extents are free for allocation.

	TABLE ORGANIZATION

A table can be organized either as a heap or B-tree. Technically, if a table as a clustered
index, it is a B-tree, otherwise, it is a heap.

When a primary key is applied to a column, SQL Server enforces it using a clustered index 
except NONCLUSTERED is specified as a keyword on the column, or perhaps if there is an 
existing clustered column.

When a unique constraint is specified, SQL Server enforces it using a nonclustered index
except CLUSTERED keyword is specified.

Because a table must be organized in one of these 2 ways-- heap or B-tree-- table 
organization is known as HOBT.

There are cases when HEAP is better than B-tree. When trying to achieve minimal logging when
doing bulk-import, it is better to use a heap as opposed to a B-tree. Because heap gives
better performance.

Nonclustered indexes can be applied zero or more time on a table. HOBT and nonclustered index
can be separated into partitions. Each partition stores data in a collection of pages called
allocation units. There are 3 of them: IN_ROW_DATA, ROW_OVERFLOW_DATA, LOB_DATA.

IN_ROW_DATA stores fixed-length columns; it also holds variable length columns as long as 
they do not exceed 8000 bytes limit
ROW_OVERFLOW_DATA: This holds VARCHAR, NVARCHAR, VARBINARY, SQL_VARIANT, CLR user-defined typed
data that does not exceed 8000bytes but was moved from the original row becaise it exceeded 
8060 bytes limit
LOB_DATA: holds large object values like VARCHAR(MAX), NVARCHAR(MAX), VARBINARY(MAX) that
exceed 8000bytes, XML, or CLR UDTs. 

The view sys.system_internals_allocation_units holds anchors pointing to the page collections
stored in the allocation units.


*/

/*
	HEAP

IAMs map data in the heap.

	B-TREE

All indexes in SQL Server are B-trees, which are a special case of balanced trees. A B-tree
is a tree where the no leaf is much farther to the root than the other.

At the leaf level, the order of the page might not match the index key order. If page x points
to next page y, and page appears before page x in the file, page y is considered out-of-order.
Logical scan fragmentation(average fragmentation in percent) is measured as the percentage of
out-of-order page. The main cause of logical scan fragmentation is page splits.

The higher the logical scan fragmentation the slower the index order scan if the data is not
cached. There is little impact on index order scans when the data is cached.

SQL Server also maintains IAM pages to map the data stored in the index in file order like
it does in heap. The scan of data based on IAM pages is allocation order scan. SQL Server 
might use this kind of scan when it needs to perform unordered scans of index's leaf level.
Because allocation order scan reads data in file order, its performance is unaffected by
logical scan fragmentation., unlike with index order scans. Therefore allocation order scan
tends to be more efficient than index order scans, especially when the data is not cached.

To remove fragmentation, rebuild the index use ALTER INDEX REBUILD command. FILLFACTOR can
be specified in percent to fill leaf-level pages at the end of rebuild. For example, using
FILLFACTOR = 70, you request to fill leaf pages to 70 percent.

The operands and steps needed to estimaye the number of levels in an index(This calls for
clustered and nonclustered indexes unless explicitly stated otherwise):


*/

-- Get info about pages in data in a database

SELECT * FROM sys.system_internals_allocation_units;

-- The following is used to get level of fragmentation in your index:

SELECT avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats;

SELECT * FROM dbo.Orders;

/*
	NON-CLUSTERED INDEXES

A nonclustered index is also structured as a B-tree and in many respects is similar to a 
clustered index. The main difference is that a leaf row in a nonclustered index contains
only the index key columns and a row locator. The content of the row locator depends on 
whether the underlying table is organized as a heap or as B-tree.

For a heap, the leaf index has index key column and a row locator(RID for short) that points
to the actual data row. 

For a B-tree, however, the leaf index has index key column and a clustering key(values of the
clustered index keys from the row being pointed to and the uniquifier)
*/

/*
	TOOLS TO MEASURE QUERY PERFORMANCE

SQL Server gives a number of tools to measure performance. Nevertheless, the most important 
thing is the user experience. The user mainly cares about 2 things: response time and 
throughput. Response time is the time it takes the first row to return while the throughput
is the time it takes the query to complete.

Performance measures that are of most interest to developers are number of reads, , CPU time
and elapsed time.
*/

SET NOCOUNT ON;
USE PerformanceV3;

/*
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
*/
CHECKPOINT;
DBCC DROPCLEANBUFFERS;

/*
3 main built-in tools are used to analyze and measure query performance:
a graphical execution plan, STATISTICS IO and STATISTICS TIME session option, Extended Events
session with statement completed events.

Graphical execution plan is mainly used to analyze the plan used by the optimizer for a 
query, Session options is needed to measure the performance of a single query. Finally,
Extended Events session is needed to measure the performance of a large number of queries.

*/

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
WHERE orderid <= 10000;

-- To measure query performance with session option

SET STATISTICS IO, TIME ON;

-- To measure performance using extended events session

CREATE EVENT SESSION query_performance ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(WHERE (sqlserver.session_id=(51)));

ALTER EVENT SESSION query_performance ON SERVER STATE = START;
-- replace the above with your session ID

/*
	ACCESS METHODS
*/

/*
	TABLE SCAN/UNORDERED CLUSTERED INDEX SCAN

Table scan typically happens when the SQL Server scans all pages in a table especially when
the underlyinf table is a heap.

Unordered clustered index scan happens when SQL server scans all pages in a table when the
underlying table is a B-tree.

table scan / unordered clustered index scan occur when all data rows are to be fetched or
when a subset of rows are to fetched from a table without proper indexing on the filter.


*/

-- The following codes are for tablescan/unordered clustered index scan

-- Create Orders2 table

DROP TABLE IF EXISTS dbo.Orders2;

SELECT * INTO dbo.Orders2 FROM dbo.Orders;

-- Create a nonclustered index on dbo.Orders2
ALTER TABLE dbo.Orders2 ADD CONSTRAINT PK_Orders2 PRIMARY KEY NONCLUSTERED(orderid)

SET STATISTICS IO, TIME ON;

-- Query on a heap

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders2;
/*
dbo.Orders2 is a heap because it has no clustered index.

The logical operation for the access method in the above query is a table scan and the physical
operation is a heap scan which makes use of an allocation scan order using IAM pages
*/

-- Query on a B-tree


SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders;
/*
dbo.Orders is a nonclustered index table because it has a primary key which by default is enforced
using a clustered index.

The logical operation is a table scan because all rows are fetched. However, the physical 
operation is a clustered index scan.

The fact that Order is not needed in fetching the data rows leave the storage engine to 
determine either of 2 scans-- Index order scan(scan on the leaf of index following a linked
list) or allocation scan order(scan based on IAM pages). The choice between these 2 is gonna be 
based on performance or data consistency.
*/

/*
	UNORDERED COVERING NON-CLUSTERED INDEX SCAN

Unordered covering nonclustered index is similar to unordered clustered index. The "covering"
concept is specific to query. That is, when all columns in a query is are specified in an
index. 

In an unordered covering nonclustered index, the leaf pages are fewer than in an unordered
clustered index scan because it contains fewer data rows.


*/

--  The followings are code used for exploring covering unordered/ nonclustered index scan

SELECT orderid
FROM dbo.Orders;

SELECT orderid, orderdate
FROM dbo.Orders;

/*
	ORDERED CLUSTERED INDEX SCAN

Ordered clustered index scan is a full scan of the leaf level of an index. It guarantees
that the data given to the next operator is index ordered.

*/

--

SELECT orderid, custid, empid, shipperid, orderdate, filler
FROM dbo.Orders
ORDER BY orderdate;

/*
	ORDERED COVERING NONCLUSTERED INDEX SCAN

Ordered covering nonclustered index scan is similar to ordered clustered index scan.  The 
difference ui that the former is performed on a nonclustered index.
*/

-- The following code shows scan using ordered covering nonclustered index

SELECT orderid, orderdate
FROM dbo.Orders
ORDER BY orderid;

/*
An ordered index scan is used not only when you explicitly request the
data sorted, but also when the plan uses an operator that can benefit from
sorted input data. This can be the case when processing GROUP BY,
DISTINCT, joins, and other requests. This can also happen in the following query:
*/

-- Example of ordered covering nonclustered index scan

SELECT orderid, custid, empid, orderdate
FROM dbo.Orders AS O1
WHERE orderid =
	(SELECT MAX(orderid)
	FROM dbo.Orders AS O2
	WHERE O2.orderdate = O1.orderdate);