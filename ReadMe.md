# **Driving Business Intelligence and Decision-Making through SQL Data Cleaning**.


# Executive Summary:
Messy business data, stored in a relational database, was cleaned using SQL.

To evaluate, update, or completely overhaul its market strategy, a company needed a thorough understanding of its customer base. Gaining this insight relied entirely on access to a clean, error-free dataset. 

Trustworthy and reliable data was derived after identifying and correcting errors such as Duplicate records, missing values, inconsistent values, outliers, and unwanted data amongst others.

SQL was used as the tool for data cleaning and transformation. It was applied through the Postgres RDBMS.

**Lower- and Middle-Income class customers had the highest customer traffic and made the most purchases.**  
**Young Adults to Young Seniors had a cumulatively high impact on the business.**  
**Conversion Rate was a key performance metric that should be determined.**  
**The business data-gathering process needed to be either reviewed or redesigned, and the data cleaning operation be automated.**      

Business Intelligence improved as a result, as subsequent analysis was based on reliable, clean information that accurately described the business operations. 



# Business Problem(s)/Question(s):
Every business generates and collects data connected to its operations. This information helps to drive business operations by providing an unbiased basis for “Data-Driven Decision Making”. 

Marketing Teams need reliable Buyer Profiles to develop new or update existing Market Strategy. This indicates a need for data about its customers. In many cases, the available or collected data contains errors that (will) need to be corrected. 


- What are the types of mess that the business data may have?

- Can SQL be used to check for and correct those messes so that a trustworthy dataset is derived for further use? 

- Can dependable, trustworthy insights be derived from cleaned data using SQL? 

These few questions (and more) were answered in this project.

**Answers to the business questions helped produce a reliable foundation for analyses, and a strong context for data-driven decisions**. 



# Methodology:
Basically involved using SQL queries for:

- Creation of Database and Tables, 
- Data Exploration, and 
- Data Transformation 


In more detail, SQL queries were used to:

- Create a Database and Table to hold the raw data.

- Inspect the dataset and identify data quality issues.
- Check for duplicate records (using the PARTITION BY clause and a BIGSERIAL data type column). 
- Standardize inconsistent text values using SQL functions.
- Identify and handle missing or null values.
- Apply the PERCENTILE_CONT() function in Outlier handling.
- Convert date and numerical columns into appropriate data types.
- Remove unnecessary spaces and inconsistent characters.
- Create a cleaned dataset for further analysis and reporting.



# Skills:
**SQL:**
- Regular Expressions in Data Exploration (and Data Cleaning). 

- CTEs and Window Functions in Duplicate row detection and removal.
- Conditional Logic using CASE-WHEN-THEN-ELSE-END.
- Update statements in Data Editing and Replacement.
- Data type conversion using ALTER TABLE, ALTER COLUMN, TYPE, and USING commands. 
- Transaction Control Language commands like BEGIN, COMMIT, ROLLBACK.
- WHERE clause to handle NULL and missing values, 
- Sub-queries in Outliers, NULL and Negative Values manipulation.
- String Manipulation, 
- DROP COLUMN to remove unnecessary data.
- Generate a CLEAN dataset of required fields for further application.

**DBeaver:**
- Apply CREATE DATABASE and CREATE TABLE commands.

- Import data from external files to populate tables.

**pgAdmin:**
- Write SQL queries to assess and clean data.

- Execute the SQL queries to implement transformations.

- Execute SQL queries to analysis the cleaned dataset for insights and information.



# Results and Business Recommendations
Answers were proffered to the earlier raised questions and more.

### 1. **What type of Customer Information was in the dataset?**

Analysis revealed the following;

• **Demographic:** Income, Age, Gender, Education, Profession, and Marital Status.

•	**Behavior:** Commute Distance, Purchase or Not.

•	**Lifestyle:** Number of Cars, Number of Children, and Homeowner.

### Business Recommendation(s)
- The Organization/Business should consider several Customer Information in the assessment or development of Market Strategy.

- Income demographic is important as it indicates purchasing power and product pricing, which impacts price fixing and revenue.

- Purchase or Not information is vital in calculating Conversion Rate, a key performance metric. 

- Location information, needed for locale performance determination, is vital data that must be collected.


### 2. **What types of mess did the data have?**

[Python file on Exploratory Data Analysis on Messy Dataset](Exploratory_Data_Analysis_on_Dataset.ipynb)

Data Problems, identified from an Exploratory Data Analysis performed on the original/raw dataset, included;

- Duplicate Records.

- Missing Values (e.g., nan, unknown).
- Outliers (e.g., value of 9,999,999 in Income, 999 and 150 for Age, 99 for Number of Children).
- Negative values.
- Invalid Data values (e.g., “yesterday”, “invalid date” in Date column).
- Inconsistent Text Formats.
- Wrong Data Types (e.g., Numbers and Dates entered as Strings).


### Business Recommendation(s):
- Investigate the Data Gathering Process; improve on it or design a new one.

- Implement a staged cleaning process before utilizing data for analysis.

### 3. **Can SQL be used to check for and correct those messes?**
The application of keywords, functions, and Regular Expressions made checking for and correcting data quality issues (using SQL) possible.

[SQL file on Data Assessment and Cleaning Process](bike_customers_data_cleaning.ql)         
[SQL file on Data Assessment and Cleaning Process_contd](bike_customers_data_cleaning_contd.sql)

Some data issues that were checked and corrected using SQL queries are as follows;
