select
	datname
from
	pg_database ;


select
	*
from
	information_schema.tables 
where
	table_schema = 'public';



-- Drop the table
drop table bike_customers_dataset  ;


-- Create the table that holds the customer information
-- Extracting the needed columns from the main table.

create table if not exists bike_customers_dataset AS
	select "Order ID", "Date of Purchase", "Customer Age", "Gender", "Marital Status", "Income", "Educational Level",
			"Occupation", "Commute Distance", "Home Ownership", "Number of Cars", "Number of Children", "Purchased or Not"
	from
		messy_data_bike_sales ;


-- Start a transaction.
BEGIN;

-- 1).
-- Create a unique value column that identifies all the records.
-- This makes it possible to check for duplicates in the dataset.

alter table bike_customers_dataset
add column serial_number bigserial ;


-- 1a.)
-- How many PURE duplicates do we have in the dataset?
-- 35000 records/rows/observations.

with duplicates as(
	select
		*,
		row_number() over (partition by
		"Order ID", "Date of Purchase", "Customer Age", "Gender", "Marital Status", "Income", "Educational Level",
		"Occupation", "Commute Distance", "Home Ownership", "Number of Cars", "Number of Children", "Purchased or Not"
		order by serial_number) as "duplicates_index"
	from
		bike_customers_dataset 
)
select 
	*
from
	duplicates
where
	duplicates_index > 1 ;


-- 1b.)
-- delete one of every PURE DUPLICATE records
-- 35000 rows deleted.

with duplicates as(
	select
		*,
		row_number() over (partition by
		"Order ID", "Date of Purchase", "Customer Age", "Gender", "Marital Status", "Income", "Educational Level",
		"Occupation", "Commute Distance", "Home Ownership", "Number of Cars", "Number of Children", "Purchased or Not"
		order by serial_number) as "duplicates_index"
	from
		bike_customers_dataset 
)
delete from bike_customers_dataset
where serial_number in (select serial_number
from duplicates where "duplicates_index" > 1) ;


-- display some records
select
	*
from
	bike_customers_dataset 
limit 
	10 ;




-- 2.)
-- Date of Purchase

-- 2a.)
-- Check for DISTINCT date values that have at least one text character.
-- Has ANY SINGLE CHARACTER that is a TEXT.
select
	distinct "Date of Purchase"	
from
	bike_customers_dataset 
where 
	"Date of Purchase" ~ '[a-zA-Z]';
	

-- "Date of Purchase" contains '', 'invalid date' and '2025-13-45' values
-- '' represents an empty data point.
-- Invalid value 2025-13-45 noticed during attempt to change column type to date.

select
	"Order ID", "Date of Purchase",
	case
		when "Date of Purchase" ='' then NULL
		when "Date of Purchase" = 'invalid date' then NULL
		when "Date of Purchase" = '2025-13-45' then '2025-12-31'
		else "Date of Purchase"
	end as "Date Fills"
from
 	bike_customers_dataset 
where
	"Date of Purchase" in ('', 'invalid date', '2025-13-45')


-- 2b)
-- Update the column accordingly.

update bike_customers_dataset
set "Date of Purchase" = case
		when "Date of Purchase" ='' then NULL
		when "Date of Purchase" = 'invalid date' then NULL
		when "Date of Purchase" = '2025-13-45' then '2025-12-31'
		else "Date of Purchase"
	end ;


-- 2c)
-- Change the data type
-- from character varying to date.

alter table bike_customers_dataset
alter column "Date of Purchase" type date 
using cast("Date of Purchase" as date);


-- End the Transaction by committing the changes.
COMMIT ;




-- Start another transaction.
BEGIN;

-- 3.)
-- Customer Age


-- 3a)
-- Check for Distinct values THAT ARE NOT NUMBERS.
select
	distinct "Customer Age"	
from
	bike_customers_dataset
where 
	"Customer Age" !~ '^\d+$';
	

-- 3b)
-- Replace text versions of numbers

