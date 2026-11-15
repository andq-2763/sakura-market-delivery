# AI-report — LAB-5

AI dùng: Claude (Cowork, Claude Opus 5.5), cùng phiên đã làm LAB-4, nên AI đã đọc bộ specs, RFP và workbook LAB-1. Skill chấm SWP của chương trình (bộ tkm) chạy trên máy học viên.

## 1. Skill và prompt cho từng việc

| Việc | Skill / công cụ | Prompt hoặc cách điều khiển |
|---|---|---|
| **Break task** | Claude + script Python (`tools/backlog.py` là nguồn duy nhất) | "Từ `specs/` LAB-4, đi theo bảng traceability và GAP-01〜16. Mỗi issue trỏ đúng 1 mục spec, ≤ 32 giờ, có acceptance criteria kiểm tra được. Hạng mục 完納奨励金 tách theo 7 bước của DD-07, mỗi biến nghiệp vụ một issue. Việc chờ khách là issue loại Question." Sau đó dán **đề LAB-5 (ảnh)** để AI đối chiếu đủ 8 mục phải nộp |
| **Chấm SWP** | **Skill chấm SWP của tkm** (Scope × Complexity → SWP, xuất HTML vào `swp-report/`) | Chạy skill trên 95 issue (bỏ epic và sub-issue). Người review chọn 10 issue mẫu phủ các loại (estimate.md §1), so điểm skill với hiểu biết về spec, sửa và ghi lý do vào `data/swp.csv` |
| **Agent ghi SWP lên Project** | `github/set-swp.ps1` (do AI viết, người chạy) | Script đọc `swp_final` đã chốt và ghi vào field SWP của từng item. Chỉ ghi giá trị đã có người duyệt; giá trị skill chấm thô không bao giờ được đẩy thẳng lên Project |
| **Quy ra giờ** | Claude | "Ước giờ trực tiếp theo vai trò; 1 ngày = 6h tập trung; issue > 32h thì tách sub-issue; sau đó so tỉ lệ giờ/SWP, issue nào lệch quá ±50% trung vị thì liệt kê để xem lại" (estimate.md §2) |
| **Dựng Project** | Claude viết `github/setup-github-project.ps1` (gh CLI + REST sub-issue + GraphQL Iteration) | Môi trường cloud của AI bị chặn GraphQL và chưa liên kết GitHub, nên script chạy trên máy học viên. AI đã chạy thử script bằng PowerShell 7 với một bản `gh` giả lập ghi log mọi lệnh |
| **Báo cáo tiến độ** | Claude + script (`tools/render_docs.py`) | "Giả lập kết quả từng issue (ngày xong, giờ thực tế) dựa trên rủi ro có thật trong tài liệu (Q-30, A-04, ADR-004). Mọi con số trong báo cáo phải được **tính** từ dữ liệu, không viết tay" |

## 2. Review output của AI

### Con người review ở đâu

| Bước | Người làm gì |
|---|---|
| Trước khi bắt đầu | Chọn repo riêng (không ghi đè README LAB-2), chỉ ra skill SWP nằm trong tkm |
| Sau khi AI break task lần 1 | Gửi phần **"Kết quả thực hành" của đề**. AI phát hiện bản đầu (thư mục `lab5/` trong repo prototype) thiếu: file ở gốc repo, PREMISE, task-breakdown, estimate, Iteration, sub-issue, point là SWP. Làm lại toàn bộ cấu trúc |
| Chấm SWP | Kiểm 10 issue mẫu; sửa điểm skill chỗ chưa đúng (estimate.md §1) |
| Trước khi nộp | Mở repo và Project bằng cửa sổ ẩn danh; đọc lại giọng văn báo cáo gửi khách |

### Vấn đề phát hiện trong output của AI và cách xử lý

