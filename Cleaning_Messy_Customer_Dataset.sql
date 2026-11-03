select
	*
from
	bike_business_messy_dataset 
limit
	20 ;

-- Drop Table
drop table customers_dataset;


-- Extract the dataset for the customers.
-- Save them in a created table.
create table if not exists customers_dataset as(
	select
		"Order ID", "Date of Purchase", "Customer Age", "Gender",
		"Marital Status", "Income", "Educational Level", "Occupation",
		"Commute Distance", "Home Ownership", "Number of Cars",
		"Number of Children", "Purchased or Not"
	from
		bike_business_messy_dataset
)

-- Extract some data from the created table.
-- From sorted results, there are duplicate 
-- "Order ID" values, thus duplicate records.
select
	*
from
	customers_dataset
order by
	"Order ID"
limit
	20;




-- Start a transaction
BEGIN;

-- 1.
-- DUPLICATE RECORDS.

-- First create a unique value column
alter table customers_dataset
add column serial_number bigserial ;

-- Check how many duplicate records are in the dataset.
-- 35,000 records 
with duplicate_records as(
	select
		*,
		row_number() over(
			partition by "Order ID", "Date of Purchase", "Customer Age",
							"Gender", "Marital Status", "Income"
			order by serial_number
		) as duplicate_index
	from
		customers_dataset
)
select
	*
from
	duplicate_records
where
	duplicate_index > 1 ;

-- Remove Duplicate records.
-- 35,000 rows/records deleted.
with duplicate_records as(
	select
		*,
		row_number() over(
			partition by "Order ID", "Date of Purchase", "Customer Age",
							"Gender", "Marital Status", "Income"
			order by serial_number
		) as duplicate_index
	from
		customers_dataset
)
delete from customers_dataset
where serial_number in(select serial_number
					   from duplicate_records 
					   where duplicate_index > 1) ;

-- Commit the changes.
COMMIT ;

	


-- Begin another transaction
BEGIN ;

-- 2.
-- DATE OF PURCHASE.

-- Remove the spaces before and/or
-- after the entries.
select
	trim("Date of Purchase")
from
	customers_dataset ;

-- Replace the entries with the values
-- containing the removed spaces.
-- Update the column.
update customers_dataset
set "Date of Purchase" = trim("Date of Purchase") ;


-- Check for any entries that may have text.
select
	distinct("Date of Purchase")
from
	customers_dataset
where
	regexp_like("Date of Purchase", '^[a-zA-Z ]+$');


-- Using a CASE statement to text the replacement of
-- values in a column.
-- 130 rows.
select
	"Date of Purchase",
	case
		when "Date of Purchase" = any(array['yesterday', 'invalid date']) then null
		else "Date of Purchase"
	end as Date_values
from
	customers_dataset
where 
	regexp_like("Date of Purchase", '^[a-zA-Z ]+$');

-- Replace the text values in the Date column with null.
-- Update the column.
update customers_dataset
set "Date of Purchase" = case
		when "Date of Purchase" = any(array['yesterday', 'invalid date']) then null
		else "Date of Purchase"
	end ;


-- Check for date values that are out of range.
-- 50 rows.
-- 2025-13-45.
select
	"Date of Purchase",
	substring("Date of Purchase", 1, 4) as Year_value,
	substring("Date of Purchase", 6, 2) as Month_value,
	substring("Date of Purchase", 9, 2) as Day_value
from
	customers_dataset
where
	substring("Date of Purchase", 6, 2) > 12::text
	or substring("Date of Purchase", 9, 2) > 31::text;

-- Using a CASE statement to text the replacement of
-- out-of-range dates with null value.
select
	"Date of Purchase",
	case
		when substring("Date of Purchase", 6, 2) > 12::text then null
		when substring("Date of Purchase", 9, 2) > 31::text then null
		else "Date of Purchase"
	end as replace_bad_dates
from
	customers_dataset
where
	substring("Date of Purchase", 6, 2) > 12::text
	or substring("Date of Purchase", 9, 2) > 31::text;