select
	"Customer Age",
	case
		when "Customer Age" = '18 years' then '18'
		when "Customer Age" = '25+' then '25'
		when "Customer Age" = 'forty-five' then '45'
		when "Customer Age" = 'thirty' then '30'
		else "Customer Age"
	end as corrected_ages
from
	bike_customers_dataset ;


-- 3c)
-- Update the column.

update bike_customers_dataset
set "Customer Age" = case
		when "Customer Age" = '18 years' then '18'
		when "Customer Age" = '25+' then '25'
		when "Customer Age" = 'forty-five' then '45'
		when "Customer Age" = 'thirty' then '30'
		else "Customer Age"
	end ;
	

-- 3d)
-- Replace input 'old' with the median value of age range
-- from 65 to 84 years; 74.5 rounded up to 75.
-- 2137 rows.

select
	"Customer Age",
	case
		when "Customer Age" = 'old' then '75'
		else "Customer Age"
	end as age_correction
from
	bike_customers_dataset 
where 
	"Customer Age" = 'old';


-- 3e)
-- Update the column.
-- 2137 rows updated.

update bike_customers_dataset
set "Customer Age" = case
		when "Customer Age" = 'old' then '75'
		else "Customer Age"
	end 
where 
	"Customer Age" = 'old';


-- 3f)
-- Replace the entries 'nan' and 'unknown' with zero (0) values.
-- Then later replace those zero values with the MEDIAN.
-- 4202 rows affected.

select
	"Customer Age",
	case
		when "Customer Age" = 'nan' or "Customer Age" = 'unknown' then '0'
		else "Customer Age"
	end as age_correction_1
from
	bike_customers_dataset 
where 
		"Customer Age" = 'nan' or 
		"Customer Age" = 'unknown';


-- 3g)
-- Update the column.
-- 4202 rows updated.

update bike_customers_dataset
set "Customer Age" = case
		when "Customer Age" = 'nan' or "Customer Age" = 'unknown' then '0'
		else "Customer Age"
	end
where 
		"Customer Age" = 'nan' or 
		"Customer Age" = 'unknown';


-- 3g)
-- Create CTEs for the numerical values.
-- 10411 rows affected.

with age_numericals as (
	select
			percentile_cont(0.01) within group (order by cast("Customer Age" as int)) as age_1th_percentile,
			percentile_cont(0.25) within group (order by cast("Customer Age" as int)) as age_25th_percentile,
			percentile_cont(0.50) within group (order by cast("Customer Age" as int)) as age_Median,
			percentile_cont(0.99) within group (order by cast("Customer Age" as int)) as age_99th_percentile
	from 
		bike_customers_dataset
	where 
		cast("Customer Age" as int)is not null 
)
-- At this point, every value in the "Customer Age" column is a string representation of a number.
select
	"Customer Age",
	case
		when cast("Customer Age" as int) > 100  then an.age_99th_percentile
		when cast("Customer Age" as int) = 0  then an.age_Median
		when cast("Customer Age" as int) < 0 then an.age_1th_percentile 
		else cast("Customer Age" as int)
	end as age_corrections
from
	bike_customers_dataset,
	age_numericals an
where 
	cast("Customer Age" as int) = 0 
	or cast("Customer Age" as int) < 0
	or cast("Customer Age" as int) > 100;


-- 3h)
-- Update the column.
-- 10411 rows updated.

with age_numericals as (
	select
			percentile_cont(0.01) within group (order by cast("Customer Age" as int)) as age_1th_percentile,
			percentile_cont(0.25) within group (order by cast("Customer Age" as int)) as age_25th_percentile,
			percentile_cont(0.50) within group (order by cast("Customer Age" as int)) as age_Median,
			percentile_cont(0.99) within group (order by cast("Customer Age" as int)) as age_99th_percentile
	from 
		bike_customers_dataset
	where 
		cast("Customer Age" as int)is not null 
)
update bike_customers_dataset
set "Customer Age" = case
		when cast("Customer Age" as int) > 100  then (select age_numericals.age_99th_percentile from age_numericals)
		when cast("Customer Age" as int) = 0  then (select age_numericals.age_Median from age_numericals)
		when cast("Customer Age" as int) < 0 then (select age_numericals.age_1th_percentile from age_numericals)
		else cast("Customer Age" as int)
	end
