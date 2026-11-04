# Data Catalog — Gold Layer

## Overview

The Gold Layer represents the business-ready data of the Data Warehouse, designed to support analytical queries, business intelligence, and reporting.

It follows a **Star Schema** dimensional model consisting of two dimension views and one fact view.

The Gold Layer integrates cleaned and standardized data from the Silver Layer, combining customer, product, and sales information into an analytical data model.

### Gold Layer Objects

| View Name | Object Type | Description |
|---|---|---|
| gold.dim_customers | Dimension View | Customer demographic and geographic information |
| gold.dim_products | Dimension View | Product details, categories, and attributes |
| gold.fact_sales | Fact View | Sales transactions, customer and product references, and sales measures |

All three objects are implemented as SQL Server views.

---

## 1. gold.dim_customers

**Purpose:** Stores customer information enriched with demographic and geographic data from the CRM and ERP source systems.

**Source Views/Tables:**
- `Silver.crm_cust_info`
- `Silver.erp_CUST_AZ12`
- `Silver.erp_LOC_A101`

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| customer_key | BIGINT | Surrogate key generated using ROW_NUMBER() to uniquely identify each customer row in the view result. |
| customer_id | INT | Original numerical customer identifier from the CRM source system. |
| customer_number | NVARCHAR(50) | Alphanumeric customer identifier used to integrate CRM and ERP information. |
| first_name | NVARCHAR(50) | Customer's first name. |
| last_name | NVARCHAR(50) | Customer's last name or family name. |
| country | NVARCHAR(50) | Customer's country obtained from the ERP location data. |
| marital_status | NVARCHAR(50) | Standardized marital status, such as 'Married', 'Single', or 'n/a'. |
| gender | NVARCHAR(50) | Customer gender, prioritizing CRM values when they are not 'n/a', otherwise falling back to ERP gender or 'n/a'. |
| birthdate | DATE | Customer's date of birth obtained from the ERP customer data. |
| create_date | DATE | Date when the customer record was created in the source CRM system. |

### Data Transformation Rules

- Generate a surrogate key using `ROW_NUMBER() OVER (ORDER BY ci.cst_id)`.
- Integrate CRM customer information with ERP demographic and location data using `LEFT JOIN`.
- Use CRM gender when its value is different from `'n/a'`.
- Otherwise, use `COALESCE(ca.gen, 'n/a')` to obtain ERP gender or a default value.
- Include customer birthdates and countries from the ERP source systems.

---

## 2. gold.dim_products

**Purpose:** Provides information about products, including their classification, maintenance requirements, costs, and product lines.

Only product records with a NULL `prd_end_dt` are included, representing the current product records according to the Silver Layer logic.

**Source Tables:**
- `Silver.crm_prd_info`
- `Silver.erp_PX_CAT_G1V2`

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| product_key | BIGINT | Surrogate key generated using ROW_NUMBER() to identify each product row in the view result. |
| product_id | INT | Original numerical product identifier from the CRM source system. |
| product_number | NVARCHAR(50) | Alphanumeric product identifier used to match products with sales transactions. |
| product_name | NVARCHAR(50) | Descriptive name of the product. |
| category_id | NVARCHAR(50) | Identifier representing the product category. |
| category | NVARCHAR(50) | Main product classification, such as Bikes or Components. |
| subcategory | NVARCHAR(50) | More detailed product classification within a category. |
| Maintenance | NVARCHAR(50) | Indicates whether a product requires maintenance. |
| cost | INT | Product cost recorded in the source data, expressed in monetary units. |
| product_line | NVARCHAR(50) | Product line or series to which the product belongs. |
| start_date | DATE | Date from which the product record became effective. |

### Data Transformation Rules

- Generate surrogate keys using `ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key)`.
- Integrate CRM product information with ERP product categories using `LEFT JOIN`.
- Enrich products with category, subcategory, and maintenance information.
- Exclude historical product records using `WHERE pr.prd_end_dt IS NULL`.
- Retain product costs, product lines, and effective start dates.

---

## 3. gold.fact_sales

**Purpose:** Provides transactional sales information for analytical and reporting purposes.

The fact view combines sales records from the Silver Layer with surrogate keys from the Gold customer and product dimensions.

