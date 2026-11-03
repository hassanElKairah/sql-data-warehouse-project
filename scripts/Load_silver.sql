 /*
===============================================================================
Stored Procedure: Load Silver Layer
===============================================================================

Script Purpose:
    This stored procedure loads and transforms data from the Bronze Layer
    into the Silver Layer of the Data Warehouse.

    It performs data cleansing, standardization, normalization, and
    data quality improvements to prepare reliable datasets for the
    Gold Layer.

Main Operations:
    1. Truncate existing Silver tables before loading new data.
    2. Extract data from the corresponding Bronze tables.
    3. Apply data cleansing and transformation rules.
    4. Insert cleaned and standardized data into Silver tables.
    5. Track the execution time of each table and the entire process.
    6. Handle errors using TRY...CATCH.

Data Transformations:
    - Remove duplicate customer records using ROW_NUMBER().
    - Trim unnecessary spaces from text fields.
    - Standardize gender and marital status values.
    - Replace NULL values with appropriate defaults.
    - Extract product categories and standardize product identifiers.
    - Calculate product end dates using LEAD() and DATEADD().
    - Validate and convert sales dates.
    - Correct inconsistent sales amounts and product prices.
    - Standardize customer identifiers and country names.
    - Handle invalid birth dates.

Source Tables:
    - Bronze.crm_cust_info
    - Bronze.crm_prd_info
    - Bronze.crm_sales_details
    - Bronze.erp_CUST_AZ12
    - Bronze.erp_LOC_A101
    - Bronze.erp_PX_CAT_G1V2

Target Tables:
    - Silver.crm_cust_info
    - Silver.crm_prd_info
    - Silver.crm_sales_details
    - Silver.erp_CUST_AZ12
    - Silver.erp_LOC_A101
    - Silver.erp_PX_CAT_G1V2

Execution Monitoring:
    GETDATE() records the start and end times.
    DATEDIFF() calculates execution duration in seconds.
    PRINT displays loading progress and execution statistics.

Error Handling:
    TRY...CATCH captures SQL execution errors and displays
    diagnostic information using ERROR_MESSAGE(),
    ERROR_NUMBER(), and ERROR_STATE().

Warning:
    This procedure uses TRUNCATE TABLE before each load.
    Existing Silver data is removed and replaced with newly
    transformed data from the Bronze Layer.

===============================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN 
DECLARE @start_time DATETIME , @end_time DATETIME  , @start_bash_time DATETIME , @end_bash_time DATETIME ;
    
	BEGIN TRY 
	    
		SET @start_bash_time = GETDATE()  
		SET  @start_time = GETDATE()  
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE Silver.crm_cust_info 
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.crm_cust_info  (
			cst_id ,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status ,
			cst_gndr ,
			cst_create_date
		)
		SELECT 
			cst_id ,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname)  cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'S'  THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M'  THEN 'Maried'
				ELSE 'n/a'
			END cst_marital_status ,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'F'  THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M'  THEN 'Male'
				ELSE 'n/a'
			END cst_gndr ,
			cst_create_date
		FROM(
		SELECT 
		*,
		ROW_NUMBER()  OVER(PARTITION BY cst_id Order by cst_create_date DESC)  flag_last
		FROM Bronze.crm_cust_info
		WHERE cst_id IS NOT NULL 
		)t WHERE flag_last = 1
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';




	    SET @start_time = GETDATE()
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE Silver.crm_prd_info  
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key ,
			prd_nm , 
			prd_cost ,
			prd_line ,
			prd_start_dt , 
			prd_end_dt
		)

		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key , 1 , 5) , '-' , '_') cat_id,
			SUBSTRING(prd_key , 7 , LEN(prd_key)) prd_key,
			prd_nm , 
			ISNULL(prd_cost ,0)   AS prd_cost ,
			prd_line ,
			prd_start_dt , 
			DATEADD(
			DAY,
			-1,
			LEAD(prd_start_dt) OVER(
				PARTITION BY prd_key
				ORDER BY prd_start_dt
			   )
			) AS prd_end_dt
		FROM Bronze.crm_prd_info
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';


	


	    SET @start_time = GETDATE()
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE Silver.crm_sales_details  
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.crm_sales_details  (
			sls_ord_num ,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt , 
			sls_ship_dt , 
			sls_due_dt ,
			sls_sales,
			sls_quantity , 
			sls_price
		)
		SELECT 
			sls_ord_num ,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8  THEN NULL
				ELSE  CAST(CAST( sls_order_dt  AS VARCHAR ) AS DATE)   
			END sls_order_dt , 
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt )!= 8  THEN NULL
				ELSE  CAST(CAST( sls_ship_dt  AS VARCHAR ) AS DATE)   
			END sls_ship_dt , 
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt )!= 8  THEN NULL
				ELSE  CAST(CAST( sls_due_dt  AS VARCHAR ) AS DATE)   
			END sls_due_dt ,
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales!=  abs(sls_price )* sls_quantity
			THEN abs(sls_price )* sls_quantity
			ELSE sls_sales
			END sls_sales,
			sls_quantity , 
			CASE WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price!=  abs(sls_sales )/ NULLIF(sls_quantity , 0)
			THEN abs(sls_sales )/ NULLIF(sls_quantity , 0) 
			ELSE sls_price
			END sls_price
		FROM Bronze.crm_sales_details
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';

	
	    SET @start_time = GETDATE()
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE  Silver.erp_CUST_AZ12 
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.erp_CUST_AZ12 ( 
			cid , 
			bdate,
			gen
		)
		SELECT
			CASE 
				WHEN CID LIKE  'NAS%' THEN SUBSTRING(CID , 4 , LEN(CID)) 
				ELSE CID
			END cid , 


			CASE 
				WHEN BDATE < '1924-01-01' OR BDATE > GETDATE()  THEN NULL 
				ELSE BDATE
			END bdate,
			CASE 
				WHEN UPPER(TRIM(GEN)) IN  ('F' , 'Female')  THEN 'Female'
				WHEN UPPER(TRIM(GEN)) IN  ('M' , 'Male')  THEN 'Male'
				ELSE 'n/a'
			END gen
		FROM Bronze.erp_CUST_AZ12
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';


		--handle the erp tables 
		SET @start_time = GETDATE()
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE  Silver.erp_LOC_A101
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.erp_LOC_A101 (cid , Country)
		SELECT  
		REPLACE (CID,'-' ,'')  cid , 
		CASE 
			WHEN  TRIM(CNTRY) IN  ('DE'  ,'Germany')  THEN 'Germany'  
			WHEN  TRIM(CNTRY )IN ('USA' ,  'US' , 'United States')  THEN 'United States'
			WHEN TRIM(CNTRY )= ''  OR CNTRY IS NULL  THEN 'n/a' 
			ELSE TRIM(CNTRY)
		END Country
		FROM Bronze.erp_LOC_A101
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';


		SET @start_time = GETDATE();
		PRINT' trunciting the tables before the inserting :';
		TRUNCATE TABLE  Silver.erp_PX_CAT_G1V2 
		PRINT'>> Inserting the data into the table : ';
		INSERT INTO Silver.erp_PX_CAT_G1V2(  id,
						cat ,
						Subcat ,
						Maintenance )
		SELECT 
			ID id , 
			CAT cat , 
			SUBCAT Subcat , 
			MAINTENANCE AS Mantenance 
		FROM Bronze.erp_PX_CAT_G1V2
		SET @end_time = GETDATE()
		PRINT'=======================================================================================================';
		PRINT'THE TOTAL Time of this insert is : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time) AS NVARCHAR);
		PRINT'=======================================================================================================';


		SET @end_bash_time = GETDATE();
		PRINT'=======================================================================================================';
		PRINT'THE WHOLE duration of the process : ' + CAST(DATEDIFF(SECOND , @start_bash_time ,  @end_bash_time) AS NVARCHAR);
		PRINT'=======================================================================================================';
	END TRY 

	BEGIN CATCH
	    PRINT'=======================================================================================================';
		PRINT'ERROR OCCUR In the load Silver ';
		PRINT'=======================================================================================================';
		print'error message '  + CAST(ERROR_STATE() AS NVARCHAR) ;
		PRINT'error message :'  + ERROR_MESSAGE();
		PRINT'error message :'  +CAST( ERROR_NUMBER() AS NVARCHAR);

	END CATCH 

END 