where 
	cast("Customer Age" as int) = 0 
	or cast("Customer Age" as int) < 0
	or cast("Customer Age" as int) > 100;


-- 3i)
-- Change the data type of the Customer Age column.

alter table bike_customers_dataset
alter column "Customer Age" type int 
using cast("Customer Age" as int);


-- Commit the changes
COMMIT ;




-- Start another transaction.
BEGIN;

-- 4.)
-- Gender


-- 4a)
-- Check for Distinct values
select
	distinct "Gender"
from
	bike_customers_dataset;


-- 4b)
-- Remove any trailing or leading spaces

update bike_customers_dataset
set "Gender" = trim("Gender");


-- 4c)
-- Modify the gender values. 

select
	 "Gender",
	 case
		when "Gender" = any(array['f','F','feMale', 'FEMALE', 'F�male', 'she/her', 'woman']) then 'Female'
		when "Gender" = any(array['m', 'M', 'mail', 'MALE', 'man', 'M�le', 'he/him']) then 'Male'
		when "Gender" = 'Non-binary' then 'Non-Binary'
		when "Gender" = any(array['unknown', 'nan']) then 'Unknown'
		when "Gender" = any(array['prefer not to say', '?']) then 'Unspecified'
		else "Gender"
	 end as gender_correct
from
	bike_customers_dataset 
where
	"Gender" is not null;


-- 4d)
-- Update the Gender column.

update bike_customers_dataset
set "Gender" =  case
		when "Gender" = any(array['f','F','feMale', 'FEMALE', 'F�male', 'she/her', 'woman']) then 'Female'
		when "Gender" = any(array['m', 'M', 'mail', 'MALE', 'man', 'M�le', 'he/him']) then 'Male'
		when "Gender" = 'Non-binary' then 'Non-Binary'
		when "Gender" = any(array['unknown', 'nan']) then 'Unknown'
		when "Gender" = any(array['prefer not to say', '?']) then 'Unspecified'
		else "Gender"
	 end ;


-- 4e)
-- Are there any empty gender value cells?
-- Zero (0) rows.

select
	count("Gender")
from
	bike_customers_dataset
where 
	"Gender" = '';
	

select
	distinct "Gender"
from
	 bike_customers_dataset ;


-- Commit the changes
COMMIT ;




-- Start another transaction.
BEGIN;

-- 5)
-- Income.


-- 5a)
-- Check for the values that are not pure numbers.

select
	distinct "Income"
from
	bike_customers_dataset 
where
	"Income" ~ '[a-zA-Z]';


-- 5b)
-- Check for the values that may contain
-- other characters apart from numbers, decimals,
-- or negative value.

select
	distinct "Income"
from
	bike_customers_dataset 
where
	"Income" ~ '[^0-9.-]';


-- 5c)
-- CASE statement for value replacements.
-- 10522 rows

select
	"Income",
	case
		when "Income" = any(array['$45,000', '45k']) then '45000'
		when "Income" = '>200k' then '200100'
		when "Income" = '100k+' then '100100'
		when "Income" = 'fifty thousand' then '50000'
		when "Income" = 'zero' then '0'
		when "Income" = 'rich' then '258482'
		else "Income"
	end
from
	bike_customers_dataset 
where
	"Income" ~ '[^0-9.-]' ;


-- 5d)
-- Update the Income column.
-- 10522 rows updated.

update 	bike_customers_dataset 
set "Income" = case
		when "Income" = any(array['$45,000', '45k']) then '45000'
		when "Income" = '>200k' then '200100'
		when "Income" = '100k+' then '100100'
		when "Income" = 'fifty thousand' then '50000'
		when "Income" = 'zero' then '0'
		when "Income" = 'rich' then '258482'
		else "Income"
	end 
where
	"Income" ~ '[^0-9.-]';



-- 5e)
-- Treat Negative values as dummy data. 
-- Represent them as missing values.
-- 2353 rows