**Source Objects:**
- `Silver.crm_sales_details`
- `gold.dim_products`
- `gold.dim_customers`

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(50) | Alphanumeric sales order identifier from the CRM source system. |
| product_key | BIGINT | Surrogate key referencing the corresponding product record in gold.dim_products. |
| customer_key | BIGINT | Surrogate key referencing the corresponding customer record in gold.dim_customers. |
| sls_order_dt | DATE | Date when the sales order was placed. |
| sls_ship_dt | DATE | Date when the order was shipped. |
| sls_due_dt | DATE | Due date associated with the sales order. |
| sls_sales | INT | Total sales amount associated with the transaction line. |
| sls_quantity | INT | Number of product units ordered. |
| sls_price | INT | Unit price of the product in the sales transaction. |

### Data Transformation Rules

- Retrieve sales transactions from `Silver.crm_sales_details`.
- Match sales product identifiers with `gold.dim_products.product_number`.
- Match sales customer identifiers with `gold.dim_customers.customer_id`.
- Retrieve the corresponding product and customer surrogate keys.
- Use `LEFT JOIN` to preserve sales records even when dimension matches are unavailable.
- Retain cleaned order dates, shipping dates, due dates, sales amounts, quantities, and prices from the Silver Layer.

---

## 4. Data Model Relationships

The Gold Layer uses a **Star Schema** with one central fact view connected to two dimension views.

| Dimension View | Dimension Key | Fact View | Fact Key | Relationship |
|---|---|---|---|---|
| gold.dim_customers | customer_key | gold.fact_sales | customer_key | One-to-Many (1:N) |
| gold.dim_products | product_key | gold.fact_sales | product_key | One-to-Many (1:N) |

### Relationship Description

**Customer Dimension:**

One customer dimension record can be associated with multiple sales records.

**Product Dimension:**

One product dimension record can be associated with multiple sales records.

The relationships are implemented through matching surrogate key values in the SQL views.

### Important Considerations

- The dimension and fact objects are SQL Server views, not physical tables.
- Primary Key and Foreign Key relationships are logical relationships; they are not enforced by constraints on these views.
- Surrogate keys are generated dynamically using ROW_NUMBER() and may change if the underlying data or ordering changes.
- Product and customer surrogate keys may be NULL in the fact view when no matching dimension record is found.
- The order number may appear in multiple fact rows when an order contains multiple product lines.
- The fact view retains transaction-level sales records and is intended for sales-line analysis.

---

## 5. Business Usage

The Gold Layer supports analytical use cases such as:

- **Customer Analysis:** Analyze sales performance by customer, country, gender, or marital status.
- **Product Analysis:** Analyze sales by product, category, subcategory, or product line.
- **Sales Analysis:** Calculate total revenue, quantities sold, and average selling prices.
- **Trend Analysis:** Analyze sales over time using order dates.
- **Business Reporting:** Provide structured datasets for SQL analytics, dashboards, and BI tools.

### Main Business Metrics

| Metric | Description | Calculation |
|---|---|---|
| Total Sales | Total value of recorded sales | SUM(sls_sales) |
| Total Quantity | Total number of product units sold | SUM(sls_quantity) |
| Total Orders | Number of distinct sales orders | COUNT(DISTINCT order_number) |
| Average Unit Price | Average unit price across sales lines | AVG(sls_price) |
| Total Customers | Number of customer records in the customer dimension | COUNT(*) from dim_customers |
| Total Products | Number of current product records in the product dimension | COUNT(*) from dim_products |

---

## 6. Data Lineage

The Gold Layer is populated through SQL views that transform and integrate cleaned Silver Layer data.

**Customer Dimension:**

`Silver.crm_cust_info + Silver.erp_CUST_AZ12 + Silver.erp_LOC_A101 → gold.dim_customers`

**Product Dimension:**

`Silver.crm_prd_info + Silver.erp_PX_CAT_G1V2 → gold.dim_products`

**Sales Fact:**

`Silver.crm_sales_details + gold.dim_products + gold.dim_customers → gold.fact_sales`

The final model provides business-ready customer, product, and sales data for analytical consumption.
