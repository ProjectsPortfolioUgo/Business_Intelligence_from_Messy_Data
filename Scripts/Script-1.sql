DROP TABLE public.newtable ;

CREATE TABLE public.newtable (
    "Order ID" integer NULL,
    "Date of Purchase" varchar(50) NULL,
    "Customer Age" varchar(50) NULL,
    gender varchar(50) NULL,
    "Marital Status" varchar(50) NULL,
    income varchar(50) NULL,
    "Educational Level" varchar(50) NULL,
    occupation varchar(50) NULL,
    "Product Category" varchar(50) NULL,
    "Type of Bike" varchar(50) NULL,
    "Commute Distance" varchar(50) NULL,
    "Home Ownership" varchar(50) NULL,
    "Number of Cars" varchar(50) NULL,
    "Number of Children" varchar(50) NULL,
    "Purchased or Not" varchar(50) NULL
);


DROP TABLE public.messy_data_bike_sales ;

CREATE TABLE public.messy_data_bike_sales (
    "Order ID" integer NULL,
    "Date of Purchase" varchar(50) NULL,
    "Quantity sold" varchar(50) NULL,
    "Total Revenue" real NULL,
    "Cost" real NULL,
    "Profit" real NULL,
    "Discount Applied" varchar(50) NULL,
    "Customer Age" varchar(50) NULL,
    "Gender" varchar(50) NULL,
    "Marital Status" varchar(50) NULL,
    "Income" varchar(50) NULL,
    "Educational Level" varchar(50) NULL,
    "Occupation" varchar(50) NULL,
    "Product Category" varchar(50) NULL,
    "Type of Bike" varchar(50) NULL,
    "Model" varchar(50) NULL,
    "Color" varchar(50) NULL,
    "Size" varchar(50) NULL,
    "Brand" varchar(50) NULL,
    "Commute Distance" varchar(50) NULL,
    "Home Ownership" varchar(50) NULL,
    "Number of Cars" varchar(50) NULL,
    "Number of Children" varchar(50) NULL,
    "Purchased or Not" varchar(50) NULL
);