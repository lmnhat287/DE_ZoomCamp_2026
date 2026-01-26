--implicit inner join
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough",  '|' ,zpu."Zone") as "pickup_location",
	CONCAT(zdo."Borough",  '|' ,zdo."Zone") as "dropof_location"
from 
	yellow_taxi_trips t,
	zones zpu,
	zones zdo
where
	t."PULocationID" = zpu."LocationID" and
	t."DOLocationID" = zdo."LocationID"
limit 200

--explicit inner join 
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough",  '|' ,zpu."Zone") as "pickup_location",
	CONCAT(zdo."Borough",  '|' ,zdo."Zone") as "dropof_location"
from 
	yellow_taxi_trips t
join 
	zones zpu on t."PULocationID" = zpu."LocationID"
join
	zones zdo on t."DOLocationID" = zdo."LocationID"
limit 200

--checking data not in zones table
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
from 
	yellow_taxi_trips t
where 
	"PULocationID" not in (select "LocationID" from zones) or
	"DOLocationID" not in (select "LocationID" from zones)
limit 100

--checking data is null
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
from 
	yellow_taxi_trips t
where 
	"PULocationID" IS NULL or
	"DOLocationID" IS NULL
limit 100

--Left join when data is missing on zones but present on yellow_taxi_trips
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough",  '|' ,zpu."Zone") as "pickup_location",
	CONCAT(zdo."Borough",  '|' ,zdo."Zone") as "dropof_location"
from 
	yellow_taxi_trips t
left join 
	zones zpu on t."PULocationID" = zpu."LocationID"
join
	zones zdo on t."DOLocationID" = zdo."LocationID"
limit 200

--Right join when data is missing on yellow_taxi_trips but present on zones
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough",  '|' ,zpu."Zone") as "pickup_location",
	CONCAT(zdo."Borough",  '|' ,zdo."Zone") as "dropof_location"
from 
	yellow_taxi_trips t
right join 
	zones zpu on t."PULocationID" = zpu."LocationID"
join
	zones zdo on t."DOLocationID" = zdo."LocationID"
limit 200

--Outer join = left + right for each situation
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough",  '|' ,zpu."Zone") as "pickup_location",
	CONCAT(zdo."Borough",  '|' ,zdo."Zone") as "dropof_location"
from 
	yellow_taxi_trips t
outer join 
	zones zpu on t."PULocationID" = zpu."LocationID"
join
	zones zdo on t."DOLocationID" = zdo."LocationID"
limit 200

--group by 
select 
	cast(tpep_dropoff_datetime as DATE) as "Day Drop off",
	count (1)
from
	yellow_taxi_trips t
group by
	cast(tpep_dropoff_datetime as DATE)
limit 100

--order by day 
select 
	cast(tpep_dropoff_datetime as DATE) as "Day Drop off",
	count (1)
from
	yellow_taxi_trips t
group by
	cast(tpep_dropoff_datetime as DATE)
order by 
	"Day Drop off" ASC
limit 100

--order by count 
select 
	cast(tpep_dropoff_datetime as DATE) as "Day Drop off",
	count (1) as "count"
from
	yellow_taxi_trips t
group by
	cast(tpep_dropoff_datetime as DATE)
order by 
	"count" DESC
limit 100

--Other Aggregations
select 
	cast(tpep_dropoff_datetime as DATE) as "Day Drop off",
	count (1) as "count",
	MAX(total_amount) as "total amount",
	MAX(passenger_count) as "passenger_count"
from
	yellow_taxi_trips t	
group by
	cast(tpep_dropoff_datetime as DATE)
order by 
	"count" DESC
limit 100

--Grouping by Multiple Fields
select 
	cast(tpep_dropoff_datetime as DATE) as "day",
	"DOLocationID",
	count (1) as "count",
	MAX(total_amount) as "total amount",
	MAX(passenger_count) as "passenger_count"
from
	yellow_taxi_trips t	
group by
	1, 2
order by
	"day" asc,
	"DOLocationID" asc
limit 100

--question 3 homework
select count (*) 
from green_taxi_data t
where "trip_distance" <= 1
and "lpep_pickup_datetime" >= '2025-11-01'
and "lpep_pickup_datetime" < '2025-12-01'


--question 4 homework
select "lpep_pickup_datetime", "trip_distance"
from green_taxi_data t
where "trip_distance" < 100
and "lpep_pickup_datetime" >= '2025-11-01'
and "lpep_pickup_datetime" < '2025-12-01'
order by "trip_distance" DESC

--question 5 homework
select zpu."Zone" as "pickup_location",sum(t.total_amount) as "total_sum"
from green_taxi_data t
join zones zpu on t."PULocationID" = zpu."LocationID"
where t."lpep_pickup_datetime" >= '2025-11-18'
and t."lpep_pickup_datetime" < '2025-11-19'
group by zpu."Zone"
order by "total_sum" DESC

--question 6 homework max version
SELECT 
	zdo"Borough",zdo."Zone",max (g.tip_amount)
FROM public.green_taxi_data g
join public.zones zpu on  g."PULocationID" = zpu."LocationID"
join public.zones zdo on  g."DOLocationID" = zdo."LocationID"
WHERE 
	g.lpep_pickup_datetime >= '2025-11-01' 
	and  g.lpep_pickup_datetime < '2025-12-01'
	and zpu."Zone" = 'East Harlem North'
group by 1,2
order by 3 DESC
--question 6 homework sum version
SELECT 
	zdo"Borough",zdo."Zone",sum (g.tip_amount)
FROM public.green_taxi_data g
join public.zones zpu on  g."PULocationID" = zpu."LocationID"
join public.zones zdo on  g."DOLocationID" = zdo."LocationID"
WHERE 
	g.lpep_pickup_datetime >= '2025-11-01' 
	and  g.lpep_pickup_datetime < '2025-12-01'
	and zpu."Zone" = 'East Harlem North'
group by 1,2
order by 3 DESC