-- Replace the out-of-range date values.
-- Update the column.
-- 50 rows updated.
update customers_dataset
set "Date of Purchase" = case
		when substring("Date of Purchase", 6, 2) > 12::text then null
		when substring("Date of Purchase", 9, 2) > 31::text then null
		else "Date of Purchase"
	end
where
	substring("Date of Purchase", 6, 2) > 12::text
	or substring("Date of Purchase", 9, 2) > 31::text;

-- Replace space entries with null.
-- Update the column.
update customers_dataset
set "Date of Purchase" = case
		when "Date of Purchase" = '' then null
		else "Date of Purchase" 
	end;

-- Change the data type of the column.
alter table customers_dataset
alter column "Date of Purchase" type date
using cast ("Date of Purchase" as date) ;


-- See a few rows
select
	*
from
	customers_dataset
order by
	"Order ID"
limit
	10 ;


-- Commit
COMMIT ;




-- Begin another transaction
BEGIN ;

-- 3.
-- CUSTOMER AGE.

-- Remove any trailing or leading spaces.
-- Update the column.
update customers_dataset
set "Customer Age" = trim("Customer Age");


-- Check for values that are not numerical.
-- May contain other characters apart from or
-- along with numbers.
select
	distinct("Customer Age")
from
	customers_dataset
where
	not regexp_like("Customer Age", '^\d+$') ;

-- Create a CASE statement to handle replacement
-- of values.
select
	distinct "Customer Age",
	case
		when "Customer Age" = any(array['nan', 'unknown']) then null
		when "Customer Age" = '18 years' then '18'
		when "Customer Age" = 'thirty' then '30'
		when "Customer Age" = 'forty-five' then '45'
		when "Customer Age" = any(array['-5', '25+', 'old']) then null
		else "Customer Age"
	end
from
	customers_dataset
where 
	not regexp_like("Customer Age", '^\d+$')

-- Update the Customer Age column.
-- 16890 rows updated.
-- 6313 rows for -5, 25+, and old.
update customers_dataset
set "Customer Age" = case
		when "Customer Age" = any(array['nan', 'unknown']) then null
		when "Customer Age" = '18 years' then '18'
		when "Customer Age" = 'thirty' then '30'
		when "Customer Age" = 'forty-five' then '45'
		when "Customer Age" = any(array['-5', '25+', 'old']) then null
		else "Customer Age"
	end
where 
	not regexp_like("Customer Age", '^\d+$');


-- Check distinct "Customer Age" values
-- Display in descending order.
select
	distinct cast("Customer Age" as integer)
from
	customers_dataset
order by
	"Customer Age"::integer desc ;


-- Handle outlier values of 999 and 150.
-- Calculate selected percentile values.
with percentile_values as(
	select
		percentile_cont(0.01) within group (order by "Customer Age"::integer) as v1th_percentile,
		percentile_cont(0.25) within group (order by "Customer Age"::integer) as v25th_percentile,
		percentile_cont(0.50) within group (order by "Customer Age"::integer) as v50th_percentile,
		percentile_cont(0.75) within group (order by "Customer Age"::integer) as v75th_percentile,
		percentile_cont(0.99) within group (order by "Customer Age"::integer) as v99th_percentile
	from
		customers_dataset
)
select
	*
from
	percentile_values ;


-- CASE statement to show replacement of outlier values.
-- 4110 rows.
with percentile_values as(
	select
		percentile_cont(0.01) within group (order by "Customer Age"::integer) as v1th_percentile,
		percentile_cont(0.25) within group (order by "Customer Age"::integer) as v25th_percentile,
		percentile_cont(0.50) within group (order by "Customer Age"::integer) as v50th_percentile,
		percentile_cont(0.75) within group (order by "Customer Age"::integer) as v75th_percentile,
		percentile_cont(0.99) within group (order by "Customer Age"::integer) as v99th_percentile
	from
		customers_dataset
)
select
	"Customer Age",
	case
		when "Customer Age"::integer = any(array[999, 150]) then pv.v99th_percentile
		else "Customer Age"::integer
	end
