--phan vung du lieu cho bang yellow_trips, chia theo nam va thang pickup datetime
COPY (
    SELECT *, 
           year(tpep_pickup_datetime) as y, 
           month(tpep_pickup_datetime) as m 
    FROM yellow_trips
) 
TO 'yellow_taxi' 
(FORMAT PARQUET, PARTITION_BY (y, m), OVERWRITE_OR_IGNORE);


--phan vung du lieu cho bang green_trips, chia theo nam va thang pickup datetime
COPY (
    SELECT *, 
           year(lpep_pickup_datetime) as y, 
           month(lpep_pickup_datetime) as m 
    FROM green_trips
)
TO 'green_taxi' 
(FORMAT PARQUET, PARTITION_BY (y, m), OVERWRITE_OR_IGNORE);

---- Creating external table referring to parquet files for yellow taxi trips
CREATE VIEW ext_yellow_taxi AS SELECT * FROM read_parquet('yellow_taxi/*/*/*.parquet');

-- Creating external table referring to parquet files for green taxi trips
CREATE VIEW ext_green_taxi AS SELECT * FROM read_parquet('green_taxi/*/*/*.parquet');

-- Check yellow trip data
SELECT * FROM ext_yellow_taxi LIMIT 5;

-- Check green trip data
SELECT * FROM ext_green_taxi LIMIT 5;

--- Materizing the views 
CREATE OR REPLACE TABLE yellow_tripdata_non_partitioned AS
SELECT * FROM ext_yellow_taxi

-- Materializing the views 
CREATE OR REPLACE TABLE green_tripdata_non_partitioned AS
SELECT * FROM ext_green_taxi

-- Tạo thư mục partitioned và chia dữ liệu theo ngày (DATE)
COPY (
    SELECT *, 
           CAST(tpep_pickup_datetime AS DATE) AS pickup_date 
    FROM ext_yellow_taxi
) 
TO 'yellow_tripdata_partitioned' 
(FORMAT PARQUET, PARTITION_BY (pickup_date), OVERWRITE_OR_IGNORE);

-- hive_partitioning=1 giúp DuckDB nhận diện cột 'pickup_date' từ tên thư mục
CREATE OR REPLACE VIEW yellow_tripdata_partitioned AS 
SELECT * FROM read_parquet('yellow_tripdata_partitioned/*/*.parquet', hive_partitioning=1);

-- Tạo thư mục partitioned và chia dữ liệu theo ngày (DATE)
COPY (
    SELECT *, 
           CAST(lpep_pickup_datetime AS DATE) AS pickup_date 
    FROM ext_green_taxi
) 
TO 'green_tripdata_partitioned' 
(FORMAT PARQUET, PARTITION_BY (pickup_date), OVERWRITE_OR_IGNORE);

-- hive_partitioning=1 giúp DuckDB nhận diện cột 'pickup_date' từ tên thư mục
CREATE OR REPLACE VIEW green_tripdata_partitioned AS 
SELECT * FROM read_parquet('green_tripdata_partitioned/*/*.parquet', hive_partitioning=1);

--Kiem tra so luong ban ghi trong bang yellow_trips va yellow_tripdata_partitioned de xac nhan du lieu da duoc phan vung dung
SELECT count(*) 
FROM yellow_trips
WHERE CAST(tpep_pickup_datetime AS DATE) = '2019-06-01';

SELECT count(*) 
FROM yellow_tripdata_partitioned 
WHERE pickup_date = '2019-06-01';

--Kiem tra so luong ban ghi trong bang green_trips va green_tripdata_partitioned de xac nhan du lieu da duoc phan vung d
SELECT 'green_tripdata_partitioned' AS table_name,
        pickup_date AS partition_id,
COUNT(*) AS total_rows
FROM green_tripdata_partitioned
GROUP BY pickup_date
ORDER BY total_rows DESC;

---- Creating a partition and cluster table
COPY (
    SELECT *, 
           CAST(lpep_pickup_datetime AS DATE) AS pickup_date 
    FROM ext_green_taxi
    -- CLUSTERING: Sắp xếp dữ liệu vật lý theo cột thường xuyên lọc
    ORDER BY VendorID, pickup_date
) 
TO 'green_taxi_partitioned_clustered' 
(FORMAT PARQUET, PARTITION_BY (pickup_date), OVERWRITE_OR_IGNORE);

-- Tạo view cho bảng đã được partition và cluster
CREATE OR REPLACE VIEW green_taxi_final AS 
SELECT * FROM read_parquet('green_taxi_partitioned_clustered/*/*.parquet', hive_partitioning=1);


.timer on
-- TRUY VẤN 1: Trên bảng chỉ Phân vùng (Partitioned only)
SELECT count(*) as trips
FROM green_tripdata_partitioned
WHERE pickup_date BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID = 1;

-- TRUY VẤN 2: Trên bảng vừa Phân vùng vừa Gom cụm (Partitioned + Clustered)
SELECT count(*) as trips
FROM green_taxi_final
WHERE pickup_date BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID = 1;
-- So sánh thời gian thực thi của hai truy vấn trên để thấy được lợi ích của việc vừa phân vùng vừa gom cụm dữ liệu.
EXPLAIN ANALYZE 
SELECT count(*) 
FROM green_taxi_final 
WHERE pickup_date BETWEEN '2019-06-01' AND '2020-12-31' 
  AND VendorID = 1;