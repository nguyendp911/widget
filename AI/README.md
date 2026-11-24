# Thiên Niên AI – triển khai 3.5

Đây là gateway chuyên ngành hỗ trợ Gemini Developer API chính thức và mô hình tương thích Chat Completions. Chưa fine-tune hay huấn luyện trọng số. Phạm vi được giới hạn bằng danh sách 9 chủ đề, schema chặt chẽ, prompt hệ thống và không có công cụ truy cập ngoài. Không nhận văn bản tự do, không cung cấp dự báo chắc chắn hoặc lá số chưa tính được.

## Gemini — lựa chọn mặc định khi có API key

Tạo API key tại https://aistudio.google.com/apikey. Python 3.10+, không cần pip. Trên PowerShell của máy chủ:

```powershell
$env:AI_PROVIDER = "gemini"
$env:GEMINI_API_KEY = "YOUR_GEMINI_API_KEY"
$env:ORACLE_ACCESS_TOKEN = (python -c "import secrets; print(secrets.token_urlsafe(32))")
$env:GEMINI_MODE = "balanced"
python AI/oracle_server.py
```

Lưu mã ORACLE_ACCESS_TOKEN ở nơi an toàn để nhập trên iPhone. Không commit khóa thật. Nếu khởi động lại và tạo token mới, mã trên iPhone cần cập nhật.

Không cần AI_MODEL khi dùng Gemini. Máy chủ gọi models.list, duyệt phân trang, lọc generateContent và loại các dòng chuyên ảnh/video/audio/live/embedding; lưu cache 5 phút. Chế độ balanced ưu tiên Flash ổn định, fast ưu tiên Flash-Lite, deep ưu tiên Pro. Xếp hạng phiên bản trong từng nhóm từ dữ liệu thực tế. Có thể giới hạn bằng GEMINI_ALLOWED_MODELS (danh sách ID phân cách dấu phẩy) để kiểm soát chi phí. Model hiển thị từ GET /oracle/models; model thực sự dùng được trả về cùng câu trả lời. Danh sách không bảo đảm model có quota hay quyền sinh nội dung. Khi gặp 404/503, thử tối đa một model khác; không lặp khi gặp 429 hoặc lỗi xác thực. Kiểm tra hạn mức và billing trước khi dùng.

Cần HTTPS reverse proxy chuyển tiếp cả /oracle và /oracle/models vào 127.0.0.1:8080. Không công khai cổng Python trực tiếp. Chỉ nhập URL máy chủ mình tin cậy. Xem tài liệu https://ai.google.dev/api/models và https://ai.google.dev/api/generate-content.

## Nhà cung cấp tương thích (tùy chọn)

Đặt AI_PROVIDER=compatible để dùng cấu hình cũ.

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
