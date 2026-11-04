
/*
===============================================================================
DDL Script: Create Gold Layer Views
===============================================================================

Script Purpose:
    This script creates the Gold Layer views of the Data Warehouse,
    following a Star Schema dimensional model.

    It integrates cleaned and standardized data from the Silver Layer
    to provide business-ready datasets for analytics and reporting.

    The script creates two dimension views and one fact view:

    1. gold.dim_customers
       - Combines customer information from CRM and ERP systems.
       - Enriches customer records with demographic and geographic data.
       - Generates surrogate keys using ROW_NUMBER().
       - Standardizes gender values using CASE and COALESCE().

    2. gold.dim_products
       - Combines product information with ERP category data.
       - Generates surrogate keys using ROW_NUMBER().
       - Enriches products with category, subcategory, and maintenance.
       - Filters historical records to retain current products only.

    3. gold.fact_sales
       - Retrieves sales transactions from the Silver Layer.
       - Integrates customer and product surrogate keys using LEFT JOIN.
       - Provides sales amounts, quantities, prices, and order dates.
       - Supports business analysis through the Star Schema.

Main Operations:
    - DROP VIEW if the view already exists.
    - CREATE VIEW to define the Gold Layer objects.
    - Integrate Silver Layer data using LEFT JOIN.
    - Generate surrogate keys using ROW_NUMBER().
    - Apply business rules using CASE and COALESCE().
    - Filter historical product records.

Source Layer:
    Silver Layer

Target Views:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

Important Notes:
    - The Gold Layer uses SQL views, not physical tables.
    - Views retrieve data from the underlying Silver Layer.
    - Surrogate keys generated with ROW_NUMBER() are calculated
      dynamically and may change when the underlying data changes.
    - The fact view uses LEFT JOIN to preserve sales records
      even when matching dimension records are unavailable.
    - DROP VIEW removes the view definition but does not delete
      the underlying Silver Layer data.

===============================================================================
*/


--prepare the dimention and the fact table :
IF OBJECT_ID ('gold.dim_customers'  , 'V')  IS NOT NULL 
   DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers  AS 
SELECT 
    --create the surrogate key 
	ROW_NUMBER()  OVER (ORDER BY ci.cst_id) customer_key,
	ci.cst_id customer_id ,
	ci.cst_key customer_number,
	ci.cst_firstname first_name, 
	ci.cst_lastname last_name, 
	lc.Country  country,
	ci.cst_marital_status marital_status, 
	CASE 
	   WHEN  ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	   ELSE COALESCE(ca.gen , 'n/a') 
	END  gender,
	ca.bdate birthdate ,
	ci.cst_create_date create_date 
FROM Silver.crm_cust_info ci
LEFT JOIN  Silver.erp_CUST_AZ12 ca
  ON ca.cid = ci.cst_key
LEFT JOIN Silver.erp_LOC_A101 lc
  ON lc.cid =  ci.cst_key ;

GO




-- prepare the gold.dim_product
IF OBJECT_ID ('gold.dim_products'  , 'V')  IS NOT NULL 
   DROP VIEW gold.dim_products ;
GO
CREATE VIEW gold.dim_products  AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt , pr.prd_key)  product_key,
	pr.prd_id product_id, 
	pr.prd_key product_number, 
	pr.prd_nm product_name,
	cat.id category_id  ,
	cat.cat   category, 
	cat.Subcat subcategory,
	cat.Maintenance  ,

	pr.prd_cost cost , 
	pr.prd_line product_line , 
	pr.prd_start_dt start_date 
FROM Silver.crm_prd_info  pr
LEFT JOIN Silver.erp_PX_CAT_G1V2 cat
ON cat.id = pr.cat_id
WHERE pr.prd_end_dt IS NULL   ; -- helps to remove the historical data
GO



--Prepare the fact table 
IF OBJECT_ID ('gold.fact_sales'  , 'V')  IS NOT NULL 
   DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
    sls.sls_ord_num  order_number,
	pr.product_key,
	cu.customer_key,

    sls.sls_order_dt,
    sls.sls_ship_dt,
    sls.sls_due_dt,
    sls.sls_sales,
    sls.sls_quantity,
    sls.sls_price
FROM Silver.crm_sales_details sls
LEFT JOIN gold.dim_products  pr
ON pr.product_number = sls.sls_prd_key
LEFT JOIN gold.dim_customers cu
ON sls.sls_cust_id = cu.customer_id;
GO