from
	customers_dataset cd,
	percentile_values pv
where
	"Customer Age"::integer in (150, 999);

-- Update the Customer Age column.
-- 4110 rows updated.
with percentile_values as(
	select
		percentile_cont(0.01) within group (order by "Customer Age"::integer) as v1th_percentile,
		percentile_cont(0.25) within group (order by "Customer Age"::integer) as v25th_percentile,
		percentile_cont(0.50) within group (order by "Customer Age"::integer) as v50th_percentile,
		percentile_cont(0.75) within group (order by "Customer Age"::integer) as v75th_percentile,
		percentile_cont(0.99) within group (order by "Customer Age"::integer) as v99th_percentile
	from
		customers_dataset
)
update customers_dataset
set "Customer Age" = case
		when "Customer Age"::integer = any(array[999, 150]) then (select v99th_percentile from percentile_values)
		else "Customer Age"::integer
	end
where
	"Customer Age"::integer in (150, 999);


-- Change the data type of the "Customer Age" column.
alter table customers_dataset
alter column "Customer Age" type integer
using cast("Customer Age" as integer);


-- See a few rows
select
	*
from
	customers_dataset
order by
	"Order ID"
limit
	10 ;


-- Commit changes
COMMIT ;




-- Begin another transaction
BEGIN ;

-- 4.
-- PURCHASE OR NOT.

-- Remove any trailing or leading spaces.
-- Change the case of text entries to title case
update customers_dataset
set "Purchased or Not" = initcap(trim("Purchased or Not")) ;


-- Retrieve the distinct values in the column.
select
	distinct "Purchased or Not"
from
	customers_dataset ;


-- CASE statements to handle replacement of the
-- values in the column.

select
	distinct "Purchased or Not",
	case
		when "Purchased or Not" = any(array['✔️', '✅', '1', 'Bought', 'Purchased', 'True', 'Y', 'Yes']) then 'Yes'
		when "Purchased or Not" = any(array['✖️', '❌', '0', 'Did Not Buy', 'False', 'N', 'No', 'Not Purchased']) then 'No'
		when "Purchased or Not" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Purchased or Not" = 'Maybe' then 'Unspecified'
		else "Purchased or Not"
	end
from
	customers_dataset

-- Update the column
update customers_dataset
set "Purchased or Not" = case
		when "Purchased or Not" = any(array['✔️', '✅', '1', 'Bought', 'Purchased', 'True', 'Y', 'Yes']) then 'Yes'
		when "Purchased or Not" = any(array['✖️', '❌', '0', 'Did Not Buy', 'False', 'N', 'No', 'Not Purchased']) then 'No'
		when "Purchased or Not" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Purchased or Not" = 'Maybe' then 'Unspecified'
		else "Purchased or Not"
	end ;


-- Check the distinct entries
select
	distinct "Purchased or Not"
from
	customers_dataset ;


-- Commit the changes
COMMIT ;




-- Begin another transaction
BEGIN ;

-- 5.
-- GENDER.

-- Remove trailing or leading spaces.
-- Change case of texts to Title case.
update customers_dataset
set "Gender" = initcap(trim("Gender"))


-- Retrieve the distinct values in the column.
select
	distinct "Gender"
from
	customers_dataset ;


-- CASE statements to handle value replacements.
select
	distinct "Gender",
	case
		when "Gender" = any(array['♀', 'F', 'Female', 'Fémale', 'She/Her', 'Woman']) then 'Female/She/Her/Woman'
		when "Gender" = any(array['♂', 'He/Him', 'M', 'Mail', 'Male', 'Mâle', 'Man']) then 'Male/He/Him/Man'
		when "Gender" = 'Prefer Not To Say' then 'Unspecified'
		when "Gender" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Gender" = null then 'Unknown'
		else "Gender"
	end as Gender_Correction
from
	customers_dataset ;


