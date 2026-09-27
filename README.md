# Enigma Finance - Ứng dụng Quản lý Tài chính & Chi tiêu Cá nhân

Ứng dụng đa nền tảng chất lượng cao được xây dựng bằng **Flutter 3.47+**, hỗ trợ tối ưu cho cả hai hệ điều hành **iOS** và **Android**.

---

## 🌟 Tính năng chính

1. **Tổng quan tài sản & Dòng tiền (Dashboard)**
   - Thẻ tổng tài sản hiện đại với hiệu ứng gradient, chế độ bảo mật ẩn/hiện số dư (`•••••• ₫`).
   - Thống kê nhanh tổng thu, tổng chi và tỷ lệ thặng dư dòng tiền trong tháng.
   - Thanh tiến độ kiểm soát hạn mức ngân sách tháng với cảnh báo khi vượt định mức.
   - Danh sách ví/tài khoản trượt ngang tiện lợi.
   - Danh sách giao dịch gần nhất kèm xem chi tiết, chỉnh sửa và xóa nhanh.

2. **Sổ giao dịch toàn diện (Transactions)**
   - Tìm kiếm giao dịch thời gian thực theo tên, danh mục, ghi chú.
   - Bộ lọc linh hoạt: Tất cả / Chi tiêu / Thu nhập.
   - Bộ lọc thời gian: Tuần này / Tháng này / Năm nay / Toàn bộ.
   - Thao tác vuốt để xóa giao dịch (Swipe-to-delete) có hộp thoại xác nhận an toàn.
   - Xem chi tiết giao dịch: ngày giờ, danh mục, nguồn ví, ghi chú và tùy chọn chỉnh sửa.

3. **Báo cáo & Phân tích trực quan (Statistics & Analytics)**
   - Biểu đồ phân bổ chi tiêu Donut (`fl_chart`) tương tác trực tiếp theo từng danh mục.
   - Thanh so sánh tương quan dòng tiền Thu - Chi và thặng dư tài chính.
   - Phân tích cơ cấu và tỷ lệ phần trăm chi tiêu cho từng nhóm chi (Ăn uống, Mua sắm, Di chuyển, Hóa đơn,...).
   - Thẻ đánh giá sức khỏe tài chính & gợi ý quản lý chi tiêu.

4. **Quản lý Ví tiền & Ngân sách (Wallets & Budget)**
   - Hỗ trợ nhiều loại ví: Tiền mặt, Tài khoản ngân hàng, Thẻ tín dụng, Ví điện tử (MoMo/ZaloPay), Sổ tiết kiệm.
   - Giao diện thẻ thanh toán ngân hàng trực quan với màu sắc nhận diện riêng biệt.
   - Thêm ví mới với cấu hình số dư ban đầu, loại tài khoản và bảng màu sắc tùy chỉnh.
   - Cài đặt và điều chỉnh hạn mức ngân sách chi tiêu tháng.
   - Nút khôi phục dữ liệu mẫu (Reset demo data) tiện lợi.

5. **Giao diện & Trải nghiệm (UI/UX)**
   - Hỗ trợ Dark Mode & Light Mode mượt mà thông qua `ThemeBloc` và lưu trữ cài đặt.
   - Chuẩn thiết kế Material 3 hiện đại, bo góc mềm mại, bóng đổ thanh lịch.
   - Định dạng tiền tệ chuẩn tiếng Việt (`₫`, `VNĐ`, `15.000.000 ₫`).

---

## 🏗 Kiến trúc dự án (BLoC Pattern)

```
lib/
├── bloc/
│   ├── finance_bloc.dart       # Quản lý toàn bộ logic nghiệp vụ tài chính
│   ├── finance_event.dart      # Các sự kiện (Thêm, Sửa, Xóa GD, Đổi bộ lọc, v.v.)
│   ├── finance_state.dart      # Trạng thái ứng dụng & tính toán số liệu tự động
│   └── theme_bloc.dart         # Quản lý chuyển đổi giao diện Sáng / Tối
├── models/
│   ├── category_model.dart     # Mô hình danh mục thu/chi
│   ├── transaction_model.dart  # Mô hình giao dịch
│   └── wallet_model.dart       # Mô hình ví/tài khoản
├── repositories/
│   └── finance_repository.dart # Xử lý lưu trữ dữ liệu bền vững (SharedPreferences)
├── screens/
│   ├── add_transaction_screen.dart # Form ghi chép giao dịch (Modal Bottom Sheet)
│   ├── dashboard_screen.dart       # Màn hình Tổng quan
│   ├── main_navigation_screen.dart # Khung điều hướng chính với thanh Dock Bar
│   ├── statistics_screen.dart      # Màn hình Báo cáo biểu đồ
│   ├── transactions_screen.dart    # Màn hình Sổ giao dịch & tìm kiếm
│   └── wallets_screen.dart         # Màn hình Quản lý ví & ngân sách
├── theme/
│   └── app_theme.dart          # Hệ thống bảng màu, Typography & Themes
├── utils/
│   └── currency_format.dart    # Tiện ích format tiền tệ và ngày tháng VN
└── main.dart                   # Điểm khởi chạy ứng dụng (MultiBlocProvider)
```

---

## 🚀 Hướng dẫn chạy ứng dụng

### 1. Kiểm tra môi trường
```bash
flutter doctor
```

### 2. Cài đặt các gói thư viện
```bash
flutter pub get
```

### 3. Chạy kiểm tra tĩnh và Unit Test
```bash
flutter analyze
flutter test
```

### 4. Khởi chạy trên thiết bị

- **Android (Emulator hoặc thiết bị thật):**
  ```bash
  flutter run -d android
  ```

- **iOS (Simulator hoặc iPhone/iPad trên macOS):**
  ```bash
  flutter run -d ios
  ```

- **Xem trước nhanh trên máy tính:**
  ```bash
  flutter run -d windows
  # hoặc
  flutter run -d chrome / edge
  ```
