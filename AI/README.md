# Thiên Niên AI – triển khai 3.4

Đây là gateway chuyên ngành dùng mô hình tương thích Chat Completions. Chưa fine-tune hay huấn luyện trọng số. Phạm vi được giới hạn bằng danh sách 9 chủ đề, schema chặt chẽ, prompt hệ thống và không có công cụ truy cập ngoài. Không nhận văn bản tự do, không cung cấp dự báo chắc chắn hoặc lá số chưa tính được.

## Chạy thử
Python 3.10+; không cần pip. Cấu hình biến môi trường trên máy chủ:
- ORACLE_ACCESS_TOKEN: chuỗi ngẫu nhiên tối thiểu 32 ký tự (khác khóa nhà cung cấp)
- AI_PROVIDER_KEY: khóa mô hình, không đưa vào Git/iOS
- AI_MODEL: mã model tương thích của nhà cung cấp
- AI_CHAT_COMPLETIONS_URL: địa chỉ HTTPS đầy đủ tới Chat Completions
- PORT: mặc định 8080

Chạy python AI/oracle_server.py. Gateway chỉ lắng nghe loopback. Đặt sau reverse proxy HTTPS với giới hạn tần suất, giới hạn số kết nối, timeout, quản lý ngân sách và xác thực riêng từng người trước khi cung cấp công khai. Mã truy cập chung hiện chỉ thích hợp bản thử nghiệm cá nhân. Không ghi nội dung ngày sinh vào log proxy. Kiểm tra điều khoản lưu trữ của nhà cung cấp trước khi gửi dữ liệu cá nhân.

Trong tab Thiên mệnh > Hỏi Thiên Niên AI > Kết nối máy chủ AI: nhập URL https://<host>/oracle và mã truy cập, chọn chủ đề, đồng ý gửi ngày và dữ liệu lịch đã tính. Không cần nhập khóa API của nhà cung cấp trên iPhone.

## Artwork
Gói 24 imageset riêng được cung cấp bên ngoài repo. Giải nén và sao chép các thư mục .imageset trong Shared/Lunar/Assets.xcassets vào asset catalog cùng đường dẫn trong repo, giữ lại asset cũ. Nếu chưa cài artwork mới, ứng dụng dùng hình vector hoặc ký hiệu dự phòng.

## Kiểm thử
python -m unittest discover -s AI -p "test_*.py"
Xcode: xcodegen generate, chạy target ViePNTests trên iOS simulator. Không xem phiên bản này là đã build thành công khi chưa có kết quả CI.
