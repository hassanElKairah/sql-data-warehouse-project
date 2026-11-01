# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository.

This project demonstrates a complete data warehousing and analytics solution, from building a modern data warehouse to generating useful business insights.

The project is designed as a portfolio project and follows common best practices in data engineering and data analytics.

---

## Project Requirements

### Building the Data Warehouse - Data Engineering

#### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data from multiple source systems, enabling analytical reporting and informed decision-making.

#### Specifications

- **Data Sources:** Import data from two source systems, ERP and CRM, provided as CSV files.
- **Data Quality:** Clean and resolve data quality issues before performing analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only. Data historization is not required.
- **Documentation:** Provide clear documentation of the data model and data flow to support both business stakeholders and analytics teams.

---

## BI: Analytics and Reporting - Data Analysis

### Objective

Develop SQL-based analytics to provide detailed insights into:

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights help business stakeholders understand key performance indicators and support better strategic decision-making.

---

## Data Architecture

The project follows a Medallion Architecture with three main layers:

- **Bronze Layer:** Stores raw data as received from the source systems.
- **Silver Layer:** Cleans, standardizes, and prepares the data.
- **Gold Layer:** Contains business-ready data optimized for analytics and reporting.

Data flow:

`ERP + CRM -> Bronze -> Silver -> Gold -> Analytics`

---

## Project Structure

The repository is organized into the following folders:

- **datasets/** - Contains source data files from ERP and CRM.
- **scripts/** - Contains SQL scripts used to build and load the data warehouse.
- **docs/** - Contains project documentation and architecture diagrams.
- **tests/** - Contains validation and data quality checks.

---

## Technologies Used

- SQL Server
- SQL
- Git
- GitHub
- Draw.io
- CSV Files

---

## Project Goal

The main goal of this project is to practice the complete data engineering workflow:

`Understand Requirements -> Design Architecture -> Build Data Warehouse -> Validate Data -> Create Analytics`
