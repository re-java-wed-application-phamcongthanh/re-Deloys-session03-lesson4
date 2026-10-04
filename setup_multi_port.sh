#!/bin/bash
# Script tự động cấu hình Nginx Virtual Hosts chạy song song port 8080 và 8090
set -e

echo "=== 1. Tạo thư mục web roots & copy HTML files ==="
sudo mkdir -p /var/www/beta-app/html
sudo mkdir -p /var/www/internal-app/html

sudo cp beta-app/index.html /var/www/beta-app/html/index.html
sudo cp internal-app/index.html /var/www/internal-app/html/index.html

sudo chown -R www-data:www-data /var/www/beta-app
sudo chown -R www-data:www-data /var/www/internal-app

echo "=== 2. Mở cổng 8080 và 8090 trên UFW Firewall ==="
sudo ufw allow 8080/tcp comment 'Allow Beta App'
sudo ufw allow 8090/tcp comment 'Allow Internal App'

echo "=== 3. Cấu hình Nginx Multi-Port Server Blocks ==="
sudo cp multi-port.conf /etc/nginx/sites-available/multi-port.conf
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/

echo "=== 4. Kiểm tra cú pháp và Reload Nginx ==="
sudo nginx -t
sudo systemctl reload nginx

echo "=== CẤU HÌNH THÀNH CÔNG! Beta App (Port 8080) & Internal App (Port 8090) ==="
