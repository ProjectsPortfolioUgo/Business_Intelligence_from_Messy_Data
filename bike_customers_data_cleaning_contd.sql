/* Bike Customers Dataset.....*/
/* Data Cleaning Continues....*/

select
	*
from
	bike_customers_dataset
order by
	"Order ID"
limit
	10 ;




-- Start a transaction
BEGIN ;

-- 1)
-- Marital Status

-- 1a)
-- Capitalize the first letter of each word.
-- Remove the Trailing and Leading spaces.
-- And check for the distinct values.

select
	distinct initcap(trim("Marital Status"))
from
	bike_customers_dataset;


-- 1b)
-- Update the column.

update bike_customers_dataset
set "Marital Status" = initcap(trim("Marital Status"));


-- 1c)
-- Replace values as required.

select
	"Marital Status",
	case 
		when "Marital Status" = any(array['N/A', 'Nan']) then 'Unknown'
		when "Marital Status" = 'D' then 'Divorced'
		when "Marital Status" = 'M' then 'Married'
		when "Marital Status" = 'W' then 'Widowed'
		when "Marital Status" = 'S' then 'Single'
		when "Marital Status" = 'Living Together' then 'Partnership'
		else "Marital Status"	
	end as marital_values
from
	bike_customers_dataset
where
	"Marital Status" is not null;



-- 1d)
-- Update the column.

update bike_customers_dataset
set "Marital Status" = case 
		when "Marital Status" = any(array['N/A', 'Nan']) then 'Unknown'
		when "Marital Status" = 'D' then 'Divorced'
		when "Marital Status" = 'M' then 'Married'
		when "Marital Status" = 'W' then 'Widowed'
		when "Marital Status" = 'S' then 'Single'
		when "Marital Status" = 'Living Together' then 'Partnership'
		else "Marital Status"	
	end ;


select
	distinct("Marital Status")
from
	bike_customers_dataset ;

-- Commit the changes
COMMIT;
	



-- Start another transaction
BEGIN;

--2)
-- Educational Level

--2a)
-- Capitalize the first letter of each word.
-- Remove the Trailing and Leading spaces.
-- And check for the distinct values.

select
	distinct initcap(trim("Educational Level"))
from
	bike_customers_dataset;


-- 2b)
-- Update the values

update bike_customers_dataset
set "Educational Level" = initcap(trim("Educational Level")) ;


-- 2c)
-- Check for empty spaces.
-- Zero (0)

select
	count("Educational Level")
from
	bike_customers_dataset
where
	"Educational Level" = '';


-- 2d)
-- Apply CASE clause to replace values.

select
	"Educational Level",
	case
		when "Educational Level" = any(array['Ba', 'Bachelor''S', 'Bachelors', 'Bs']) then 'Bachelors'
		when "Educational Level" = any(array['Master''S', 'Masters', 'Ms', 'Ma']) then 'Masters'
		when "Educational Level" = any(array['High School', 'Highschool', 'Hs']) then 'High School'
		when "Educational Level" = any(array['Phd', 'Doctorate']) then 'PhD'
		when "Educational Level" = 'Dropout' then 'School Leaver'
		when "Educational Level" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Educational Level" = 'Ged' then 'GED'
		when "Educational Level" = 'Some College' then 'College'
		else "Educational Level"
	end as education_values	
from
	bike_customers_dataset
where
	"Educational Level" is not null;

-- Checking for null values.
-- Zero (0) rows.
select
	"Educational Level", "Gender"
from
	bike_customers_dataset
where
	"Educational Level" is null ;



-- 2e)
-- Update the Educational Level.

