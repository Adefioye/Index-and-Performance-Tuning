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
*/

/*
	NON-CLUSTERED INDEXES

A nonclustered index is also structured as a B-tree and in many respects is similar to a 
clustered index. The main difference is that a leaf row in a nonclustered index contains
only the index key columns and a row locator. The content of the row locator depends on 
whether the underlying table is organized as a heap or as B-tree.
*/
