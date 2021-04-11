/****************************************************************

Description: CTE replacement with Temp Tables.

****************************************************************/
USE AdventureWorks2019
GO

-- Sample Database
CREATE TABLE dbo.MyEmployees
(
	EmployeeID smallint NOT NULL,
	FirstName nvarchar(30)  NOT NULL,
	LastName  nvarchar(40) NOT NULL,
	Title nvarchar(50) NOT NULL,
	DeptID smallint NOT NULL,
	ManagerID int NULL,
 CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
);

-- Populate the table with values.
INSERT INTO dbo.MyEmployees VALUES 
 (1, N'Ken', N'Sanchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16,  N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23,  N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);
GO

CREATE TABLE dbo.MyEmployeesHistory
(
	EmployeeID smallint NOT NULL,
	JoinDate datetime NULL,
	LastDate datetime NULL,
	SalaryGroup int,
 CONSTRAINT PK_MyEmployeesHistory PRIMARY KEY CLUSTERED (EmployeeID ASC) 
);
-- Populate the table with values.
INSERT INTO dbo.MyEmployeesHistory VALUES 
 (1,   '12/1/2008', NULL,1)
,(273, '11/1/2007', NULL,2)
,(274, '4/3/2006', NULL,3)
,(275, '5/8/2006', NULL,2)
,(276, '7/9/2005', NULL,3)
,(285, '12/5/2008', NULL,2)
,(286, '6/1/2008', NULL,3)
,(16,  '9/7/2008', NULL,3)
,(23,  '9/9/2008', NULL,2);
GO

-- Example of CTE
WITH Emp_CTE AS (
SELECT FirstName, LastName, Title, EmployeeID, ManagerID
FROM dbo.MyEmployees
)
SELECT *
FROM dbo.MyEmployeesHistory dh INNER JOIN 
		Emp_CTE ecte ON ecte.EmployeeID = dh.EmployeeID
WHERE Title LIKE '%Representative%'
GO

-- Example of Table Variable
DECLARE @TempVar TABLE (
	FirstName nvarchar(30)  NOT NULL,
	LastName  nvarchar(40) NOT NULL,
	Title nvarchar(50) NOT NULL,
	EmployeeID smallint NOT NULL,
	ManagerID int NULL)
INSERT INTO @TempVar (FirstName, LastName, Title, EmployeeID, ManagerID)
SELECT FirstName, LastName, Title, EmployeeID, ManagerID
FROM dbo.MyEmployees

SELECT *
FROM dbo.MyEmployeesHistory dh INNER JOIN 
		@TempVar ecte ON ecte.EmployeeID = dh.EmployeeID
WHERE Title LIKE '%Representative%'
GO

-- Clean up
DROP TABLE dbo.MyEmployees
GO
DROP TABLE dbo.MyEmployeesHistory
GO