update bike_customers_dataset
set "Educational Level" = case
		when "Educational Level" = any(array['Ba', 'Bachelor''S', 'Bachelors', 'Bs']) then 'Bachelors'
		when "Educational Level" = any(array['Master''S', 'Masters', 'Ms', 'Ma']) then 'Masters'
		when "Educational Level" = any(array['High School', 'Highschool', 'Hs']) then 'High School'
		when "Educational Level" = any(array['Phd', 'Doctorate']) then 'PhD'
		when "Educational Level" = 'Dropout' then 'School Leaver'
		when "Educational Level" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Educational Level" = 'Ged' then 'GED'
		when "Educational Level" = 'Some College' then 'College'
		else "Educational Level"
	end ;


-- Commit changes
COMMIT ;




-- Start another transaction
BEGIN;

-- 3)
-- Occupation


-- 3a)
-- Capitalize the first letter of each word.
-- Remove the Trailing and Leading spaces.
-- And check for the distinct values.

update bike_customers_dataset
set "Occupation" = initcap(trim("Occupation")) ;


-- 3b)
-- Check for empty spaces.
-- Check for null values.
-- Zero (0)

select
	"Occupation", "Educational Level"
from
	bike_customers_dataset
where
	"Occupation" = '' or
	"Occupation" is null 
limit
	10;


-- 3c)
-- Apply CASE clause to replace values.

select
	"Occupation",
	case
		when "Occupation" = any(array['Doc', 'Doctor']) then 'Doctor'
		when "Occupation" = any(array['Engineer', 'Engr']) then 'Engineer'
		when "Occupation" = any(array['Ret', 'Retired']) then 'Retired'
		when "Occupation" = any(array['Stud', 'Student']) then 'Student'
		when "Occupation" = any(array['Teach', 'Teacher']) then 'Teacher'
		when "Occupation" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Occupation" = any(array['Unemp', 'Unemployed']) then 'Unemployed'
		when "Occupation" = 'Other' then 'Unspecified'
		else "Occupation"
	end as occupation_values
from
	bike_customers_dataset
where
	"Occupation" is not null ;


-- 3d)
-- Update the values

update bike_customers_dataset
set "Occupation" = case
		when "Occupation" = any(array['Doc', 'Doctor']) then 'Doctor'
		when "Occupation" = any(array['Engineer', 'Engr']) then 'Engineer'
		when "Occupation" = any(array['Ret', 'Retired']) then 'Retired'
		when "Occupation" = any(array['Stud', 'Student']) then 'Student'
		when "Occupation" = any(array['Teach', 'Teacher']) then 'Teacher'
		when "Occupation" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Occupation" = any(array['Unemp', 'Unemployed']) then 'Unemployed'
		when "Occupation" = 'Other' then 'Unspecified'
		else "Occupation"
	end ; 



-- Commit changes
COMMIT;




-- 4)
-- Gender column assessment.
-- Check for leading and trailing spaces. 
-- Zero (0) rows.

select
	"Gender"
from
	bike_customers_dataset 
where
	"Gender" <> trim("Gender");




-- Start another transaction
BEGIN;

-- 5)
-- Commute Distance


-- 5a)
-- Check for missing data points if any.
-- Zero (0) rows.

select
	"Commute Distance", "Occupation", "Gender"
from
	bike_customers_dataset
where
	"Commute Distance" is null or
	"Commute Distance" = '';

	

-- 5b)
-- Remove any Leading and Trailing spaces
-- Output the unique values in the column

select
	distinct initcap(trim("Commute Distance"))
from
	bike_customers_dataset
where 
	"Commute Distance" is not null ;


-- 5c)
-- Update the values

update bike_customers_dataset
set "Commute Distance" = lower(trim("Commute Distance"))
where "Commute Distance" <> '' or "Commute Distance" is not null;



-- 5d)
-- Replace the values using the
-- CASE statement.
-- Distance of zero is still less than 1.

select
	"Commute Distance",
	case
		when "Commute Distance" = any(array['nan', 'unknown']) then 'Unknown'
		when "Commute Distance" = any(array['bike', 'car', 'train', 'walk', 'n/a']) then 'Unspecified'
		when "Commute Distance" = '0' then '<1 mile'
		else "Commute Distance"
	end as commute_values
