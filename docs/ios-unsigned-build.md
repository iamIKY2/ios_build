# Tạo IPA không ký từ Windows bằng Codemagic

Workflow `ios-unsigned` trong `codemagic.yaml` chạy trên máy macOS của Codemagic.
Không cần Apple Developer, chứng chỉ ký hay provisioning profile cho workflow này.

## Cách chạy

1. Đưa dự án vào kho Git riêng trên GitHub, GitLab hoặc Bitbucket. Thêm
   `codemagic.yaml`, mã nguồn Flutter, `pubspec.lock`, assets và thư mục `ios/`.
   Không đưa `.env`, khóa API bí mật, thư mục `backend/venv/`, `build/` hoặc
   thông tin ký ứng dụng lên kho mã nguồn.
2. Đăng nhập https://codemagic.io và thêm ứng dụng từ kho mã nguồn đó.
3. Chọn cấu hình bằng `codemagic.yaml` và workflow **Enigma iOS - Unsigned IPA**.
4. Chọn nhánh chứa cấu hình rồi bắt đầu build.
5. Khi thành công, tải **Enigma-unsigned.ipa** trong phần **Artifacts** của build.

Workflow được chạy thủ công, không tự build khi push. Kiểm tra hạn mức và chi phí
của tài khoản Codemagic trước khi bắt đầu.

## File được tạo

Lệnh `flutter build ios --release --no-codesign` tạo `Runner.app` cho thiết bị iOS.
Workflow đặt ứng dụng vào `Payload/Runner.app` và nén thành
`build/ios/ipa/Enigma-unsigned.ipa`. Bước cuối kiểm tra cấu trúc ZIP của file.

Đây là IPA chưa ký: không cài trực tiếp lên iPhone thông thường và không tải
thẳng lên TestFlight/App Store. Có thể giữ file để ký bằng công cụ khác sau này.
Đây cũng không phải bản chạy trên iOS Simulator.

## Môi trường build

- Flutter `3.47.5`, khớp SDK local của dự án (Dart `3.13.4`).
- Máy `mac_mini_m2`, Xcode mới nhất do Codemagic cung cấp.
- Dự án dùng CocoaPods, có sẵn `ios/Podfile` và tắt Swift Package Manager riêng
  trong `pubspec.yaml`. Workflow tự chạy `pod install --repo-update`.
- Cấu hình Firebase, Google và ký ứng dụng: xem [ios-setup.md](ios-setup.md).

Chưa có build macOS thực tế được chạy từ workspace Windows này. Nếu dịch vụ
không cung cấp phiên bản SDK đã ghim hoặc build báo lỗi plugin/Xcode, cần xem log
build để điều chỉnh; không hạ yêu cầu Dart trong `pubspec.yaml` chỉ để bỏ qua lỗi.

Tài liệu:
- https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
- https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/

## Màn hình trắng khi cài qua SideStore

Workflow GitHub Actions `.github/workflows/ios-unsigned.yml` cũng build bằng
`flutter build ios --release --no-codesign`. Hãy tải IPA từ lần chạy mới nhất
trên nhánh có bản sửa, rồi cài lại qua SideStore để kiểm tra.

App hiển thị giao diện khởi động trước khi đọc bộ nhớ thiết bị. Nếu bước bắt buộc
này lỗi hoặc quá 15 giây, app hiện thông báo và nút **Thử lại**. Đồng bộ mạng,
Firebase/push và nhắc nhở được khởi tạo sau khi giao diện app đã xuất hiện;
các dịch vụ này không còn chặn `runApp`.

Nếu cùng IPA chạy được trong LiveContainer nhưng trắng khi cài độc lập, chưa thể
kết luận là lỗi JIT hay lỗi SideStore. LiveContainer có cơ chế tương thích riêng
(Bundle ID, SDK behavior, signing). Cần kiểm tra bản cài độc lập:

- Chỉ trắng, không thấy chữ **Enigma**: lấy device console từ lúc mở app, kiểm
  tra native launch, Flutter engine và chữ ký/entitlements sau khi SideStore ký.
- Hiện **Đang khởi động…** rồi nút **Thử lại**: tìm log `[Startup] Required
  initialization failed` để kiểm tra SharedPreferences/plugin và bộ nhớ app.
- Hiện splash có logo nhưng không chuyển trang: kiểm tra xác thực, Keychain và
  kết nối API. Đây là giai đoạn sau khi khởi tạo giao diện.
- Log `[Startup]`, `[FCM]`, `[ReminderService]` giúp phân biệt lỗi dịch vụ. Push
  cần provisioning/entitlements APNs phù hợp; việc tạo IPA unsigned thành công
  không xác nhận push sẽ hoạt động sau khi ký lại.

Không cần xóa app/dữ liệu để thử bản sửa. Chưa xác minh bản cài SideStore trên
thiết bị thực từ workspace Windows này.

Tham khảo cơ chế tương thích của LiveContainer:
https://livecontainer.github.io/docs/guides/app-settings
