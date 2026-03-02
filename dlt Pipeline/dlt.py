import dlt
import duckdb
import requests

# 1. Định nghĩa tài nguyên lấy dữ liệu từ API (có xử lý phân trang tự động)
@dlt.resource(name="taxi_data", write_disposition="replace")
def ny_taxi_api():
    base_url = "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api"
    page = 1
    while True:
        # Gửi request với tham số page
        response = requests.get(base_url, params={"page": page})
        response.raise_for_status()
        data = response.json()
        
        # Nếu trang trống thì dừng lại
        if not data:
            break
            
        yield data
        page += 1

# 2. Định nghĩa và chạy Pipeline
pipeline = dlt.pipeline(
    pipeline_name="ny_taxi_pipeline",
    destination="duckdb",
    dataset_name="ny_taxi_data"
)

# Chạy nạp dữ liệu
load_info = pipeline.run(ny_taxi_api())
print(f"Pipeline running info: {load_info}")

# 3. Kết nối DuckDB để phân tích trả lời câu hỏi
conn = duckdb.connect(f"{pipeline.pipeline_name}.duckdb")
conn.sql(f"SET search_path = '{pipeline.dataset_name}'")

# --- TRẢ LỜI CÁC CÂU HỎI ---

# Câu 1: Khoảng thời gian (Start/End date)
res1 = conn.sql("""
    SELECT 
        min(tpep_pickup_datetime) as start_date, 
        max(tpep_pickup_datetime) as end_date 
    FROM taxi_data
""").df()
print("\nQuestion 1 Results:")
print(res1)

# Câu 2: Tỷ lệ thanh toán bằng thẻ tín dụng (payment_type = 1)
res2 = conn.sql("""
    SELECT 
        (count(CASE WHEN payment_type = 1 THEN 1 END) * 100.0 / count(*)) as cc_proportion 
    FROM taxi_data
""").df()
print("\nQuestion 2 Results:")
print(res2)

# Câu 3: Tổng tiền Tip
res3 = conn.sql("SELECT sum(tip_amount) as total_tips FROM taxi_data").df()
print("\nQuestion 3 Results:")
print(res3)