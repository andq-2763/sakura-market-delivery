# PREMISE — Backlog LAB-5 khác bản LAB-4 đã nộp ở đâu

Đầu vào là bản LAB-4 nộp ngày 2026-11-15 (`sakura-market-prototype/specs/`). Có thay đổi, chia thành 3 phần dưới đây. Các bản sửa đã được commit vào chính repo đó, nên cột "Trước → sau" trỏ thẳng tới file.

## 1. Spec thêm / bỏ / sửa so với LAB-4

| Mã | Spec (mã / file) | Thêm / Bỏ / Sửa | Trước → sau | Vì sao | Issue bị ảnh hưởng |
|---|---|---|---|---|---|
| S-01 | SCR-040 (`specs/02_System-Architecture/01_High-Level-Design/screens/SCR-040.md` v1.1) | Sửa | Trước: nút 確定 gửi `client_request_id` **trong body**. Sau: header `Idempotency-Key` | Khi viết DoD cho T026 (API) và T027 (màn hình), thấy màn hình và API Design §2 quy ước 7 mô tả hai cách khác nhau. Nếu giữ nguyên, FE và BE sẽ làm lệch nhau | T026, T027 |
| S-02 | DD-07 bước 1 (`specs/02_System-Architecture/02_Low-Level-Design/02_Detail-Design.md` v1.1) và bảng `incentive_results` (`03_Database-Design.md` v1.1, DDL) | Sửa | Trước: 再計算 thì **DELETE** dòng 本計算 cũ. Sau: đặt `superseded_at`, không xóa (thêm 1 cột) | Khi tách T052 [INC-1], đối chiếu thấy DD-07 mâu thuẫn với BR-16 của chính LAB-4 (không xóa cứng dữ liệu, audit phải truy được). Lỗi review sót ở LAB-4 | T052, T058 |
| S-03 | SCR-090 入金・請求データ取込 (`specs/…/screens/SCR-090.md`, mới) | Thêm | Trước: chỉ có ID trong Screen List. Sau: spec field, validation all-or-nothing, quyền, sự kiện | T059 / T060 (import và sửa tay thanh toán) không có chỗ để viết acceptance criteria. Đây là hạng mục 完納奨励金 mà đề yêu cầu tách rõ | T059, T060 |

Không bỏ spec nào. Các chỗ hở chưa sửa thiết kế (chỉ đặt giả định hoặc để mở) nằm ở [task-breakdown.md §4](task-breakdown.md#4-chỗ-hở--mâu-thuẫn-của-spec-lab-4-phát-hiện-khi-break).

## 2. Giả định bổ sung

Chỉ đặt giả định cho chỗ spec hoặc RFP còn để ngỏ. Không ghi đè những gì RFP đã nêu rõ.

| Mã | Giả định | Chỗ spec / RFP để ngỏ | Ảnh hưởng tới issue / estimate |
|---|---|---|---|
| A5-01 | Code production được làm bằng cách **refactor trên codebase prototype LAB-2**, không viết lại từ đầu. Dữ liệu prototype là mock nên được tạo lại bằng seed, không cần migrate | LAB-4 PREMISE chỉ nói "prototype không phải kiến trúc đích" và có danh sách GAP, nhưng không nói refactor hay viết lại | Các GAP-01〜16 thành issue loại Refactor (nhãn `gap-from-prototype`). Giờ ước lượng thấp hơn so với viết mới |
| A5-02 | Spec SCR-160 (màn hình giải quyết xung đột offline) được **viết trong chính issue T040** trước khi code | LAB-4 chỉ có DD-09, chưa có screen spec | T040 tính thêm khoảng 4h viết spec |
| A5-03 | Đội Sprint 1: BE×3, FE×2, QA×1, BrSE bán thời gian (20h). Capacity 6h tập trung/ngày × 10 ngày | Proposal LAB-1 chỉ có tổng 人月 theo tháng (tháng 3/2027 ≈ 10.9 人月) | Quyết định khối lượng cam kết Sprint 1 (337h) |
| A5-04 | Sprint 1 bắt đầu ngày 2027-03-01: sau 基本設計 G2 (2/5) và nghỉ Tết (2/5〜2/12), mỗi sprint 2 tuần | WBS LAB-1 chỉ ghi "3 インクリメント" | Ngày của các Iteration |
| A5-05 | Người phụ trách là **người giả định** (BE-Hùng, FE-Mai…), ghi vào field "Assignee (giả định)". GitHub assignee chỉ dùng tài khoản học viên | Đề cho phép "người phụ trách giả định"; không có tài khoản GitHub thật của đội | Field Project |
| A5-06 | Giờ được **ước lượng trực tiếp** cho từng issue, rồi đối chiếu với SWP (xem estimate.md §3) | Đề cho chọn ước trực tiếp hoặc quy đổi SWP ra giờ | Mọi issue |

## 3. Hướng đã chốt (chỗ LAB-4 còn để nhiều phương án)

| Vấn đề | Các phương án ở LAB-4 | Phương án chốt | Vì sao |
|---|---|---|---|
| 赤黒 lưu thế nào (ADR-004 **Proposed**, chờ Q-26) | (a) Dòng bút toán dưới cùng `trade_code`; (b) giữ cách của prototype là tạo giao dịch mới; (c) có thêm `entry_code` nếu kế toán cần số phiếu riêng | **(a)**. Nếu Q-26 trả lời cần số phiếu thì thêm (c) sau | (a) đáp ứng RFP 06-04. (c) chỉ là thêm 1 cột, không làm đổi các issue T024, T047, T051 |
| Vai trò người duyệt (ADR-008 **Proposed**, CR-05) | 7 vai trò như RFP, hoặc thêm ROLE-APPROVER | **8 vai trò** (có ROLE-APPROVER) | Prototype đã chạy với 8 vai trò; Q-10 giả định duyệt 1 cấp. T009 làm theo hướng này |
| Nền tảng production (ADR-010) | AWS Tokyo, hoặc dự phòng Supabase Tokyo (gói trả phí) | **AWS Tokyo** | Cam kết マルチAZ / RTO 4h / DR sang vùng khác trong proposal. Epic EP01 ước lượng theo AWS |
