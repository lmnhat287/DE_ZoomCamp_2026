import os
import urllib.request
from concurrent.futures import ThreadPoolExecutor

# Cấu hình đường dẫn
DOWNLOAD_DIR = "data/yellow_taxi_2024"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-"
MONTHS = [f"{i:02d}" for i in range(1, 7)] # Tháng 1 đến tháng 6

def download_file(month):
    url = f"{BASE_URL}{month}.parquet"
    file_path = os.path.join(DOWNLOAD_DIR, f"yellow_tripdata_2024-{month}.parquet")
    
    try:
        if os.path.exists(file_path):
            print(f"File {file_path} đã tồn tại. Bỏ qua.")
            return file_path
        print(f"Đang tải {url}...")
        urllib.request.urlretrieve(url, file_path)
        print(f"Đã xong: {file_path}")
        return file_path
    except Exception as e:
        print(f"Lỗi tải {url}: {e}")
        return None

if __name__ == "__main__":
    with ThreadPoolExecutor(max_workers=4) as executor:
        executor.map(download_file, MONTHS)
    print("--- Dữ liệu 2024 (T1-T6) đã sẵn sàng ---")