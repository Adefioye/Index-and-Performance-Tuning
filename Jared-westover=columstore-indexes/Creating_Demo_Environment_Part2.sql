-- Run this script to follow along with the demo.
USE [master];
GO

-- Checking to see if our database exists and if it does drop it.
IF DATABASEPROPERTYEX ('ABCCompany','Version') IS NOT NULL
BEGIN
	ALTER DATABASE [ABCCompany] SET SINGLE_USER
	WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [ABCCompany];
END
GO

-- Make sure you have at least 10GB to follow along.
CREATE DATABASE [ABCCompany]
 ON PRIMARY 
( NAME = N'ABCCompany', FILENAME = N'C:\Pluralsight\SQLFiles\ABCCompany.mdf' ,SIZE = 100000KB , FILEGROWTH = 100000KB)
 LOG ON 
( NAME = N'ABCCompany_log', FILENAME = N'C:\Pluralsight\SQLFiles\ABCCompany_log.ldf',SIZE = 100000KB , FILEGROWTH = 100000KB)
GO


ALTER DATABASE [ABCCompany] SET RECOVERY SIMPLE;
GO

USE [ABCCompany];
GO

CREATE SCHEMA [Sales];
GO

CREATE TABLE [Sales].[SalesPersonLevel] (
	[Id] int identity(1,1) NOT NULL,
	[LevelName] nvarchar(500) NOT NULL,
	[CreateDate] datetime NOT NULL DEFAULT GETDATE(),
	[ModifyDate] datetime NULL
	CONSTRAINT [PK_SalesPersonLevel] PRIMARY KEY CLUSTERED ([Id]));
GO

INSERT INTO [Sales].[SalesPersonLevel] ([LevelName])
	VALUES	('President'),
			('Manager'),
			('Staff'),
			('Senior Staff');
GO
	
CREATE TABLE [Sales].[SalesPerson] (
	[Id] int identity(1,1) NOT NULL,
	[FirstName] nvarchar(500) NOT NULL,
	[LastName] nvarchar(500) NOT NULL,
	[SalaryHr] decimal(32,2) NULL,
	[ManagerId] int NULL,
	[LevelId] int NOT NULL,
	[Email] nvarchar(500) NULL,
	[StartDate] date NOT NULL,
	[CreateDate] datetime NOT NULL DEFAULT GETDATE(),
	[ModifyDate] datetime NULL
	CONSTRAINT [PK_SalesPerson] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [FK_SalesPersonLevel] FOREIGN KEY ([LevelId]) REFERENCES [Sales].[SalesPersonLevel] ([Id]),
	CONSTRAINT [FK_SalesPersonManagerId] FOREIGN KEY ([ManagerId]) REFERENCES [Sales].[SalesPerson] ([Id]));
GO

INSERT INTO [Sales].[SalesPerson] ([FirstName],[LastName],[SalaryHr],[ManagerId],[LevelId],[Email],[StartDate]) 
	VALUES	('Tom','Jones',300,1,1,'Tom.Jones@ABCCorp.com','1/5/2016'),
			('Sally','Smith',175,1,2,'Sally.Smith@ABCCorp.com','1/7/2018'),
			('Bill','House',100,2,3,'Bill.House@ABCCorp.com','1/8/2018'),
			('Karen','Knocks',100,2,3,'Karen.Knocks@ABCCorp.com','1/15/2017'),
			('Lisa','James',75,2,3,'Lisa.James@ABCCorp.com','6/1/2018'),
			('Kerrie','Friend',125,2,3,'Kerrie.Friend@ABCCorp.com','8/14/2018'),
			('Jason','Henderson',55,2,3,'Jason.Henderson@ABCCorp.com','1/14/2017'),
			('Wanda','Jones',55,2,3,'Tom.Jones@ABCCorp.com','9/1/2017'),
			('Jared','Lee',65,2,3,'Jared.Lee@ABCCorp.com','9/8/2018'),
			('Tammy','Smith',75,2,3,'Tammy.Smith@ABCCorp.com','2/5/2018');
GO


CREATE TABLE [Sales].[SalesTerritoryStatus] (
	[Id] int identity(1,1) NOT NULL,
	[StatusName] nvarchar(500) NOT NULL,
	[CreateDate] datetime NOT NULL DEFAULT GETDATE(),
	[ModifyDate] datetime NULL
	CONSTRAINT [PK_SalesTerritoryStatus] PRIMARY KEY CLUSTERED ([Id]));
GO

INSERT INTO [Sales].[SalesTerritoryStatus] ([StatusName])
	VALUES	('On Hold'),
			('In Progress'),
			('Closed');
GO

CREATE TABLE [Sales].[SalesTerritory] (
	[Id] int identity(1,1) NOT NULL,
	[TerritoryName] nvarchar(500) NOT NULL,
	[Group] nvarchar(500) NULL,
	[StatusId] int NOT NULL,
	[CreateDate] datetime NOT NULL DEFAULT GETDATE(),
	[ModifyDate] datetime NULL
	CONSTRAINT [PK_SalesTerritory] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [FK_StatusId] FOREIGN KEY ([StatusId]) REFERENCES [Sales].[SalesTerritoryStatus] ([Id]));
GO

INSERT INTO [Sales].[SalesTerritory] ([TerritoryName],[Group],[StatusId]) 
	VALUES	('Northwest','North America',2),
			('Northeast','North America',2),
			('Southwest','North America',2),
			('Southeast','North America',1),
			('Canada','North America',3),
			('France','Europe',1),
			('Germany','Europe',2),
			('Australia','Pacific',2),
			('United Kingdom','Europe',3),
			('Spain','Europe',1);
GO

CREATE TABLE [Sales].[SalesOrder] (
	[Id] int identity(1,1) NOT NULL,
	[SalesPerson] int NOT NULL,
	[SalesAmount] decimal(36,2) NOT NULL,
	[SalesDate] date NOT NULL,
	[SalesTerritory] int NOT NULL,
	[OrderDescription] nvarchar(MAX) NULL,
	[CreateDate] datetime NOT NULL DEFAULT GETDATE(),
	[ModifyDate] datetime NULL
	CONSTRAINT [PK_SalesOrder] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [FK_SalesPerson] FOREIGN KEY ([SalesPerson]) REFERENCES [Sales].[SalesPerson] ([Id]),
	CONSTRAINT [FK_SalesTerritory] FOREIGN KEY ([SalesTerritory]) REFERENCES [Sales].[SalesTerritory] ([Id]));
GO