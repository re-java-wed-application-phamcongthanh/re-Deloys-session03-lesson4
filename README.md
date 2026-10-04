# Bài 4: Chạy song song nhiều cổng dịch vụ (Nginx Virtual Hosts)

## 🎯 1. Mục Tiêu
- Cấu hình Nginx chạy song song hai trang web tĩnh độc lập trên cùng một địa chỉ IP máy chủ ảo thông qua việc phân chia cổng dịch vụ (**8080** và **8090**).
- Thiết lập tường lửa UFW và DigitalOcean Cloud Firewall mở các cổng tương ứng để người dùng ngoài Internet truy cập được.

---

## 📋 2. Yêu Cầu Chi Tiết (Requirements)
- **Bối cảnh**: Triển khai hai môi trường thử nghiệm độc lập: trang kiểm thử ứng dụng (**Beta App**) và trang thông tin nội bộ (**Internal App**) chạy song song trên cùng một Droplet.
- **Ràng buộc**:
  1. Tạo hai thư mục lưu trữ mã nguồn riêng biệt: `/var/www/beta-app/html/` và `/var/www/internal-app/html/`. Mỗi thư mục chứa một file `index.html` có tiêu đề tương ứng.
  2. Cấu hình Server Block của Nginx lắng nghe trên cổng **8080** trỏ root về thư mục `beta-app`.
  3. Cấu hình Server Block thứ hai lắng nghe trên cổng **8090** trỏ root về thư mục `internal-app`.
  4. Mở các cổng `8080/tcp` và `8090/tcp` trên tường lửa UFW và trên DigitalOcean Cloud Firewall.

---

## 🛠️ 3. Hướng Dẫn Các Bước Thực Hiện (Step-by-Step Guide)

### Bước 1: Tạo Thư Mục Web Root & Các File HTML Độc Lập

```bash
# 1. Tạo thư mục cho Beta App (Port 8080)
sudo mkdir -p /var/www/beta-app/html

# 2. Tạo thư mục cho Internal App (Port 8090)
sudo mkdir -p /var/www/internal-app/html
```

Tạo file `/var/www/beta-app/html/index.html`:
```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Beta App - Port 8080</title>
</head>
<body style="background: #1e293b; color: #38bdf8; text-align: center; padding-top: 100px;">
    <h1>🚀 Welcome to Beta App Testing Environment (Port 8080)</h1>
</body>
</html>
```

Tạo file `/var/www/internal-app/html/index.html`:
```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Internal App - Port 8090</title>
</head>
<body style="background: #0f172a; color: #4ade80; text-align: center; padding-top: 100px;">
    <h1>🔒 Welcome to Internal Dashboard Portal (Port 8090)</h1>
</body>
</html>
```

### Bước 2: Tạo File Cấu Hình Multi-Port Server Blocks trong Nginx
Tạo file `/etc/nginx/sites-available/multi-port.conf`:
```nginx
# Server Block 1: Beta App trên Port 8080
server {
    listen 8080;
    server_name _;

    root /var/www/beta-app/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

# Server Block 2: Internal App trên Port 8090
server {
    listen 8090;
    server_name _;

    root /var/www/internal-app/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Bước 3: Kích Hoạt Cấu Hình & Mở Cổng Tường Lửa UFW

```bash
# 1. Tạo Symlink kích hoạt cấu hình
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/

# 2. Mở cổng 8080 và 8090 trên UFW
sudo ufw allow 8080/tcp comment 'Allow Beta App Port 8080'
sudo ufw allow 8090/tcp comment 'Allow Internal App Port 8090'
sudo ufw status verbose

# 3. Kiểm tra cú pháp và Reload Nginx
sudo nginx -t
sudo systemctl reload nginx
```

---

## ✅ 4. Lệnh Kiểm Tra & Kết Quả Mong Đợi (Verification)

### 1. Truy cập Beta App trên Cổng 8080:
```bash
curl http://<IP_ADDRESS_DROPLET>:8080
```
**Kết quả mong đợi**: Trả về đúng trang HTML của Beta App (`Welcome to Beta App Testing Environment`).

### 2. Truy cập Internal App trên Cổng 8090:
```bash
curl http://<IP_ADDRESS_DROPLET>:8090
```
**Kết quả mong đợi**: Trả về đúng trang HTML của Internal App (`Welcome to Internal Dashboard Portal`).
