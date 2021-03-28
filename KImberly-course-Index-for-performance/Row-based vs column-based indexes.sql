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

*/