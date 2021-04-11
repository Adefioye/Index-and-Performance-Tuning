/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course ©Pluralsight.

Description: Script to show UnUsed Indexes using DMVs

****************************************************************/

SELECT TOP 25
o.name AS ObjectName
, i.name AS IndexName
, i.index_id AS IndexID  
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, 'DROP INDEX ' + QUOTENAME(i.name) 
+ ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.object_id)) as 'drop statement'
FROM sys.dm_db_index_usage_stats dm_ius  
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.object_id = i.object_id   
INNER JOIN sys.objects o on dm_ius.object_id = o.object_id
INNER JOIN sys.schemas s on o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.object_id 
				FROM sys.partitions p GROUP BY p.index_id, p.object_id) p 
		ON p.index_id = dm_ius.index_id AND dm_ius.object_id = p.object_id
WHERE OBJECTPROPERTY(dm_ius.object_id,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()   
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
GO
