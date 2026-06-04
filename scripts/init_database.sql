/*
Crate database and schemas
*/
use master;
Go
IF EXISTS (select 1 from sys.databases where name ='DataWarehouse')
Begin
	Alter database DataWarehouse Set SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP database DataWarehouse
END
GO
-- Create DB
Create Database DataWarehouse;
GO
use DataWarehouse;
-- Createt Schemas
Create Schema bronze;
GO
Create Schema silver;
Go
Create Schema gold;
Go