from
	bike_customers_dataset
where
	"Commute Distance" is not null ;


-- 5e)
-- Update the column

update bike_customers_dataset
set "Commute Distance" = case
		when "Commute Distance" = any(array['nan', 'unknown']) then 'Unknown'
		when "Commute Distance" = any(array['bike', 'car', 'train', 'walk', 'n/a']) then 'Unspecified'
		when "Commute Distance" = '0' then '<1 mile'
		else "Commute Distance"
	end ;



-- Commit changes
COMMIT;




-- Start another transaction
BEGIN ;

-- 6)
-- Home Ownership


-- 6a)
-- Remove any trailing and leading spaces.
-- Uniformize the Capitalization of each entry
-- Check for unique values

select
	distinct(initcap(trim("Home Ownership")))
from
	bike_customers_dataset ;

-- 6b)
-- Update values accordingly

update bike_customers_dataset
set "Home Ownership" = initcap(trim("Home Ownership"));


select
	*
from
	bike_customers_dataset
where
	"Home Ownership" is null 
limit 
	5;


-- 6c)
-- Case clause for value substitution.

select
	"Home Ownership",
	case
		when "Home Ownership" = 'Living With Parents' then 'Co-Resident'
		when "Home Ownership" = 'Own' then 'Homeowner/Freeholder'
		when "Home Ownership" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Home Ownership" = 'Rent' then 'Tenant'
		else "Home Ownership"
	end as home_ownership_values
from
	bike_customers_dataset ;


-- 6d)
-- Update the values accordingly

update bike_customers_dataset
set "Home Ownership" = case
		when "Home Ownership" = 'Living With Parents' then 'Co-Resident'
		when "Home Ownership" = 'Own' then 'Homeowner/Freeholder'
		when "Home Ownership" = any(array['Nan', 'Unknown']) then 'Unknown'
		when "Home Ownership" = 'Rent' then 'Tenant'
		else "Home Ownership"
	end;


-- Commit the changes
COMMIT;





-- Start another transaction
BEGIN;

-- 7)
-- "Number of Cars"

-- 7a)
-- Check for unique entries that are composed
-- entirely of text. Have ZERO Numbers in them.


select
	distinct "Number of Cars"
from
	bike_customers_dataset
where
	regexp_like("Number of Cars", '[^0-9.-]');


-- 7b)
-- Replace values as needed.
-- 10074 rows

-- 1-2 cars: Usually referred to as a "few" or a "couple".
-- 3-4 cars: Commonly accepted as "several" in general or practical terms.
-- 5 or more cars: Often translates to "many" or a "fleet".

select
	"Number of Cars",
	case
		when "Number of Cars" = 'many' then '5'
		when "Number of Cars" = 'none' then '0'
		when "Number of Cars" = 'several' then '4'
		else "Number of Cars"
	end as number_of_cars
from
	bike_customers_dataset 
where
	regexp_like("Number of Cars", '[^0-9.-]');


-- 7c)
-- Update the values accordingly
-- 10074 rows updated.

update bike_customers_dataset
set "Number of Cars" = case
		when "Number of Cars" = 'many' then '5'
		when "Number of Cars" = 'none' then '0'
		when "Number of Cars" = 'several' then '4'
		else "Number of Cars"
	end
where
	regexp_like("Number of Cars", '[^0-9.-]');
	

-- 7d)
-- Output the unique number values

select
	distinct "Number of Cars"
from
	bike_customers_dataset
where
	"Number of Cars" ~ '^[0-9-]+$';



-- 7e)
-- Treat the negative values as dummy data. Replace them 
-- with the missing value parameter, null.
-- 1961 records.

select
	"Number of Cars",
	case
		when cast("Number of Cars" as int) < 0 then null
		else "Number of Cars"
	end
from
	bike_customers_dataset 
where
	regexp_like("Number of Cars",  '^[0-9-]+$') and
	cast("Number of Cars" as int) < 0 ;