| # | Vấn đề | Phát hiện bằng | Xử lý |
|---|---|---|---|
| 1 | Bản đầu không theo cấu trúc nộp bài của đề: dùng Story Point do AI tự đặt thay vì SWP của skill, không có Iteration hay sub-issue | Người gửi đề chi tiết | Làm lại: repo riêng, 6 file ở gốc, Iteration, sub-issue, field SWP |
| 2 | Sprint 1 ban đầu đặt tháng 11/2026, trái WBS LAB-1 (khi đó mới là 要件定義) | AI đối chiếu WBS | Dời sang 2027-03 (PREMISE A5-04) |
| 3 | Cân tải: 2 BE bị giao 104h và 114h trên capacity 60h | Script cộng giờ theo người | Thêm BE thứ 3 theo quy mô đội của proposal, dời 6 issue |
| 4 | Script PowerShell: hàm `Gh` trùng tên `gh` → đệ quy vô hạn; biến `$pid` là biến hệ thống chỉ đọc; tên epic có dấu phẩy làm hỏng option; mảng lồng nhau làm mất field Status của 123 item; `-like "[T054]*"` bị hiểu dấu `[ ]` là ký tự đại diện | Chạy thử với `gh` giả lập (đếm số lệnh mong đợi: 123 issue, 107 quan hệ sub-issue, 607 lần sửa field, 27 issue đóng; chạy lại thì 0 tạo mới) | Sửa cả 5 lỗi |
| 5 | **Spec LAB-4 mâu thuẫn**: SCR-040 khác API về cách chống gửi trùng; DD-07 xóa dòng trái BR-16; SCR-090 không có spec | Khi viết acceptance criteria cho từng issue | Sửa spec LAB-4 (PREMISE S-01〜S-03) |
| 6 | Tổng giờ backlog chỉ bằng 22% LAB-1. AI không tự nêu cho đến khi lập bảng so sánh | Bảng estimate.md §4 | Giải thích nguyên nhân, ghi rủi ro R-5, không dùng để báo giá lại |
| 7 | Câu giải thích burndown do AI viết ban đầu nói "3/8〜3/11 bắt kịp nhanh", nhưng số liệu cho thấy khoảng cách lại tăng | Đối chiếu từng ngày với đường kế hoạch | Viết lại theo số liệu |
| 8 | Báo cáo tiếng Nhật dùng SP, lệch với repo dùng SWP/giờ; một ô tổng giờ của 相対取引 sai (ghi 106, đúng là 100) | Cộng lại từng nhóm, phải khớp 337 / 261 | Chuyển báo cáo sang giờ, sửa ô sai |

## 3. Điểm đặc biệt trong cách dùng AI

**Hiệu quả:**
- **Một nguồn dữ liệu, mọi thứ còn lại được sinh ra.** `tools/backlog.py` sinh issue trên GitHub, CSV, bảng trong estimate.md và progress-report.md, burndown. Nhờ vậy sửa một issue thì các báo cáo không lệch nhau, và người review chỉ cần kiểm một chỗ.
- **Kiểm tra bằng máy trước khi tin.** Script dựng Project được chạy thử với bản `gh` giả lập, bắt được 5 lỗi mà nếu không thì học viên sẽ gặp khi chạy thật. Mọi con số trong báo cáo đều được cộng lại cho khớp tổng.
- **Break task là một lần review spec.** Viết acceptance criteria cho từng issue làm lộ 3 chỗ sai của chính bộ spec LAB-4 mà review LAB-4 đã bỏ sót.

**Chưa tốt, cần cải thiện khi làm thật:**
- Board chưa được dựng thật trong phiên AI (môi trường cloud bị chặn GraphQL). Lần chạy trên máy học viên là lần kiểm tra thật đầu tiên.
- Giờ do AI ước lượng, có dấu hiệu lạc quan (Sprint 1 vượt 8%, T024 vượt 50%). Khi làm thật cần planning poker với đội, và hiệu chỉnh tỉ lệ giờ/SWP sau mỗi sprint.
- Kết quả Sprint 1 là giả lập: các "sự cố" do AI chọn từ rủi ro có thật trong tài liệu, không phải dữ liệu đo được.
- Đầu ra của skill SWP chưa có khi viết bản này. estimate.md §1 và cột SWP sẽ được điền sau khi chạy skill. Nếu giờ/SWP lệch nhiều, phải xem lại cả ước lượng giờ chứ không chỉ sửa SWP.
