# SQL Data Warehouse & Analytics Project

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Data Engineering](https://img.shields.io/badge/Data_Engineering-0078D4?style=for-the-badge)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-2EA043?style=for-the-badge)

## 📌 Project Overview

Welcome to my **SQL Data Warehouse and Analytics Project**!

This project demonstrates the design and implementation of a modern data warehouse using **Microsoft SQL Server**, following the Medallion Architecture (Bronze, Silver, and Gold).

The main objective is to consolidate raw sales data from two business systems, **CRM and ERP**, into a centralized, clean, and structured data warehouse, enabling efficient analytical queries, business intelligence, and data-driven decision-making.

This end-to-end project covers the essential stages of data engineering, including:

- **Data Architecture:** Designing a modern data warehouse using the Medallion Architecture.
- **Data Ingestion:** Extracting and loading raw CSV data into SQL Server.
- **Data Transformation:** Cleaning, standardizing, and integrating data.
- **Data Modeling:** Designing dimensional and fact views using a Star Schema.
- **Data Quality:** Implementing validation checks to ensure data consistency and reliability.
- **Data Documentation:** Documenting data architecture, models, transformations, and lineage.
- **SQL Analytics:** Preparing business-ready datasets for analytical queries and reporting.

The project was developed as a hands-on learning experience, inspired by the **Data With Baraa SQL Data Warehouse Project**, with my own implementation, SQL scripts, and documentation.

---

## 🏗️ Data Architecture

The data warehouse follows the **Medallion Architecture**, organized into three main layers:

**Bronze → Silver → Gold**

### Architecture Diagram

![Data Warehouse Architecture](02_docs/data_architecture.png)

### 1. Bronze Layer — Raw Data

The Bronze Layer is responsible for ingesting raw data from the CRM and ERP source systems.

**Main characteristics:**

- Ingest raw data from CSV files.
- Preserve original source values.
- Use SQL Server tables for raw data storage.
- Perform full-load ingestion using `BULK INSERT`.
- Apply `TRUNCATE TABLE` before reloading datasets.
- Implement stored procedures for automated data loading.
- Track execution time and handle errors using `TRY...CATCH`.

### 2. Silver Layer — Cleaned & Standardized Data

The Silver Layer transforms raw data into clean, consistent, and reliable datasets.

**Main transformations:**

- Remove duplicate records.
- Handle NULL and missing values.
- Standardize gender and marital status values.
- Normalize product identifiers and category information.
- Convert and validate date formats.
- Correct inconsistent sales amounts and prices.
- Integrate cleaned data from CRM and ERP systems.
- Perform data quality and consistency checks.

### 3. Gold Layer — Business-Ready Data

The Gold Layer provides structured datasets optimized for business analytics and reporting.

It follows a **Star Schema** dimensional model consisting of:

- `gold.dim_customers` — Customer dimension.
- `gold.dim_products` — Product dimension.
- `gold.fact_sales` — Sales fact view.

The Gold Layer is implemented using SQL Server views, integrating cleaned data from the Silver Layer.

These views enable customer analysis, product performance evaluation, and sales reporting.

---

## ⭐ Data Model — Star Schema

The Gold Layer follows a **Star Schema**, where a central fact view connects to customer and product dimension views.

### Data Model Diagram

![Gold Layer Star Schema](02_docs/data_model.png)

### Dimension Views

**1. gold.dim_customers**

Contains customer details, including:

- Customer identifiers and surrogate keys.
- First name and last name.
- Country.
- Gender.
- Marital status.
- Birthdate.
- Customer creation date.

**2. gold.dim_products**

Contains product information, including:

- Product identifiers and surrogate keys.
- Product name and number.
- Category and subcategory.
- Product line.
- Product cost.
- Maintenance information.
- Product effective start date.

### Fact View

**3. gold.fact_sales**

Contains sales transactions and analytical measures:

- Order number.
- Product surrogate key.
- Customer surrogate key.
- Order, shipping, and due dates.
- Sales amount.
- Quantity.
- Unit price.

### Data Relationships

The Star Schema establishes logical one-to-many relationships between the dimensions and the sales fact view.

- `dim_customers.customer_key` → `fact_sales.customer_key`
- `dim_products.product_key` → `fact_sales.product_key`

These relationships enable analytical queries by combining transaction measures with customer and product attributes.

For detailed information about the tables, columns, and transformations, refer to the **Gold Layer Data Catalog**.

---

## 🔄 Data Flow & Data Lineage

The data pipeline follows an end-to-end flow from operational source systems to analytical datasets.

### Data Flow Diagram

![Data Flow and Lineage](02_docs/data_flow.png)

### Data Processing Flow

**Step 1 — Data Sources**

Data is extracted from two source systems:

- CRM: Customer, product, and sales information.
- ERP: Customer demographics, locations, and product categories.

**Step 2 — Bronze Layer**

Raw CSV files are loaded into SQL Server without applying business transformations.

**Step 3 — Silver Layer**

The raw datasets undergo cleaning, validation, standardization, and preparation for integration.

**Step 4 — Gold Layer**

Cleaned datasets are combined to create customer and product dimensions and a sales fact view.

**Step 5 — Analytics & Reporting**

Business-ready data can be consumed through SQL queries and BI tools to generate insights.

### Data Lineage

Data lineage documents the origin, transformations, and dependencies of data across the warehouse.

It supports traceability, debugging, data quality analysis, and impact assessment.

---

## 📂 Repository Structure

The project is organized into the following directories:

| Directory / File | Description |
|---|---|
| `01_datasets/` | CSV source files from CRM and ERP systems. |
| `01_datasets/source_crm/` | Customer, product, and sales source data. |
| `01_datasets/source_erp/` | ERP customer, location, and category data. |
| `02_docs/` | Project documentation, architecture diagrams, data catalog, and lineage. |
| `03_scripts/` | SQL scripts for implementing the Data Warehouse. |
| `03_scripts/init_database.sql` | Creates the DataWarehouse database and schemas. |
| `03_scripts/bronze/` | Bronze Layer table creation and data loading scripts. |
| `03_scripts/silver/` | Silver Layer table creation and data cleansing scripts. |
| `03_scripts/gold/` | Gold Layer dimension and fact view definitions. |
| `04_tests/` | SQL validation and data quality checks. |
| `README.md` | Project overview, architecture, and documentation. |
| `LICENSE` | Repository license information. |

---

## 🚀 Project Requirements

### Data Engineering — Building the Data Warehouse

**Objective**

Develop a modern SQL Server Data Warehouse that integrates customer, product, and sales data from multiple systems into a centralized analytical environment.

**Requirements**

- **Data Sources:** Import CRM and ERP datasets provided as CSV files.
- **Data Quality:** Identify and correct inconsistent, incomplete, or duplicate data.
- **Data Integration:** Combine information from multiple sources into consistent analytical datasets.
- **Data Modeling:** Implement a Star Schema using fact and dimension views.
- **Data Loading:** Implement repeatable full-load processes using SQL stored procedures.
- **Documentation:** Maintain data architecture diagrams, data lineage, and a data catalog.
- **Scope:** Focus on current data rather than maintaining full historical records.

---

## 📊 Business Intelligence & Analytics

### Objective

Prepare the Data Warehouse for analytical queries and business reporting.

The Gold Layer supports three main analytical areas.

### 1. Customer Analysis

- Analyze sales performance by customer.
- Understand customer distribution across countries.
- Explore sales by demographic attributes.
- Identify valuable customer segments.

### 2. Product Performance

- Identify best-selling products.
- Compare sales by product category and subcategory.
- Analyze product demand.
- Evaluate product contribution to total sales.

### 3. Sales Trends

- Analyze sales over time.
- Calculate total revenue and quantities sold.
- Compare sales performance across periods.
- Identify patterns and business trends.

### Key Business Metrics

| Metric | Description |
|---|---|
| Total Sales | Sum of sales amounts across transactions. |
| Total Orders | Count of distinct order numbers. |
| Total Quantity | Total number of products sold. |
| Average Selling Price | Average unit price across sales records. |
| Sales by Country | Revenue grouped by customer country. |
| Sales by Product Category | Revenue grouped by product category. |

---

## 🛠️ Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| Microsoft SQL Server | Relational database management system. |
| SQL Server Management Studio (SSMS) | SQL development, administration, and query execution. |
| T-SQL | Data ingestion, cleansing, transformations, and analytical queries. |
| Draw.io | Architecture, data modeling, and data lineage diagrams. |
| Git & GitHub | Version control and project documentation. |
| Notion | Project planning, organization, and task management. |
| CSV Files | Source datasets from CRM and ERP systems. |

---

## ⚙️ Getting Started

### Prerequisites

Before running the project, ensure that you have:

- Microsoft SQL Server installed.
- SQL Server Management Studio (SSMS).
- Access to the project CSV datasets.
- Basic knowledge of SQL.

### Step 1 — Clone the Repository

Clone the project repository to your local machine using Git or download the source files from GitHub.

### Step 2 — Initialize the Database

Execute the database initialization SQL script to create the Data Warehouse database and its schemas:

- `bronze`
- `silver`
- `gold`

### Step 3 — Configure Data Source Paths

Update the local CSV file paths in the Bronze loading script to match the location of the datasets on your machine.

Ensure that the SQL Server service has permission to access these files.

### Step 4 — Load the Bronze Layer

Create the Bronze tables and execute the Bronze loading stored procedure.

```sql
EXEC Bronze.load_Bronze;
```

### Step 5 — Load the Silver Layer

Create the Silver tables and execute the data cleansing and transformation procedure.

```sql
EXEC Silver.load_silver;
```

### Step 6 — Create the Gold Layer

Execute the Gold Layer SQL script to create the analytical views:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

### Step 7 — Validate the Data

Run the SQL validation queries to check data completeness, consistency, and analytical integrity.

### Step 8 — Explore the Gold Layer

Query the Gold Layer views to analyze sales, customers, and products.

---

## 🧪 Data Quality & Validation

Data quality is an important component of this project.

Validation checks focus on:

- **Completeness:** Identify missing or NULL values.
- **Uniqueness:** Detect duplicate business identifiers.
- **Consistency:** Verify standardized values across source systems.
- **Validity:** Check date formats, numerical values, and business rules.
- **Referential Integrity:** Verify that sales records match their customer and product dimensions.
- **Sales Accuracy:** Validate relationships between sales amounts, prices, and quantities.

These checks help maintain reliable datasets for downstream analytics.

---

## 📚 Learning Resources & Acknowledgements

This project was inspired by the SQL Data Warehouse tutorial created by **Baraa Khatib Salkini (Data With Baraa)**.

The tutorial provided a practical foundation for understanding data warehouse architecture, SQL-based ETL development, data cleansing, dimensional modeling, and project documentation.

**Original learning resources:**

- [SQL Data Warehouse Project — YouTube](https://youtu.be/9GVqKuTVANE)
- [Original GitHub Repository](https://github.com/DataWithBaraa/sql-data-warehouse-project)
- [Data With Baraa Website](https://www.datawithbaraa.com/)
- [SQL Full Course](https://youtu.be/SSKVgrwhzus)

I used these resources as a learning reference while practicing SQL development, implementing the Data Warehouse, and preparing my own project documentation.

---

## 🛡️ License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 About Me

Hi! I'm **Hassan El Kairah**, a final-year Master's student in **Data Science and Artificial Intelligence**, with a strong passion for **Data Engineering, Data Architecture, and modern data technologies**.

I am particularly interested in understanding how raw data can be transformed into reliable, structured, and business-ready datasets that support analytics and informed decision-making.

My academic background has provided me with foundations in programming, databases, data analysis, and artificial intelligence. Alongside my studies, I am actively developing my practical Data Engineering skills through hands-on projects and continuous learning.

Through this SQL Data Warehouse project, I have gained practical experience in:

- Designing and implementing a multi-layer Data Warehouse architecture.
- Developing ETL processes using SQL Server and T-SQL.
- Cleaning, standardizing, and integrating data from multiple sources.
- Building dimensional models using Star Schema principles.
- Creating stored procedures and handling data loading errors.
- Performing data quality checks and validating analytical datasets.
- Documenting data architecture, data models, and data lineage.
- Using GitHub to organize and showcase technical projects.

I am continuously expanding my knowledge in **SQL, Python, Data Pipelines, Workflow Orchestration, and Cloud Data Engineering**, with the goal of building scalable, efficient, and reliable data solutions.

### 🎯 Career Objective

My goal is to start my professional career as a **Data Engineer**, where I can apply my technical knowledge, contribute to real-world data projects, and continue developing expertise in building modern data platforms.

I enjoy solving technical challenges, learning new technologies, and transforming complex data problems into practical solutions.

**I believe that strong Data Engineering is the foundation of reliable analytics and intelligent systems.**

---

*Built with SQL Server, curiosity, and a passion for Data Engineering.*

**Hassan El Kairah**  
Master's Student — Data Science & Artificial Intelligence  
Aspiring Data Engineer
