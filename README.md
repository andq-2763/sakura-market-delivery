# 桜水産市場 業務支援システム — Delivery (LAB-5)

| | |
|---|---|
| Dự án | 株式会社 桜水産市場 業務支援システム (dự án mô phỏng của khóa học) |
| Học viên | Dang Quynh An · Mã học viên: `B122763` |
| Đề | **Product A** — sàn đấu giá thủy sản |

## 1. Tổng quan

- Backlog được break từ **bộ thiết kế LAB-4 bản nộp ngày 2026-11-15**, thư mục [`specs/`](https://github.com/andq-2763/sakura-market-prototype/tree/main/specs) trong repo prototype.
- **PREMISE.md có thay đổi** so với LAB-4: 3 sửa/thêm spec, 6 giả định, 3 hướng đã chốt. Xem [PREMISE.md](PREMISE.md).
- **16 epic → 95 issue → 12 sub-issue** (123 item trên Project). Hạng mục 完納奨励金 tách thành epic riêng (#10) với 15 issue.
- Đã chạy giả lập **Iteration "Sprint 1" (2027-03-01〜03-14)**. Sprint 2〜5 mới xếp dự kiến.
- Point trên Project là **SWP do skill chấm, đã review** ([estimate.md](estimate.md)). Giờ ước lượng được ghi riêng cho từng issue.

## 2. Liên kết

| | |
|---|---|
| Repo | https://github.com/andq-2763/sakura-market-delivery |
| GitHub Project | https://github.com/users/andq-2763/projects/1 |
| Báo cáo HTML của skill chấm SWP | [`swp-report/`](swp-report/) |
| Bộ thiết kế LAB-4 (đầu vào) | https://github.com/andq-2763/sakura-market-prototype/tree/main/specs |

- [ ] Đã mở thử repo và Project bằng **cửa sổ ẩn danh** (không đăng nhập): xem được cả hai.

## 3. Cấu trúc repo

| File/thư mục | Nội dung |
|---|---|
| `README.md` | File này |
| `PREMISE.md` | Tiền đề: backlog khác bản LAB-4 ở đâu (spec thêm/sửa, giả định, hướng đã chốt) |
| `task-breakdown.md` | Nguyên tắc chia task, bảng spec → issue, hạng mục ràng buộc đặc thù, chỗ hở của spec |
| `estimate.md` | Chấm SWP bằng skill + phần đã sửa, cách quy ra giờ, tổng theo epic, so với LAB-1 |
| `progress-report.md` | Báo cáo tiến độ Sprint 1 (trạng thái, burndown, rủi ro trễ) |
| `AI-report.md` | Cách dùng AI, review, điểm mạnh/yếu |
| `swp-report/` | Báo cáo HTML do skill chấm SWP xuất ra |
| `reports/` | Burndown (PNG), bản báo cáo gửi khách tiếng Nhật |
| `data/` | `backlog.csv` (toàn bộ item), `swp.csv` (SWP đã chốt), `stats.json` (số liệu dùng trong báo cáo) |
| `tools/` | `backlog.py` (nguồn duy nhất của backlog), `gen.py` (sinh issues.json, csv, số liệu) |
| `github/` | `setup-github-project.ps1` (dựng Project), `set-swp.ps1` (ghi SWP lên Project), `issues.json` |

## 4. Spec → Epic

| Spec (file / mục LAB-4) | Epic trên Project | Ghi chú |
|---|---|---|
| ADR-010, 01_Architecture-Design.md, 03_Database-DDL.sql | #1 — EP01 Nền tảng & hạ tầng production |  |
| ADR-008, DB §3.1 | #2 — EP02 Xác thực & phân quyền |  |
| ADR-002, DD-01, SCR-021-022.md | #3 — EP03 Người tham gia & tư cách 許可/承認 | Ràng buộc đặc thù: `constraint:qualification` |
| SM-02, ADR-012, SCR-030.md | #4 — EP04 Lô hàng (ロット) |  |
| ADR-001, DD-02, SCR-040.md, API 5.1 | #5 — EP05 相対取引 (luồng chính) | Ràng buộc đặc thù: `constraint:aitai-seri` |
| ADR-001, DD-03, SCR-051-052.md | #6 — EP06 せり結果 (chỉ ghi kết quả) | Ràng buộc đặc thù: `constraint:aitai-seri` |
| ADR-007, DD-04, DD-09, SCR-061.md | #7 — EP07 Giao hàng & offline |  |
| SM-06, DD-05, SCR-070-072.md | #8 — EP08 Đối chiếu & khóa ngày |  |
| ADR-004, DD-06, SCR-081-082.md | #9 — EP09 Sửa sau xác nhận 赤黒 | Ràng buộc đặc thù: `constraint:red-black` |
| BR-08/09, DD-07, SCR-091.md, API 5.7/5.8 | #10 — EP10 完納奨励金 (tiền thưởng thanh toán đủ hạn) — tách riêng | Ràng buộc đặc thù: `constraint:incentive` |
| ADR-006, DD-08, SCR-101-102.md | #11 — EP11 料率版 (bản tỉ lệ — tối đa 4 lần/năm) | Ràng buộc đặc thù: `constraint:rate-governance` |
| ADR-009, Screen List (RPT/PRT) | #12 — EP12 Báo cáo & 会計連携 IF-ACC-01 |  |
| ADR-011 | #13 — EP13 Thông báo · batch · vận hành |  |
| DB §5, BR-13 | #14 — EP14 Audit · master · lưu trữ |  |
| PREMISE LAB-4 §3 (Q-15), RFP 10-03 | #15 — EP15 Migration dữ liệu |  |
| QA-List, CR, AI-report LAB-4 | #16 — EP16 Quản lý & xác nhận với khách |  |