-- 7f)
-- Update the data accordingly.
-- 1961 records.

update bike_customers_dataset
set "Number of Cars" = case
		when cast("Number of Cars" as int) < 0 then null
		else "Number of Cars"
	end
where
	regexp_like("Number of Cars",  '^[0-9-]+$') and
	cast("Number of Cars" as int) < 0 ;


-- 7g)
-- Calculate median value to replace 'nan', 'unknown', and null.
-- Calculate 99th percentile value to replace outlier values.

select
	percentile_cont(0.01) within group (order by cast("Number of Cars" as int)) as the_1th_percentile,
	percentile_cont(0.5) within group (order by cast("Number of Cars" as int)) as median_number_of_cars,
	percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as the_99th_percentile
from
	bike_customers_dataset
where
	regexp_like("Number of Cars", '^[0-9]+$')


-- 7h)
-- Replace the values for 'nan' and 'unknown' with the Median
-- 5952 rows.

with cars_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Cars" as int)) as median_number_of_cars,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Cars", '^[0-9]')
)
select
	"Number of Cars",
	case
		when "Number of Cars" = any(array['nan', 'unknown']) or "Number of Cars" is null then cast((select median_number_of_cars from cars_percentiles) as text)
		else "Number of Cars"
	end
from
	bike_customers_dataset 
where
	"Number of Cars" in ('nan', 'unknown') or
	"Number of Cars" is null ;


-- 7i
-- Update the values accordingly.
-- 5952 rows updated.

with cars_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Cars" as int)) as median_number_of_cars,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Cars", '^[0-9]')
)
update bike_customers_dataset
set "Number of Cars" = case
		when "Number of Cars" = any(array['nan', 'unknown']) or "Number of Cars" is null then cast((select median_number_of_cars from cars_percentiles) as text)
		else "Number of Cars"
	end 
where
	"Number of Cars" in ('nan', 'unknown') or
	"Number of Cars" is null ; 


-- 7j
-- Handle Outliers
-- 1965 rows.

with cars_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Cars" as int)) as median_number_of_cars,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Cars", '^[0-9]')
)
select
	"Number of Cars",
	case
		when cast("Number of Cars" as float) > cars_percentiles.the_99th_percentile then cars_percentiles.the_99th_percentile
		else cast("Number of Cars" as float)
	end as cars_number_outlier
from
	bike_customers_dataset,
	cars_percentiles
where
	cast("Number of Cars" as float) > cars_percentiles.the_99th_percentile ;


-- 7k.
-- Replace the values appropriately.
-- 1965 rows affected.

with cars_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Cars" as int)) as median_number_of_cars,
		percentile_cont(0.99) within group (order by cast("Number of Cars" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Cars", '^[0-9]')
)
update bike_customers_dataset
set "Number of Cars" = case
		when cast("Number of Cars" as float) > (select the_99th_percentile from cars_percentiles) then (select the_99th_percentile from cars_percentiles)
		else cast("Number of Cars" as float)
	end
where
	cast("Number of Cars" as float) > (select the_99th_percentile from cars_percentiles) ;



-- 7l)
-- Alter the data type of the "Number of Cars" column

alter table bike_customers_dataset
alter column "Number of Cars" type int
using cast("Number of Cars" as int) ;


-- 7m)
-- Output the distinct values of the "Number of Cars" column

select
	distinct "Number of Cars"
from
	bike_customers_dataset ;


-- Commit the results
COMMIT ;




-- 8)
-- "Number of Children"

BEGIN;

-- 8a)
-- Check for unique entries that are composed
-- entirely of text. Have ZERO Numbers in them.


select
	distinct "Number of Children"
from
	bike_customers_dataset
where
	regexp_like("Number of Children", '[^0-9.-]');


-- 8b)
-- Case statement to replace values as needed.
-- 10058 rows

-- many: Linguistically and Culturally, the minimum number is 4 children. Google Search - 5th July 2026.
-- twins: means 2 children.
-- none: represents zero (0).

