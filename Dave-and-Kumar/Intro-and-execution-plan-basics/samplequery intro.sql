USE AdventureWorks2019
GO
-- Enable Execution Plan
-- CTRL+M 
SELECT [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
  FROM [Sales].[SalesOrderDetail]
GO

SELECT SUM([OrderQty])
      ,[ProductID]
  FROM [Sales].[SalesOrderDetail]
  GROUP BY [ProductID]
GO

USE AdventureWorks2019
GO

SELECT VendorID, EmployeeID
  FROM [Purchasing].[PurchaseOrderHeader]
  WHERE VendorID = 1540 AND EmployeeID = 258
GO