-- Update the column.
update customers_dataset
set "Gender" = case
		when "Gender" = any(array['♀', 'F', 'Female', 'Fémale', 'She/Her', 'Woman']) then 'Female/She/Her/Woman'
		when "Gender" = any(array['♂', 'He/Him', 'M', 'Mail', 'Male', 'Mâle', 'Man']) then 'Male/He/Him/Man'
		when "Gender" = 'Prefer Not To Say' then 'Unspecified'
		when "Gender" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Gender" = null then 'Unknown'
		else "Gender"
	end ;


select
	*
from
	customers_dataset
limit
	10;


-- Commit the changes.
COMMIT ;




-- Begin another transaction.
BEGIN;

-- 6.
-- MARITAL STATUS.

-- Remove any leading or trailing spaces.
-- Change text casing to Title case.
update customers_dataset
set "Marital Status" = initcap(trim("Marital Status"));


-- Extract the distinct values in the column
select
	distinct "Marital Status"
from
	customers_dataset ;

-- CASE statements to handle value replacements.
select
	distinct "Marital Status",
	case
		when "Marital Status" = any(array['N/A', 'Nan', 'Unknown']) then 'Unknown'
		when "Marital Status" = 'Living Together' then 'Partnership'
		when "Marital Status" = 'D' then 'Divorced'
 		when "Marital Status" = 'M' then 'Married'
		when "Marital Status" = 'S' then 'Single'
		when "Marital Status" = 'W' then 'Widowed'
		else "Marital Status"
	end Marital_Status_corrected
from
	customers_dataset ;


-- Update the column.
update customers_dataset
set "Marital Status" = case
		when "Marital Status" = any(array['N/A', 'Nan', 'Unknown']) then 'Unknown'
		when "Marital Status" = 'Living Together' then 'Partnership'
		when "Marital Status" = 'D' then 'Divorced'
 		when "Marital Status" = 'M' then 'Married'
		when "Marital Status" = 'S' then 'Single'
		when "Marital Status" = 'W' then 'Widowed'
		else "Marital Status"
	end ;


select
	*
from
	customers_dataset
limit
	10;

-- Commit the changes
COMMIT;





-- Begin another transaction
BEGIN ;

-- 7.
-- INCOME.

-- Remove any trailing or leading spaces
-- since the values are text at the moment.
update customers_dataset
set "Income" = trim("Income") ;

-- Check for values that are not entirely numeric
select
	distinct "Income"
from
	customers_dataset
where
	not regexp_like("Income", '^[0-9.]+$') ;


-- Case statement to effect value correction.
select
	distinct "Income",
	case
		when "Income" = any(array['unknown', '-1', '-10000', 'nan']) then null
		when "Income" = any(array['$45,000', '45k']) then '45000'
		when "Income" = 'fifty thousand' then '50000'
		when "Income" = 'zero' then '0'
		else "Income"
	end
from
	customers_dataset
where
	not regexp_like("Income", '^[0-9.]+$') ;

-- Update the dataset.
-- 12875 rows updated.
update customers_dataset
set "Income" = case
		when "Income" = any(array['unknown', '-1', '-10000', 'nan']) then null
		when "Income" = any(array['$45,000', '45k']) then '45000'
		when "Income" = 'fifty thousand' then '50000'
		when "Income" = 'zero' then '0'
		else "Income"
	end
where
	not regexp_like("Income", '^[0-9.]+$') ;


-- To be considered in Canada's top 1% of 
-- income earners—a common statistical baseline 
-- for being "rich" by annual earnings—you must 
-- make at least $293,800 per year.

-- Update the dataset.
-- 3548 rows updated.
update customers_dataset
set "Income" = case
		when "Income" = 'rich' then '293800.0'	
		else "Income"
	end
where
	not regexp_like("Income", '^[0-9.]+$') ;


-- How do we handle these two values? "100k+" and ">200k".
-- Remember TRANSACTION is RUNNING HERE.

