/*
	Create a stored procedure for a workload

The workload is in usp_GetPersonInfo file in demo folder in the same dorectory as this file

*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Application].[usp_GetPersonInfo];
GO

CREATE PROCEDURE [Application].[usp_GetPersonInfo] (@PersonID INT)
AS

	SELECT 
		[p].[FullName], 
		[p].[EmailAddress], 
		[c].[FormalName]
	FROM [Application].[People] [p]
	LEFT OUTER JOIN [Application].[Countries] [c] 
		ON [p].[PersonID] = [c].[LastEditedBy]
	WHERE [p].[PersonID] = @PersonID;
GO


/*
	Add counters to PerfMon, then run scripts
*/