select
	"Income",
	case 
		when cast("Income" as float) < 0 then null
		else "Income"
	end
from
	bike_customers_dataset
where
	regexp_like("Income", '^[0-9.-]+$') and 
	cast("Income" as float) < 0 ;


-- 5f)
-- Update the values accordingly
-- 2353 rows updated.

update bike_customers_dataset
set "Income" = case 
		when cast("Income" as float) < 0 then null
		else "Income"
	end
where
	regexp_like("Income", '^[0-9.-]+$') and 
	cast("Income" as float) < 0 ;
	

-- 5g)
-- At this point, almost but NOT all values in the Income column have
-- a text representation of a number. 'nan' and 'unknown' still exist.
-- 4637 rows affected.

with income_numericals as (
	select
			percentile_cont(0.25) within group (order by cast("Income" as float)) as income_25th_percentile,
			percentile_cont(0.50) within group (order by cast("Income" as float)) as income_Median,
			percentile_cont(0.75) within group (order by cast("Income" as float)) as income_75th_percentile
	from 
		bike_customers_dataset
	where 
		regexp_like("Income", '^[0-9.]+$') 
)
-- Replace 'nan', 'unknown', and null
select
	"Income",
	case 
		when "Income" = any(array['nan', 'unknown']) or "Income" is null then cast(income_num.income_Median as text) 
		else "Income"
	end as income_values
from
	bike_customers_dataset,
	income_numericals as income_num
where
	"Income" in ('nan', 'unknown') or
	"Income" is null ;



-- 5h)
-- Update the values accordingly
-- 4637 rows updated.

with income_numericals as (
	select
			percentile_cont(0.25) within group (order by cast("Income" as float)) as income_25th_percentile,
			percentile_cont(0.50) within group (order by cast("Income" as float)) as income_Median,
			percentile_cont(0.75) within group (order by cast("Income" as float)) as income_75th_percentile
	from 
		bike_customers_dataset
	where 
		regexp_like("Income", '^[0-9.]+$') 
)
update bike_customers_dataset
set "Income" = case 
		when "Income" = any(array['nan', 'unknown']) or "Income" is null then cast((select income_Median from income_numericals) as text) 
		else "Income"
	end 
where
	"Income" in ('nan', 'unknown') or
	"Income" is null ;


-- At this point ALL rows in "Income" have numeric 
-- values represented as Strings/Objects.

-- 5i)
-- Handle Outliers

with income_numericals as (
	select
			percentile_cont(0.25) within group (order by cast("Income" as float)) as income_25th_percentile,
			percentile_cont(0.50) within group (order by cast("Income" as float)) as income_Median,
			percentile_cont(0.75) within group (order by cast("Income" as float)) as income_75th_percentile
	from 
		bike_customers_dataset
	where 
		cast("Income" as float)is not null 
)
select
	income_25th_percentile,
	income_Median,
	income_75th_percentile,
	(income_75th_percentile + 14.0*(income_75th_percentile - income_25th_percentile)) as outlier_replace
from
	income_numericals ;


-- 1125 rows affected.
select
	"Income",
	case
		when cast("Income" as float) > 258482 then 472900
		else cast("Income" as float)
	end
from
	bike_customers_dataset
where
	cast("Income" as float) > 258482 ;
	



-- 5j)
-- Update the Income outlier value.
-- 472900 is the lower limit of top 1% earners in Manitoba.
-- 1125 rows affected.

update bike_customers_dataset
set "Income" = case
		when cast("Income" as float) > 258482 then 472900
		else cast("Income" as float)
	end
where
	cast("Income" as float) > 258482 ;


-- 5k)
-- Change the data type of the Income column.

alter table bike_customers_dataset
alter column "Income" type float
using cast("Income" as float) ;


-- 5l)
-- Modify the decimal places of Income.
-- Set to 2 decimal places.

update bike_customers_dataset
set "Income" = round("Income"::numeric, 2) ;

COMMIT ; 




-- Select a few rows to see the changes effected.
select
	*
from
	bike_customers_dataset
order by
	"Order ID"
limit 10 ;



ROLLBACK
