/*	CHOOSING THE CLUSTERING KEY	*/

/*
Clustered index is highly recommended for a table. Only ONE can be created per table. The 
logical order of a clustering index is maintained by a doubly linked list. It usually requires
regular and automated maintenance. This is because they are prone to fragmentation. Hence,
it is advised that they are chosen wisely.

When PRIMARY KEY is assigned to a column. SQL Server defaults to UNIQUE CLUSTERED INDEX.

NOTE:
	If CLUSTERED INDEX is not specified explicitly on the PRIMARY KEY and a CLUSTERED 
INDEX already exist. SQL Server will default the PRIMARY KEY column to a nonclustered index.
However, if CLUSTERED INDEX is provided explicitly and a CLUSTERED INDEX already exists. Error
would be thrown and we get to know a clustered INDEX already exists.

E.g:

ALTER TABLE Employee
	ADD CONSTRAINT PK_Employee PRIMARY KEY NONCLUSTERED (EmployeeGUID)

NOTE: PRIMARY KEY does not have to be then CLUSTERING KEY.

PRIMARY KEY is a relation integrity concept. However, CLUSTERING KEY is an internal mechanism 
used by SQL Server to find rows

IF a PRIMARY KEY is a NATURAL KEY, then we likely want to enforce it with a NONCLUSTERED INDEX.

IF no column(or small set of columns) that meet the criteria for a clustering key. It might
just be nice to consider a surrograte column and then cluster it.

	CLUSTERED INDEX KEY CRITERIA

- Clustering key should be unique. IF not unique, SQL Server will uniquify the rows, thereby 
wasting soace and time.
- Clustering key should be static. It should not be a volatile column
- Clustering key should be narrow. that is, as few bytes as possible.
- Non-nullable and fixed width
- Should have an ever-increasing pattern

	CLUSTERING KEY SUGGESTIONS

- Identity column - DateCol, bigint(identity); this meets most of the conditions above



*/