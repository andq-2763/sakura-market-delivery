# Estimate — SWP (skill chấm) + giờ ước lượng

Báo cáo HTML của skill chấm SWP: [`swp-report/sun-estimate-andq-2763-project-1-20261116.html`](swp-report/sun-estimate-andq-2763-project-1-20261116.html)

## 0. Quy trình chấm

1. Script `github/setup-github-project.ps1` tạo 95 issue trên repo này (SWP để trống).
2. Chạy **skill chấm SWP của chương trình** (bộ tkm) trên 95 issue → skill xuất báo cáo HTML vào `swp-report/` và bảng điểm Scope × Complexity → SWP.
3. Người review kiểm **các issue mẫu** (§1). Sửa chỗ skill chấm sai và ghi lý do. Kết quả chốt lưu ở `data/swp.csv` (cột `swp_skill` là điểm skill chấm, `swp_final` là điểm đã chốt).
4. Agent ghi SWP đã chốt lên field **SWP** của Project bằng `github/set-swp.ps1` (đọc `data/swp.csv`). Chạy `python tools/gen.py && python tools/render_docs.py` để cập nhật file này và progress-report.md.

## 1. Issue mẫu đã kiểm skill

Skill `tkm:sun-estimate` (Takumi Extras v1.1.0) tự chọn 5 issue mẫu theo quy tắc cố định: thấp nhất (#81 T065), dưới trung vị (#95 T079), cao nhất (#40 T024), bất thường (#19 T003), độ tin cậy thấp nhất (#104 T088). Mỗi issue duyệt 2 vòng: chọn mức khó → chọn điểm SWP cụ thể.

- Kết quả: **sửa 1/5** (T065: 1 → 3 SWP), giữ 4/5.
- Hiệu chỉnh lan truyền: skill tạo quy tắc `cal-001` (Scope +1 bậc cho nhóm documentation/routine/single-component) nhưng **không có issue nào khác cùng nhóm**, nên chỉ T065 đổi. Tổng backlog: skill 456 → chốt **458 SWP**.
- 97 issue còn lại (102 issue skill chấm trực tiếp, gồm sub-issue) giữ điểm skill; lý do từng issue (rationale của skill) ghi ở cột `reason` trong `data/swp.csv`.
- Điểm yếu của lần chấm: body issue chỉ có spec ref + DoD nên phần lớn ở mức INFERRED/medium; dòng "Ước lượng: N h" bị skill loại khỏi bằng chứng để không neo theo giờ.

| Issue | Skill chấm (Scope × Complexity → SWP) | Bạn chốt | Lý do |
|---|---|---|---|
| #81 T065 [INC-14] Khách xác nhận Q-06/07/08/29/30 + ký test vector | 2 × 1 → **1** | **3** | Skill chấm 1 SWP (coi là chủ yếu chờ khách). Sửa lên 3: phía mình vẫn phải soạn bộ câu hỏi kèm ví dụ số, giải thích quy tắc làm tròn/110/100/赤黒, ghi biên bản và sửa test vector rồi xin ký. |
| #95 T079 job_runs + SCR-170 trạng thái batch | 3 × 1 → **4** | **4** | Giữ 4: bảng job_runs + 1 màn hình chỉ đọc trạng thái batch; logic đơn giản (C1), phạm vi DB + UI (S3). |
| #40 T024 Bảng trade_entries + chuyển dữ liệu giao dịch cũ sang bút to | 5 × 3 → **10** | **10** | Giữ 10 (max của backlog): đổi mô hình giao dịch sang bút toán (ADR-004) và chuyển toàn bộ dữ liệu cũ; phải đối chiếu tổng tiền trước/sau (C3). Sprint 1 thực tế 30h/20h xác nhận đây là việc khó. |
| #19 T003 Thay client Supabase bằng `pg` + công cụ migration schema từ | 5 × 3 → **10** | **10** | Giữ 10: thay client Supabase bằng pg ở toàn app + dựng migration 29 bảng từ DDL; nhiều file, rủi ro hồi quy (S5×C3). |
| #104 T088 Gửi Q-26〜Q-33 cho khách, cập nhật PREMISE/ADR theo trả lời | 2 × 1 → **3** | **3** | Giữ 3: 8 câu hỏi Q-26〜33 + cập nhật PREMISE/ADR theo trả lời; việc tài liệu, không có code (S2×C1). |



## 2. Cách quy ra giờ

- **Cách đã chọn: ước lượng giờ trực tiếp cho từng issue** (PREMISE A5-06), sau đó đối chiếu với SWP. Không quy đổi SWP ra giờ, vì: (1) giờ được ước trước khi có skill; (2) đội chưa có dữ liệu lịch sử giờ/SWP của chính mình — quy đổi bằng một hệ số chung sẽ che mất những issue khó bất thường (T024, T059).
- **Quy tắc ước giờ**, áp dụng giống nhau cho mọi issue:
  - Giờ = giờ làm thuần của người phụ trách, gồm cả unit test của chính issue đó; chưa gồm review chéo và sửa bug sau kiểm thử tích hợp.
  - 1 ngày = 6 giờ tập trung.
  - Issue > 32 giờ thì tách sub-issue.
  - Issue loại Question chỉ tính giờ BrSE soạn câu hỏi và xử lý trả lời, không tính thời gian chờ khách.
- **Kiểm chéo giờ ↔ SWP:** Trung vị **2.7 giờ/SWP**. 11 issue lệch quá ±50% so với trung vị: #33 T017, #37 T021, #49 T033, #54 T038, #78 T062, #88 T072, #92 T076, #96 T080, #100 T084, #106 T090, #109 T093 — chưa xem lại từng issue; đưa vào danh sách kiểm lại giờ ước lượng ở sprint planning của sprint chứa issue đó (lệch thường do giờ gồm cả phần chờ/điều phối mà SWP không tính, hoặc body issue mỏng).

## 3. Tổng theo epic

| Epic | Số issue | Sub-issue | Tổng SWP | Tổng giờ | Ghi chú |
|---|---|---|---|---|---|
| #1 EP01 Nền tảng & hạ tầng production | 7 | 3 | 47 | 132 |  |
| #2 EP02 Xác thực & phân quyền | 5 | 0 | 26 | 68 |  |
| #3 EP03 Người tham gia & tư cách 許可/承認 | 7 | 0 | 25 | 69 | `constraint:qualification` |
| #4 EP04 Lô hàng (ロット) | 6 | 0 | 28 | 68 |  |
| #5 EP05 相対取引 (luồng chính) | 8 | 2 | 39 | 106 | `constraint:aitai-seri` |
| #6 EP06 せり結果 (chỉ ghi kết quả) | 3 | 0 | 13 | 32 | `constraint:aitai-seri` |
| #7 EP07 Giao hàng & offline | 8 | 2 | 38 | 126 |  |
| #8 EP08 Đối chiếu & khóa ngày | 5 | 0 | 24 | 64 |  |
| #9 EP09 Sửa sau xác nhận 赤黒 | 5 | 0 | 27 | 86 | `constraint:red-black` |
| #10 EP10 完納奨励金 (tiền thưởng thanh toán đủ hạn) — tách riêng | 15 | 2 | 59 | 140 | `constraint:incentive` |
| #11 EP11 料率版 (bản tỉ lệ — tối đa 4 lần/năm) | 5 | 0 | 20 | 48 | `constraint:rate-governance` |
| #12 EP12 Báo cáo & 会計連携 IF-ACC-01 | 6 | 0 | 29 | 100 |  |
| #13 EP13 Thông báo · batch · vận hành | 3 | 0 | 16 | 38 |  |
| #14 EP14 Audit · master · lưu trữ | 4 | 0 | 24 | 42 |  |
| #15 EP15 Migration dữ liệu | 4 | 3 | 30 | 90 |  |
| #16 EP16 Quản lý & xác nhận với khách | 4 | 0 | 13 | 31 |  |
| **Tổng** | **95** | **12** | **458** | **1240** | |

## 4. So với estimate LAB-1

LAB-1 ước lượng theo 製造規模 (詳細設計 + 製造 + 単体テスト) của từng nhóm chức năng, đơn vị 人日 (8h).

| Phần (epic ↔ chức năng LAB-1) | LAB-1 製造規模 (人日) | LAB-5 (giờ → 人日 = giờ/8) | Chênh | Vì sao |
|---|---|---|---|---|
| EP01 ↔ インフラ構築 (固定) | 25 | 16.5 | -8.5 | LAB-1 tính hạ tầng là việc cố định; LAB-5 thêm CI/CD, component UI, layout chung vào epic này |
| EP02 ↔ F01 | 50 | 8.5 | -41.5 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP03 ↔ F02 | 48.5 | 8.6 | -39.9 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP04 ↔ F03 | 61.5 | 8.5 | -53.0 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP05 ↔ F04 | 53.5 | 13.2 | -40.2 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP06 ↔ F05 | 26 | 4.0 | -22.0 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP07 ↔ F06+F16 | 78.5 | 15.8 | -62.8 | Offline (F16) đã tách đủ task; còn thiếu SCR-062 引渡し詳細 chưa có spec |
| EP08 ↔ F07 | 44 | 8.0 | -36.0 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP09 ↔ F08 | 42.5 | 10.8 | -31.8 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP10 ↔ F09 | 39 | 17.5 | -21.5 | DD-07 đã làm rõ thuật toán ở LAB-4 → phần 詳細設計 trong 製造規模 LAB-1 không còn |
| EP11 ↔ F10 | 33.5 | 6.0 | -27.5 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP12 ↔ F12+F13 | 72.5 | 12.5 | -60.0 | 10 báo cáo RPT-02〜12 mới ở mức task thô, chưa spec |
| EP13 ↔ F11+F17 | 42.5 | 4.8 | -37.8 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP14 ↔ F14+F15 | 49.5 | 5.2 | -44.2 | Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp |
| EP15 ↔ F18 | 29 | 11.2 | -17.8 | Wave 2〜3 chưa có dữ liệu khách (Q-15, Q-16) |
| EP16 ↔ — (PM/BrSE, tính ở 管理・横断) | 0 | 3.9 | +3.9 | Việc PM/BrSE — LAB-1 tính ở 管理・横断作業, không nằm trong 製造規模 |
| **Tổng** | **695.5** | **155.0** | **-540.5 (-78%)** | Xem giải thích bên dưới bảng |

**Vì sao LAB-5 thấp hơn LAB-1 tới 78%, và chênh này không có nghĩa LAB-1 ước lượng dư:**

1. **Phạm vi chưa break hết.** LAB-4 mới có spec chi tiết cho 15/49 màn hình và 9 hàm. Phần còn lại (34 màn hình, 10 báo cáo, migration wave 2〜3) chỉ có issue thô hoặc chưa có issue (task-breakdown §2, cột "Phần spec chưa thành issue").
2. **Định nghĩa giờ khác nhau.** Giờ LAB-5 không gồm review chéo, sửa bug sau test tích hợp, họp; LAB-1 tính các phần này trong 製造規模 qua hệ số.
3. **詳細設計 đã làm ở LAB-4.** Với EP10, thuật toán đã rõ ở DD-07 (thay đổi S-02, S-03 ở PREMISE làm rõ thêm), nên ước lượng LAB-5 không còn phần thiết kế.
4. **Có thể AI ước lượng lạc quan.** Sprint 1 thực tế vượt ước lượng 8% chỉ trên các task nhỏ; T024 vượt 50%.

**Hành động:** không dùng tổng giờ LAB-5 để báo giá lại. Sau mỗi sprint so sánh giờ thực tế/SWP với ước lượng và cộng thêm issue khi viết spec phần còn lại; đánh giá lại tổng ở Sprint 3. Ghi thành rủi ro R-5 trong progress-report.md.
