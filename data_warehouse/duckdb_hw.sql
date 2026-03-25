-- DuckDB SQL script for creating external views for Yellow Taxi data
CREATE OR REPLACE VIEW external_yellow_2024 AS 
SELECT * FROM read_parquet('data/yellow_taxi_2024/*.parquet');

-- Check the external view for yellow taxi data
SELECT * FROM external_yellow_2024 LIMIT 10;

-- Materialize the view 
CREATE OR REPLACE TABLE yellow_2024_native AS 
SELECT * FROM external_yellow_2024;

-- Count the number of trips in the materialized table
SELECT count(*) FROM yellow_2024_native;

--Data read estimation
.timer on
-- Chạy trên External View (Đọc từ tệp Parquet rời rạc)
SELECT DISTINCT(PULocationID) FROM external_yellow_2024;

-- Chạy trên Native Table (Đọc từ file .db đã được tối ưu columnar)
SELECT DISTINCT(PULocationID) FROM yellow_2024_native;

--Counting zero fare trips
SELECT count(*) FROM yellow_2024_native WHERE fare_amount = 0;

--Partitioning & Clustering
COPY (
    SELECT *, 
           CAST(tpep_dropoff_datetime AS DATE) as dropoff_date 
    FROM yellow_2024_native 
    ORDER BY VendorID -- CLUSTER BY VendorID
) 
TO 'yellow_2024_optimized' 
(FORMAT PARQUET, PARTITION_BY (dropoff_date), OVERWRITE_OR_IGNORE);

-- Tạo View để truy vấn
CREATE OR REPLACE VIEW yellow_2024_final AS 
SELECT * FROM read_parquet('yellow_2024_optimized/*/*.parquet', hive_partitioning=1);

