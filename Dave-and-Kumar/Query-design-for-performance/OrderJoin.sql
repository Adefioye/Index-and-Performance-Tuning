/****************************************************************
Description: Order of Joins example
****************************************************************/
USE AdventureWorks2019
GO

-- Record Count Query
SELECT COUNT(*) --395
FROM [Production].[ProductListPriceHistory]
SELECT COUNT(*) --504
FROM [Production].[Product]
SELECT COUNT(*) --72591
FROM [Production].[WorkOrder]
GO



  /**********************************/
 /*** Order of Tables INNER JOIN ***/
/**********************************/
-- Option 1
SELECT p.ProductID
FROM [Production].[Product] p
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
INNER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
GO
-- Option 2
SELECT p.ProductID
FROM [Production].[Product] p
INNER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
GO
-- Option 3
SELECT p.ProductID
FROM [Production].[WorkOrder] wo
INNER JOIN [Production].[Product] p ON p.ProductID = wo.ProductID
INNER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID=pph.ProductID
GO

  /**************************/
 /*** Let us be creative ***/
/**************************/
-- Parentheses Use
SELECT p.ProductID
FROM [Production].[Product] p
INNER JOIN ([Production].[ProductListPriceHistory] pph 
INNER JOIN [Production].[WorkOrder] wo ON pph.ProductID = wo.ProductID)
ON p.ProductID=pph.ProductID
GO
-- Condition Manipulation
SELECT p.ProductID
FROM [Production].[Product] p 
INNER JOIN [Production].[ProductListPriceHistory] pph -- No Condition
INNER JOIN [Production].[WorkOrder] wo 
ON pph.ProductID = wo.ProductID -- Double Condition 
ON p.ProductID=pph.ProductID
GO


  /**********************************/
 /*** Order of Tables OUTER JOIN ***/
/**********************************/
-- Option 1
SELECT p.ProductID
FROM [Production].[Product] p
LEFT OUTER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID = pph.ProductID
LEFT OUTER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
GO
-- Option 2
SELECT p.ProductID
FROM [Production].[Product] p
LEFT OUTER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
LEFT OUTER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID = pph.ProductID
GO
-- Option 3
SELECT p.ProductID
FROM [Production].[WorkOrder] wo
LEFT OUTER JOIN [Production].[Product] p ON p.ProductID = wo.ProductID
LEFT OUTER JOIN [Production].[ProductListPriceHistory] pph ON p.ProductID = pph.ProductID
GO
-- Option 4
-- Error
SELECT p.ProductID
FROM [Production].[ProductListPriceHistory] pph
LEFT OUTER JOIN [Production].[Product] p ON p.ProductID = wo.ProductID
LEFT OUTER JOIN [Production].[WorkOrder] wo ON p.ProductID = wo.ProductID
GO
