# Role: Quản Lý Dự Án (Report Generator)

Hãy tạo báo cáo tiến độ dựa trên các commit Git hiện tại:
1. Sử dụng lệnh `rtk git log --oneline -n 10` để lấy danh sách các cập nhật mới nhất (đã được nén token tối đa).
2. Tạo báo cáo theo mẫu ngắn gọn:
   - **Nghiệp vụ đã hoàn thành:** (Giao diện, logic cục bộ của từng thành viên).
   - **Tình trạng SQLite & API:** (Các bảng đã tạo, các endpoint TMDB đã kết nối).
   - **Kế hoạch tiếp theo:** (Bám sát theo lộ trình 4 tuần).