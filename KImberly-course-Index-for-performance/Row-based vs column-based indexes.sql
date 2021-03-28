/* INDEXING	*/

/*	Row-based indexes and column-based indexes	*/

/*
row-based indexes have 2 main components: the leaf level and the non-leaf level

Leaf(bottom) level: This contains sth for every table row in indexed order

Non-leaf level(s) or B-tree: This contains sth specifically representing the FIRST value from
every page of the level below.

Column-store or column-based indexes: 

The followings are features of column-based indexes:

- All rows for a single column are combined together. This helps to better compress data
- Data is segmented in a groups of 1 million rows which helps for better batch processing of data
- SQL Server can do segment elimination which helps to reduce number of segments processed
- Parallelization through batch mode

	CHOICE OF INDEXES

The choice for indexes depend on the workload

	For OLTP that require modification and highly selective point queries, we use row-based clustered indexes.
we also use secondary row-based nonclustered indexes to aid search and find individual rows
. We might also use nonclustered columnstore for older system used for data analytics as oppose
to the current system where we focus on performance for OLTP.

	For Desison support system or relational DW, where we prioritize large scale aggregates,
or perhaps use a high percentage of the entire dataset. We mainly use clustered columnstore
index


	Row-based vs Column-based indexes

- Row-based indexes support data compression. However, column-based indexes support better
compression because columns of data are packed in a row.

- Row-based indexes support point queries(seeks) while columnstore indexes support large-scale aggregations

- Row-based indexes support wide variety of scans(full and/or partial table scans), nonclustered
covering scans and nonclustered covering scans with partial scans. However, columnstore indexes
support partial scans with segment elimination, and combine with partitioning for further elimination.

	Row-based vs Column-based indexes problems

Row-based indexes problems

-  More tuning work is required. apt indexes are needed per query. Even after doing this,
more index tuning is done on the server as well.

- It is not easy to compress data(storing multiple columns of data together) using row-based
indexes.

Column-based indexes problems

- It is difficult to perform seek operation with it. Works well for aggregate data. It works
really well for version 2016 and above.


	Indexed views vs Columnstore indexes

RDW workload was primarily handled with indexed views before the advent of columstore indexes.

- Indexed views have limited use in non-Enterprise editions while columnstore indexes were in
Enterprise editions prior to 2016. However, columnstore indexes are now available in all editions
in version 2016 and above.

- Indexed views require session settings set on while columnstore indexes require no session setting.

- Indexed views require analysis to be created effectively on a "per query" basis. However, one
columstore indexes is required for one table.

- Index views are more complicated to create and require more storage however columnstore is
easy to create and require a lot less storage.

- Indexed views require more administrative overhead/maintenance. However, columnstore require
less administrative overhead and maintenance.

- Indexed views are costly to maintain during inserts/ updates. However, columnstore have limited
support for DML operations.


*/