-- For 100k+.
-- Distribution of values 
-- Extract the values of income in the 100k bracket.
with income_not_100k_200k as(
	select
	"Income" as income
from
	customers_dataset
where
	"Income" not in ('100k+', '>200k')
)
select
	income
from
	income_not_100k_200k
order by
	income desc
offset
	1124 rows
fetch
	first 10 rows only ;

-- 100k+ and >200k can be any value above.
-- 100k or 200k respectively. In Data Cleaning
-- data is not manufactured. We clean what we know.
-- 2371 rows updated.
update customers_dataset
set "Income" = case
		when "Income" = any(array['100k+', '>200k']) then null
		else "Income"
	end
where
	not regexp_like("Income", '^[0-9.]+$') ;

-- An annual income value of 999999 is possible
-- in Canada. SO the value of 999999 will not
-- be taken as an error. 
-- Besides, the value is needed for categorization
-- only.

-- Change the data type of the column
alter table customers_dataset
alter column "Income" type float
using cast("Income" as float) ;

-- Check the change in the number of decimal places.
select
	"Income",
	round("Income"::numeric,2) as income
from
	customers_dataset
limit 
	10;


-- update the column.
update customers_dataset
set "Income" = round("Income"::numeric,2);



select
	*
from
	customers_dataset
limit 
	10;

-- Commit the changes.
COMMIT;




-- Begin a transaction.
BEGIN ;

-- 8.
-- EDUCATIONAL LEVEL

-- Remove any trailing and leading spaces.
-- Modify the case of text entries to Title case.
-- Display the distinct values afterwards.
select
	distinct
	"Educational Level" as Education,
	initcap(trim("Educational Level")) as Modified
from
	customers_dataset ;


-- Update the values with those without
-- leading or trailing spaces; with title case.
update customers_dataset
set "Educational Level" = initcap(trim("Educational Level")) ;


-- Case statements that show the replacement of 
-- values.
select
	distinct
	"Educational Level",
	case
		when "Educational Level" = any(array['Ba', 'Bachelor''S', 'Bachelors', 'Bs']) then 'Bachelors'
		when "Educational Level" = any(array['Doctorate', 'Phd']) then 'PhD'
		when "Educational Level" = any(array['Ma', 'Master''S', 'Masters', 'Ms']) then 'Masters'
		when "Educational Level" = any(array['High School', 'Highschool', 'Hs', 'Ged']) then 'High School/GED'
		when "Educational Level" = any(array['Dropout']) then 'School Leaver'
		when "Educational Level" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Educational Level" = 'Some College' then 'College'
		else "Educational Level"
	end
from
	customers_dataset ;


-- Update the column.
update customers_dataset
set "Educational Level" = case
		when "Educational Level" = any(array['Ba', 'Bachelor''S', 'Bachelors', 'Bs']) then 'Bachelors'
		when "Educational Level" = any(array['Doctorate', 'Phd']) then 'PhD'
		when "Educational Level" = any(array['Ma', 'Master''S', 'Masters', 'Ms']) then 'Masters'
		when "Educational Level" = any(array['High School', 'Highschool', 'Hs', 'Ged']) then 'High School/GED'
		when "Educational Level" = any(array['Dropout']) then 'School Leaver'
		when "Educational Level" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Educational Level" = 'Some College' then 'College'
		else "Educational Level"
	end ;


select
	*
from
	customers_dataset
order by
	"Order ID"
limit 
	10;

-- Commit the changes
COMMIT ;




-- Begin another transaction
BEGIN ;

-- 9.
-- OCCUPATION.

-- Remove the trailing and leading spaces.
-- Change the casing to Title case.
select
	distinct
	initcap(trim("Occupation"))
from
	customers_dataset;

-- Update the values.
update customers_dataset
set "Occupation" = initcap(trim("Occupation"));


