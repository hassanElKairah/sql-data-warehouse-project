/*
===========================================================
Create Database and Schemas
===========================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse'
    after checking if it already exists.

    If the database already exists, it is dropped and recreated.

    The script also creates three schemas:
    'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse'
    database if it already exists.

    All existing data inside the database will be deleted.
===========================================================
*/

USE master;
GO

-- Drop and recreate the DataWarehouse database
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;
GO

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

-- Use the new database
USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
