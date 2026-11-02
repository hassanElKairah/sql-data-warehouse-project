/*
===============================================================================
Bronze Layer Setup and Data Load
===============================================================================

Script Purpose:
    This script prepares and loads the Bronze Layer of the Data Warehouse.

    It performs two main tasks:

    1. Creates the Bronze tables for the CRM and ERP source systems.
       If a table already exists, it is dropped and recreated.

    2. Loads raw CSV data into the Bronze tables using BULK INSERT.
       Before each load, the target table is truncated to remove old data.

    The script also includes execution-time tracking for each table and
    TRY...CATCH error handling to make the loading process easier to monitor
    and troubleshoot.

Bronze Layer Principle:
    Data is loaded as close as possible to the source format with minimal
    transformations. Data cleaning and standardization are handled later
    in the Silver Layer.

Source Systems:
    - CRM
    - ERP

Main Operations:
    - DROP TABLE / CREATE TABLE
    - TRUNCATE TABLE
    - BULK INSERT
    - GETDATE / DATEDIFF
    - TRY...CATCH
    - PRINT messages for monitoring

===============================================================================
*/
CREATE OR ALTER PROCEDURE Bronze.load_Bronze  AS
BEGIN
    
    DECLARE  @start_time DATETIME , @end_time DATETIME  , @start_bash_time DATETIME , @end_bash_time DATETIME ;
    set @start_bash_time = GETDATE()
    BEGIN TRY 
        
            
            IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
                DROP TABLE Bronze.crm_cust_info;

            CREATE TABLE Bronze.crm_cust_info (
                cst_id INT,
                cst_key NVARCHAR(50),
                cst_firstname NVARCHAR(50),
                cst_lastname NVARCHAR(50),
                cst_marital_status NVARCHAR(50),
                cst_gndr NVARCHAR(50),
                cst_create_date DATE
            );


            IF OBJECT_ID('Bronze.crm_prd_info', 'U') IS NOT NULL
                DROP TABLE Bronze.crm_prd_info;

            CREATE TABLE Bronze.crm_prd_info (
                prd_id INT,
                prd_key NVARCHAR(50),
                prd_nm NVARCHAR(50),
                prd_cost INT,
                prd_line NVARCHAR(50),
                prd_start_dt DATE,
                prd_end_dt DATE
            );


            IF OBJECT_ID('Bronze.crm_sales_details', 'U') IS NOT NULL
                DROP TABLE Bronze.crm_sales_details;

            CREATE TABLE Bronze.crm_sales_details (
                sls_ord_num NVARCHAR(50),
                sls_prd_key NVARCHAR(50),
                sls_cust_id INT,
                sls_order_dt NVARCHAR(50),
                sls_ship_dt NVARCHAR(50),
                sls_due_dt NVARCHAR(50),
                sls_sales INT,
                sls_quantity INT,
                sls_price INT
            );


            -- =============================================
            -- ERP TABLES
            -- =============================================

            IF OBJECT_ID('Bronze.erp_CUST_AZ12', 'U') IS NOT NULL
                DROP TABLE Bronze.erp_CUST_AZ12;

            CREATE TABLE Bronze.erp_CUST_AZ12 (
                CID NVARCHAR(50),
                BDATE DATE,
                GEN NVARCHAR(50)
            );


            IF OBJECT_ID('Bronze.erp_LOC_A101', 'U') IS NOT NULL
                DROP TABLE Bronze.erp_LOC_A101;

            CREATE TABLE Bronze.erp_LOC_A101 (
                CID NVARCHAR(50),
                CNTRY NVARCHAR(50)
            );


            IF OBJECT_ID('Bronze.erp_PX_CAT_G1V2', 'U') IS NOT NULL
                DROP TABLE Bronze.erp_PX_CAT_G1V2;

            CREATE TABLE Bronze.erp_PX_CAT_G1V2 (
                ID NVARCHAR(50),
                CAT NVARCHAR(50),
                SUBCAT NVARCHAR(50),
                MAINTENANCE NVARCHAR(50)
            );
            PRINT '====================================================';
            PRINT'Loading Bronze Layer  :';
            PRINT '====================================================';



            PRINT '====================================================';
            PRINT'BULK INSERT CRM TABLES';
            PRINT '====================================================';
            set @start_time = GETDATE();
            PRINT  'truncating table ';
            TRUNCATE TABLE Bronze.crm_cust_info;
            PRINT  'LOAD data into table : Bronze.crm_cust_info';
            BULK INSERT Bronze.crm_cust_info
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_crm\cust_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            set @end_time = GETDATE();

            PRINT 'time of operation  ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);


            set @start_time = GETDATE();
            PRINT  'truncating table ';
            TRUNCATE TABLE Bronze.crm_prd_info
            PRINT  'LOAD data into table : Bronze.crm_prd_info';
            BULK INSERT Bronze.crm_prd_info
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_crm\prd_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            set @end_time = GETDATE() ;
            PRINT 'time of operation ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);



            PRINT 'Truncating table';

            set @start_time = GETDATE()
            TRUNCATE TABLE Bronze.crm_sales_details;
            
            PRINT  '>>LOAD data into table : Bronze.crm_sales_details';
            BULK INSERT Bronze.crm_sales_details
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_crm\sales_details.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            set @end_time = GETDATE() ;
            PRINT 'time of operation ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);




            PRINT '====================================================';
            PRINT'BULK INSERT ERP TABLES';
            PRINT '====================================================';
            PRINT'Truncating Table';
            set @start_time = GETDATE() ;
            TRUNCATE TABLE Bronze.erp_CUST_AZ12;
            PRINT  '>>LOAD data into table : Bronze.erp_CUST_AZ12';
            BULK INSERT Bronze.erp_CUST_AZ12
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_erp\CUST_AZ12.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            set @end_time = GETDATE() ;
            PRINT 'time of operation ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);


            PRINT'Truncating table ';
            set @start_time = GETDATE() ;
            TRUNCATE TABLE Bronze.erp_LOC_A101;
            PRINT  '>>LOAD data into table : Bronze.erp_LOC_A101';
            BULK INSERT Bronze.erp_LOC_A101
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_erp\LOC_A101.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            
            set @end_time = GETDATE() ;
            PRINT 'time of operation ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);

            PRINT'Truncating table ';
            set @start_time = GETDATE() ;
            TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;
            PRINT  '>>LOAD data into table : Bronze.erp_PX_CAT_G1V2';
            BULK INSERT Bronze.erp_PX_CAT_G1V2
            FROM 'C:\Users\USER\Desktop\DataWareHouseProject\sql-data-warehouse-project-main\01_datasets\source_erp\PX_CAT_G1V2.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK
            );
            set @end_time = GETDATE() ;
            PRINT 'time of operation ' + CAST( DATEDIFF(second ,@start_time , @end_time ) AS NVARCHAR);
            set @end_bash_time = GETDATE() ;
            PRINT 'time of the whole operation : ' + CAST( DATEDIFF(second ,@start_bash_time , @end_bash_time ) AS NVARCHAR)  +'s';


    END TRY 
    BEGIN CATCH 
    PRINT '======================================================';
    PRINT 'ERROR OCCORD DURING LOADING BRONZE LAYER';
    PRINT'Error Message'  + ERROR_MESSAGE() ;
    PRINT'Error Message'  + ERROR_STATE() ;
    PRINT'  Error Message' + CAST( ERROR_NUMBER()  AS NVARCHAR);
    END CATCH 
    

END 