select
	"Number of Children",
	case
		when "Number of Children" = 'many' then '4'
		when "Number of Children" = 'none' then '0'
		when "Number of Children" = 'twins' then '2'
		else "Number of Children"
	end as number_of_children
from
	bike_customers_dataset 
where
	regexp_like("Number of Children", '[^0-9.-]');


-- 8c)
-- Update the values accordingly
-- 10058 records. Later 6083 records.

update bike_customers_dataset
set "Number of Children" = case
		when "Number of Children" = 'many' then '4'
		when "Number of Children" = 'none' then '0'
		when "Number of Children" = 'twins' then '2'
		else "Number of Children"
	end
where
	regexp_like("Number of Children", '[^0-9.-]');


-- 8d)
-- Output the unique number values

select
	distinct "Number of Children"
from
	bike_customers_dataset
where
	"Number of Children" ~ '^[0-9-]+$';



-- 8e)
-- Treat the negative values as dummy data. Replace them 
-- with the missing value parameter, null.
-- 1957 records.

select
	"Number of Children",
	case
		when cast("Number of Children" as int) < 0 then null
		else "Number of Children"
	end
from
	bike_customers_dataset 
where
	regexp_like("Number of Children",  '^[0-9-]+$') and
	cast("Number of Children" as int) < 0 ;



-- 8f)
-- Update the data accordingly.
-- 1957 records.

update bike_customers_dataset
set "Number of Children" = case
		when cast("Number of Children" as int) < 0 then null
		else "Number of Children"
	end
where
	regexp_like("Number of Children",  '^[0-9-]+$') and
	cast("Number of Children" as int) < 0 ;


select
	"Number of Children", "Number of Cars"
from
	bike_customers_dataset
where
	"Number of Children" is null 
limit
	5 ;


-- 8g)
-- Calculate median value to replace 'nan', 'unknown', and null
-- Calculate 99th percentile value to replace outlier values.

select
	percentile_cont(0.5) within group (order by cast("Number of Children" as int)) as median_number_of_cars,
	percentile_cont(0.99) within group (order by cast("Number of Children" as int)) as the_99th_percentile
from
	bike_customers_dataset
where
	regexp_like("Number of Children", '^[0-9]+$')


-- 8h)
-- Case statement to test the replacement of 'nan', 'unknown' and
-- null values with the Median.
-- 6063 records.

with children_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Children" as int)) as median_number_of_children,
		percentile_cont(0.99) within group (order by cast("Number of Children" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Children", '^[0-9]')
)
select
	"Number of Children",
	case
		when "Number of Children" = any(array['nan', 'unknown']) or "Number of Children" is null 
			then cast((select median_number_of_children from children_percentiles) as text)
		else "Number of Children"
	end
from
	bike_customers_dataset 
where
	"Number of Children" in ('nan', 'unknown') or
	"Number of Children" is null ;


-- 8i)
-- Update the values accordingly.
-- 6063 rows.

with children_percentiles as(
	select
		percentile_cont(0.5) within group (order by cast("Number of Children" as int)) as median_number_of_children,
		percentile_cont(0.99) within group (order by cast("Number of Children" as int)) as the_99th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Children", '^[0-9]')
)
update bike_customers_dataset
set "Number of Children" = case
		when "Number of Children" = any(array['nan', 'unknown']) or "Number of Children" is null 
			then cast((select median_number_of_children from children_percentiles) as text)
		else "Number of Children"
	end
where
	"Number of Children" in ('nan', 'unknown') or
	"Number of Children" is null;


-- 8j
-- Handle Outliers
-- 2099 rows.

with children_percentiles as(
	select
		percentile_cont(0.9971) within group (order by cast("Number of Children" as int)) as the_9971th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Children", '^[0-9]')
)
select
	"Number of Children",
	case
		when cast("Number of Children" as float) > children_percentiles.the_9971th_percentile then children_percentiles.the_9971th_percentile
		else cast("Number of Children" as float)
	end as children_number_outlier