-- Case statements to handle the replacement of
-- certain values.
select
	distinct
	"Occupation",
	case
		when "Occupation" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Occupation" = 'Doc' then 'Doctor'
		when "Occupation" = 'Engr' then 'Engineer'
		when "Occupation" = 'Ret' then 'Retired'
		when "Occupation" = 'Stud' then 'Student'
		when "Occupation" = 'Teach' then 'Teacher'
		when "Occupation" = 'Unemp' then 'Unemployed'
		when "Occupation" = 'Other' then 'Others'
		else "Occupation"
	end as modified_occupation
from
	customers_dataset ;


-- Update the column with the values.
update customers_dataset 
set "Occupation" = case
		when "Occupation" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Occupation" = 'Doc' then 'Doctor'
		when "Occupation" = 'Engr' then 'Engineer'
		when "Occupation" = 'Ret' then 'Retired'
		when "Occupation" = 'Stud' then 'Student'
		when "Occupation" = 'Teach' then 'Teacher'
		when "Occupation" = 'Unemp' then 'Unemployed'
		when "Occupation" = 'Other' then 'Others'
		else "Occupation"
	end ;


-- Commit the changes
COMMIT ;




-- Begin another transaction
BEGIN;

-- 10.
-- COMMUTE DISTANCE.

-- See the distinct values in the column.
-- Remove any trailing or leading spaces.
select
	distinct
	"Commute Distance",
	trim("Commute Distance")
from
	customers_dataset ;


-- Update the column
update customers_dataset
set "Commute Distance" = trim("Commute Distance") ;


-- Case statement to handle value transforms.
select
	distinct
	"Commute Distance",
	case
		when "Commute Distance" = any(array['bike', 'car', 'train', 'walk']) then 'Unspecified'
		when "Commute Distance" = any(array['N/A', 'nan', 'unknown']) then 'Unknown'
		when "Commute Distance" = '0' then 'Inactive'
		else "Commute Distance"
	end as modified_category
from
	customers_dataset ;



-- Update the column.
update customers_dataset
set "Commute Distance" = case
		when "Commute Distance" = any(array['bike', 'car', 'train', 'walk']) then 'Unspecified'
		when "Commute Distance" = any(array['N/A', 'nan', 'unknown']) then 'Unknown'
		when "Commute Distance" = '0' then 'Inactive'
		else "Commute Distance"
	end ;


-- See a few rows
select
	*
from
	customers_dataset
limit
	10;


-- Commit the changes
COMMIT ;




-- Begin another transaction
BEGIN ;


-- 11.
-- HOME OWNERSHIP.

-- Remove the leading or trailing spaces.
-- Change the case of the values to Title case.
select
	distinct
	"Home Ownership",
	initcap(trim("Home Ownership"))
from
	customers_dataset ;


-- Update the values in the column.
update customers_dataset
set "Home Ownership" = initcap(trim("Home Ownership")) ;


-- Case statement to handle data transformation.
select
	distinct
	"Home Ownership",
	case
		when "Home Ownership" = 'Nan' then 'Unknown'
		when "Home Ownership" = 'Rent' then 'Tenant'
		when "Home Ownership" = 'Own' then 'Owner / Outright Owner'
		else "Home Ownership"
	end as modified_ownership
from
	customers_dataset ;


-- Update the dataset.
update customers_dataset
set "Home Ownership" = case
		when "Home Ownership" = 'Nan' then 'Unknown'
		when "Home Ownership" = 'Rent' then 'Tenant'
		when "Home Ownership" = 'Own' then 'Owner / Outright Owner'
		else "Home Ownership"
	end;


select
	distinct
	"Home Ownership"
from
	customers_dataset;


-- Commit the changes
COMMIT ;





-- Begin another transaction.
BEGIN ;

-- 12.
-- NUMBER OF CARS.

-- Remove any leading and/or trailing spaces.
-- Change case of any available text data.
select
	distinct
	"Number of Cars",
	trim("Number of Cars")
from
	customers_dataset ;


-- Count the values.
select
	distinct
	"Number of Cars",
	count(1)
from
	customers_dataset
group by
	"Number of Cars" ;



