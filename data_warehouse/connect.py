import duckdb

# 1. Tạo file database DuckDB
con = duckdb.connect('ny_taxi_dwh.db')

# 2. Cài đặt và tải extension Postgres
con.execute("INSTALL postgres; LOAD postgres;")

# 3. Kết nối tới Postgres hiện tại của bạn
# Thay đổi thông số theo đúng docker-compose cũ của bạn
pg_conn_str = "host=localhost port=5432 dbname=ny_taxi user=root password=root"
con.execute(f"ATTACH '{pg_conn_str}' AS pg_db (TYPE POSTGRES);")

# 4. Sao chép dữ liệu (Ví dụ cho Yellow Taxi)
print("Đang di chuyển dữ liệu Yellow Taxi...")
con.execute("CREATE TABLE yellow_trips AS SELECT * FROM pg_db.yellow_tripdata;")

print("Đang di chuyển dữ liệu Green Taxi...")
con.execute("CREATE TABLE green_trips AS SELECT * FROM pg_db.green_tripdata;")

print("Hoàn tất! Dữ liệu đã nằm trong file ny_taxi_dwh.db")