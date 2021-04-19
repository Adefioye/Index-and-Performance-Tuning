-- Demo script for Analyzing Clustered Table 
-- Structures demo - Part II.

-- NOTE: This script requires the completion of
-- these demos/scripts:
--  * M2_Demo02a_Setup_AnalyzingCLStructures.sql
--  * Demo/Setup for sp_SQLskills_SQL2012_helpindex

USE [IndexInternals];
GO

-- We've seen the difference in size - can we see
-- exactly why there's a difference in the structures?

-- sp_helpindex doesn't really tell the whole story

-- Let's use my version to see what it shows:
EXEC sp_SQLskills_helpindex N'EmployeeCLLastName';
EXEC sp_SQLskills_helpindex N'EmployeeCLGUID';
EXEC sp_SQLskills_helpindex N'Employee';
GO