# 🔥 Fire Alarm System - Mobile Application

**Fire Alarm System** là ứng dụng di động giám sát an toàn cháy nổ thông minh, được phát triển để kết nối với hệ thống IoT (ESP32). Ứng dụng giúp người dùng theo dõi các chỉ số môi trường theo thời gian thực và nhận cảnh báo tức thì khi có sự cố xảy ra.

---

## ✨ Tính năng nổi bật

* **📊 Giám sát thời gian thực (Real-time Dashboard):**
    * Hiển thị trực quan các thông số: Nhiệt độ, Độ ẩm, Nồng độ Khói/Gas, Trạng thái Lửa.
    * Giao diện tự động thay đổi màu sắc (**Xanh** = An toàn, **Đỏ** = Nguy hiểm) để gây chú ý.
* **🔔 Cảnh báo thông minh:**
    * Nhận thông báo đẩy (Push Notification) ngay lập tức khi phát hiện cháy hoặc thông số vượt ngưỡng an toàn.
* **📈 Biểu đồ lịch sử:**
    * Xem lại lịch sử biến động của nhiệt độ và độ ẩm qua biểu đồ trực quan.
* **⚙️ Cấu hình thiết bị từ xa:**
    * Cài đặt thông tin WiFi cho thiết bị phần cứng (ESP32) mà không cần nạp lại code.
    * Thay đổi tên định danh thiết bị (Device ID) để quản lý nhiều phòng.
    * Điều chỉnh chu kỳ gửi dữ liệu (Interval) để tiết kiệm năng lượng.
    * Tùy chỉnh ngưỡng báo động (ví dụ: Nhiệt độ > 60°C mới báo).
* **🔐 Bảo mật:**
    * Đăng nhập an toàn qua Email hoặc tài khoản Google.

---

## 📱 Hướng dẫn Cài đặt (Dành cho Developer)

Để chạy ứng dụng này trên máy cá nhân, bạn cần cài đặt **Flutter SDK**.

### 1. Yêu cầu môi trường
* Flutter SDK: `3.x` trở lên
* Dart SDK: `3.x` trở lên
* Thiết bị: Android (5.0+) hoặc iOS.

### 2. Các bước cài đặt
1.  **Clone dự án về máy:**
    ```bash
    git clone [https://github.com/username/smart-fire-alarm.git](https://github.com/username/smart-fire-alarm.git)
    cd smart_fire_alarm_app
    ```

2.  **Tải các thư viện phụ thuộc:**
    ```bash
    flutter pub get
    ```

3.  **Kết nối thiết bị và chạy ứng dụng:**
    ```bash
    flutter run
    ```

---

## 📖 Hướng dẫn Sử dụng (User Manual)

### 1. Đăng nhập & Đăng ký
Khi mở ứng dụng lần đầu, bạn cần xác thực danh tính:
* **Đăng nhập:** Nhập Email và Mật khẩu đã đăng ký -> Nhấn **Đăng nhập**.
* **Đăng ký:** Nhấn vào dòng chữ **"Tạo tài khoản"** bên dưới -> Nhập thông tin để tạo tài khoản mới.
* **Google:** Nhấn vào nút **"Continue with Google"** để đăng nhập nhanh bằng Gmail.

### 2. Màn hình Trang chủ (Dashboard)
Đây là trung tâm điều khiển của bạn:
* **Thẻ trạng thái (Header):**
    * Màu **Xanh lá**: "All Systems Safe" (Nhà bạn đang an toàn).
    * Màu **Đỏ**: "CẢNH BÁO CHÁY!" (Có nguy hiểm, cần kiểm tra ngay).
* **Lưới cảm biến:** Hiển thị giá trị hiện tại của Nhiệt độ, Độ ẩm, Khói và Lửa.

### 3. Xem Lịch sử (Tab History)
Chọn tab **History** ở thanh menu dưới cùng:
* Xem biểu đồ đường thể hiện xu hướng thay đổi của môi trường.
* Sử dụng các nút lọc để chuyển đổi giữa xem Nhiệt độ, Độ ẩm hoặc Khói.

### 4. Cấu hình Thiết bị (Tab Settings)
Đây là tính năng quan trọng giúp bạn điều khiển phần cứng từ xa. Chọn tab **Settings**:

#### A. Kết nối mạng cho thiết bị (WiFi Configuration)
Nếu bạn thay đổi mật khẩu WiFi ở nhà hoặc mang thiết bị đi nơi khác:
1.  Nhập **Tên WiFi (SSID)** mới vào ô tương ứng.
2.  Nhập **Mật khẩu WiFi** mới.
3.  Nhấn **"Lưu cấu hình"**. Thiết bị sẽ tự động nhận lệnh và kết nối sang mạng mới.

#### B. Định danh thiết bị (Device ID)
Để phân biệt giữa các thiết bị (ví dụ: Phòng khách, Nhà bếp):
1.  Nhập tên mong muốn vào ô **Device ID** (ví dụ: `Kitchen_01`).
2.  Nhấn **"Lưu cấu hình"**.
*Lưu ý: Device ID trên App và trên thiết bị phần cứng phải GIỐNG NHAU thì mới nhận được dữ liệu.*

#### C. Tùy chỉnh Ngưỡng báo động
Bạn có thể tự quy định mức độ nguy hiểm:
* Kéo thanh trượt **"Nhiệt độ báo động"** (Ví dụ: đặt lên 60°C).
* Kéo thanh trượt **"Nồng độ khói"**.
* Nhấn **"SAVE CONFIGURATION"** để áp dụng. Khi nhiệt độ vượt qua mức bạn vừa đặt, App sẽ báo đỏ.

#### D. Chu kỳ gửi dữ liệu (Data Interval)
* Kéo thanh trượt để chỉnh tốc độ cập nhật (Ví dụ: 5s gửi một lần hoặc 60s gửi một lần).

---

## ❓ Câu hỏi thường gặp (FAQ)

**Q: Tại sao tôi đã đăng nhập nhưng màn hình chỉ hiện "--" và không có dữ liệu?**
> **A:** Có thể thiết bị phần cứng chưa được bật hoặc chưa kết nối mạng. Hãy kiểm tra lại:
> 1. Thiết bị ESP32 đã được cấp nguồn chưa?
> 2. **Device ID** trong phần Cài đặt của App có khớp với ID được nạp trong code ESP32 không?

**Q: Làm thế nào để đăng xuất tài khoản?**
> **A:** Vào tab **Settings**, cuộn xuống dưới cùng và nhấn nút **"Log Out"**.

**Q: App báo "Lỗi kết nối" khi mở lên?**
> **A:** Hãy kiểm tra kết nối Internet (WiFi/4G) trên điện thoại của bạn.


---
*Copyright © 2025 System Fire Alarm Project.*