-- Case statement to handle data transformation.
-- Several can be 3 - 4+ cars.
-- many has no specific defined number.
select
	distinct
	"Number of Cars",
	case
		when "Number of Cars" = any(array['nan', 'unknown', '-1', 'many']) then null
		when "Number of Cars" = 'none' then '0'
		when "Number of Cars" = 'several' then '3'
		else "Number of Cars"
	end
from
	customers_dataset

-- Several has 2034 data points. 
-- This is about 2.4% of the data points for the Number of Cars value of 3,
-- 6.3% of the data points for the Number of Cars value of 4, and
-- 16% of the data points for the Number of Cars value of 5.


-- Update the values in the column.
update customers_dataset
set "Number of Cars" = case
		when "Number of Cars" = any(array['nan', 'unknown', '-1', 'many']) then null
		when "Number of Cars" = 'none' then '0'
		when "Number of Cars" = 'several' then '3'
		else "Number of Cars"
	end ;


-- Return unique values
select
	distinct
	"Number of Cars",
	count(1)
from
	customers_dataset
group by
	"Number of Cars" ;


-- Handle the outlier values.
-- At this point, all the values are numerical
-- or null.
with outlier_values as(
	select
		percentile_cont(0.25) within group (order by cast("Number of Cars" as int)) as y25th_percentile,
		percentile_cont(0.50) within group (order by cast("Number of Cars" as int)) as y50th_percentile,
		percentile_cont(0.75) within group (order by cast("Number of Cars" as int)) as y75th_percentile,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as y99th_percentile
	from
		customers_dataset
)
select
	*
from
	outlier_values ;



with outlier_values as(
	select
		percentile_cont(0.25) within group (order by cast("Number of Cars" as int)) as y25th_percentile,
		percentile_cont(0.50) within group (order by cast("Number of Cars" as int)) as y50th_percentile,
		percentile_cont(0.75) within group (order by cast("Number of Cars" as int)) as y75th_percentile,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as y99th_percentile
	from
		customers_dataset
)
update customers_dataset
set "Number of Cars" = case
			when "Number of Cars" = 99::text then (select y99th_percentile from outlier_values)::text
			else "Number of Cars"
		end ;


-- Commit the changes
COMMIT ;


-- Begin a transaction
BEGIN ;

-- Modify the data type of the Number of Cars column.
alter table customers_dataset
alter column "Number of Cars" type int
using cast("Number of Cars" as int) ;

-- Commit the changes
COMMIT ;




-- Begin another transaction
BEGIN ;

-- 13.
-- NUMBER OF CHILDREN.

-- Remove any trailing and leading spaces.
-- Output the distinct values in the column.
select
	distinct
	"Number of Children",
	trim("Number of Children")
from
	customers_dataset ;


-- Case statement to handle the data transformation.
select
	distinct
	"Number of Children",
	case
		when "Number of Children" = any(array['-5', 'nan', 'unknown', 'many']) then null
		when "Number of Children" = 'twins' then '2'
		when "Number of Children" = 'none' then '0'
		else "Number of Children"
	end as modified
from
	customers_dataset ;

-- Update the values.
update customers_dataset
set "Number of Children" = case
		when "Number of Children" = any(array['-5', 'nan', 'unknown', 'many']) then null
		when "Number of Children" = 'twins' then '2'
		when "Number of Children" = 'none' then '0'
		else "Number of Children"
	end ;


-- Handle Outlier value.
with outlier_correct as(
	select
		percentile_cont(0.25) within group (order by cast("Number of Children" as int)) as y25th_percentile,
		percentile_cont(0.50) within group (order by cast("Number of Children" as int)) as y50th_percentile,
		percentile_cont(0.75) within group (order by cast("Number of Children" as int)) as y75th_percentile,
		percentile_cont(0.99) within group (order by cast("Number of Children" as int)) as y99th_percentile
	from
		customers_dataset
)
select
	*
from
	outlier_correct ;