from
	bike_customers_dataset,
	children_percentiles
where
	cast("Number of Children" as float) > children_percentiles.the_9971th_percentile ;


-- 8k.
-- Replace the values appropriately.
-- 1985 rows updated.

with children_percentiles as(
	select
		percentile_cont(0.9971) within group (order by cast("Number of Children" as int)) as the_9971th_percentile
	from
		bike_customers_dataset
	where
		regexp_like("Number of Children", '^[0-9]')
)
update bike_customers_dataset
set "Number of Children" = case
		when cast("Number of Children" as float) > (select the_9971th_percentile from children_percentiles) then (select the_9971th_percentile from children_percentiles)
		else cast("Number of Children" as float)
	end
where
	cast("Number of Children" as float) > (select the_9971th_percentile from children_percentiles) ;


-- 8l)
-- Alter the data type of the "Number of Children" column

alter table bike_customers_dataset
alter column "Number of Children" type int
using cast("Number of Children" as int) ;


-- 8m)
-- Output the distinct values of the "Number of Children" column

select
	distinct "Number of Children"
from
	bike_customers_dataset ; 


-- Commit the changes
COMMIT;




-- 9)
-- "Purchased or Not".

-- Start a new transaction
BEGIN;


-- 9a)
-- Remove any Leading and Trailing spaces.
-- Change the casing of values.

select
	"Purchased or Not",
	initcap(trim("Purchased or Not"))
from
	bike_customers_dataset
where
	"Purchased or Not" is not null ;

-- 9b)
-- Update the entries

update bike_customers_dataset
set "Purchased or Not" = initcap(trim("Purchased or Not")) ;


-- 9c)
-- Output the unique entries in the column.

select
	distinct "Purchased or Not"
from
	bike_customers_dataset
where
	"Purchased or Not" is not null ;


-- 9d)
-- CASE statements for value replacement.

select
	"Purchased or Not",
	case
		when "Purchased or Not" = any(array['?', '??', 'Nan', 'Unknown']) then 'Unknown'
		when "Purchased or Not" = 'Maybe' then 'Unspecified'
		when "Purchased or Not" = any(array['1', 'Bought', 'Purchased', 'True', 'Y', 'Yes']) then 'Yes'
		when "Purchased or Not" = any(array['0', 'Did Not Buy', 'False', 'N', 'No', 'Not Purchased']) then 'No'
		else "Purchased or Not"
	end as "purchase_values"
from
	bike_customers_dataset
where
	"Purchased or Not" is not null ;


-- 9e)
-- Update the values accordingly.

update bike_customers_dataset
set "Purchased or Not" = case
		when "Purchased or Not" = any(array['?', '??', 'Nan', 'Unknown']) then 'Unknown'
		when "Purchased or Not" = 'Maybe' then 'Unspecified'
		when "Purchased or Not" = any(array['1', 'Bought', 'Purchased', 'True', 'Y', 'Yes']) then 'Yes'
		when "Purchased or Not" = any(array['0', 'Did Not Buy', 'False', 'N', 'No', 'Not Purchased']) then 'No'
		else "Purchased or Not"
	end ;


-- Check the unique values
select
	distinct "Purchased or Not"
from
	bike_customers_dataset ;


-- 9f)
-- Change the column title.

alter table bike_customers_dataset
rename column "Purchased or Not" to "Purchase Made" ;


-- Commit changes
COMMIT ;



-- Start another transaction
BEGIN ;

-- Drop the serial_number column
alter table bike_customers_dataset
drop column "serial_number" ;

-- Commit changes
COMMIT ;


-- Check number of customers
select
	count(distinct "Order ID") as "Number of Customers",
	count("Order ID") as "Number of Visits"
from
	bike_customers_dataset;



select
	*
from
	bike_customers_dataset ;



rollback;