-- Outlier value of 50 has 1985 data points. 
-- This is about ~0.4% of the data points for the Number of Children value of 1 (median and 75th percentile values),
-- ~0.2% of the data points for the Number of Children value of 0, and
-- ~37% of the data points for the Number of Children value of 4.
-- The OUTLIER VALUE of 50 will be replaced with the VALUE OF 1. This maintains the DISTRIBUTION and the fact that
-- the number of children is greater than 0.

with outlier_correct as(
	select
		percentile_cont(0.25) within group (order by cast("Number of Children" as int)) as y25th_percentile,
		percentile_cont(0.50) within group (order by cast("Number of Children" as int)) as y50th_percentile,
		percentile_cont(0.75) within group (order by cast("Number of Children" as int)) as y75th_percentile,
		percentile_cont(0.99) within group (order by cast("Number of Children" as int)) as y99th_percentile
	from
		customers_dataset
)
update customers_dataset
set "Number of Children" = case
			when "Number of Children" = 50::text then (select y50th_percentile from outlier_correct)::text
			else "Number of Children"
		end ;



-- Modify the data type of the Number of Cars column.
alter table customers_dataset
alter column "Number of Children" type int
using cast("Number of Children" as int) ;


select
	"Number of Children",
	count(*)
from
	customers_dataset
group by
	"Number of Children" ;



-- Commit the changes
COMMIT ;


select
	*
from
	customers_dataset
limit 
	10 ;


-- Begin another transaction
BEGIN ;

-- DROP THE SERIAL NUMBER COLUMN
alter table customers_dataset
drop column serial_number ;

-- Commit changes
COMMIT ;


-- 14.

-- There is an income value of 9,999,999 which is NOT TOTALLY
-- UNREAL, but for the sake of rationality it can be taken as 
-- an outlier value. Income value is used for classification, so
-- its correction will / should not alter the classification.

-- Begin a transaction
BEGIN ;

with outlier_income as(
	select
		percentile_cont(0.25) within group (order by "Income") as y25th_percentile,
		percentile_cont(0.50) within group (order by "Income") as y50th_percentile,
		percentile_cont(0.75) within group (order by "Income") as y75th_percentile,
		percentile_cont(0.99) within group (order by "Income") as y99th_percentile
	from
		customers_dataset
)
select
	*
from
	outlier_income ;

-- 25th percentile value of income is ~$38206.94
-- 50th percentile (or median) value of income is $54884.24
-- 75th percentile value of income is ~$71857.36
-- 99th percentile value of income is ~$116823.71
-- NONE of them can be used to replace the outlier and still maintain the income class.

select
	"Income",
	case
		when "Income" >cast(1000000 as float) then cast(999999 as float)
		else "Income"
	end as modifies_income
from
	customers_dataset
where
	"Income" > 1000000 ;


-- Update the value
-- 1125 records.
update customers_dataset
set "Income" = case
		when "Income" > cast(1000000 as float) then cast(999999 as float)
		else "Income"
	end 
where
	"Income" > 1000000 ;

select
	*
from
	customers_dataset
where
	"Income" is not null
order by
	"Income"  desc
limit
	20 ;

-- Commit changes
COMMIT ;

select
	*
from
	customers_dataset ;


-- Check the number of nulls in each column.

-- Determine the columns that have null values
-- And how many null values are there in each column.
select
	count(*) - count("Date of Purchase") as date_of_purchase_nulls,
	count(*) - count("Customer Age") as customer_age_nulls,
	count(*) - count("Gender") as gender_nulls,
	count(*) - count("Income") as income_nulls,
	count(*) - count("Educational Level") as educational_level_nulls,
	count(*) - count("Occupation") as occupation_nulls,
	count(*) - count("Commute Distance") as commute_distance_nulls,
	count(*) - count("Home Ownership") as home_ownership_nulls,
	count(*) - count("Number of Cars") as number_cars_nulls,
	count(*) - count("Number of Children") as number_children_nulls,
	count(*) - count("Purchased or Not") as purchased_or_not_nulls
from
	customers_dataset ;


	
-- Roll Back
ROLLBACK ;