# Task breakdown — từ bộ thiết kế LAB-4 sang backlog

## 1. Nguyên tắc chia task

| Câu hỏi | Quy tắc áp dụng |
|---|---|
| **Độ hạt — chia tới đâu thì dừng** | Dừng khi 1 issue: (1) trỏ về **đúng 1 mục spec** (một DD, một SCR, một ADR hoặc một GAP); (2) 1 người làm xong trong **≤ 32 giờ**; (3) có acceptance criteria **kiểm tra được** (có test vector, mã lỗi hoặc thao tác cụ thể). Không đạt (1) thì tách theo mục spec; không đạt (2) thì tách sub-issue |
| **Khi nào tách sub-issue** | Issue ≥ 18 giờ **và** có các phần giao/kiểm tra độc lập (hạ tầng mạng / compute / DB; parser / ghi dữ liệu; từng wave migration). SWP chấm ở **issue cha**; sub-issue chỉ mang giờ. Có 5 issue được tách: T001, T025, T038, T059, T086 → 12 sub-issue |
| **Định nghĩa xong (DoD)** | Mọi ô acceptance criteria trong issue đã tích + code review + test tự động pass + nếu đổi spec thì đã sửa file spec và ghi version. Issue loại Question xong khi có biên bản trả lời của khách |
| **Epic → issue → sub-issue trên Project** | Epic là một issue (nhãn `type:epic`); issue là **sub-issue của epic** (tính năng sub-issue của GitHub); sub-issue là sub-issue của issue. Field Iteration, Assignee (giả định), SWP, Estimate (h), Actual (h) đặt ở issue; epic chỉ dùng để nhóm |
| **Loại issue** | Feature (làm mới theo spec), Refactor (sửa prototype theo GAP-xx), Infra, Test, Migration, Question (chờ khách — để phụ thuộc hiện trên board) |

## 2. Spec → issue

Số `#` là số issue trên repo này (script tạo theo thứ tự epic → issue → sub-issue và tự kiểm tra lại).

| Spec | Epic | Issue / sub-issue | Phần spec chưa thành issue và vì sao |
|---|---|---|---|
| ADR-010, 01_Architecture-Design.md, 03_Database-DDL.sql | #1 EP01 | #17 T001 (sub: #112, #113, #114), #18 T002, #19 T003, #20 T004, #21 T005, #109 T093, #110 T094 | Load test FIG-LOAD-01, diễn tập DR đầy đủ → thuộc giai đoạn NFR検証 (LAB-1 tính riêng), tạo issue khi vào 総合テスト |
| ADR-008, DB §3.1 | #2 EP02 | #22 T006, #23 T007, #24 T008, #25 T009, #26 T010 | SCR-003 ホーム (dashboard theo vai trò): LAB-4 chưa có spec, prototype đã có bản đơn giản → tạo issue khi spec |
| ADR-002, DD-01, SCR-021-022.md | #3 EP03 | #27 T011, #28 T012, #29 T013, #30 T014, #31 T015, #32 T016, #33 T017 | SCR-020/023 danh sách, 失効間近: chưa spec chi tiết; tạm dùng màn hình prototype |
| SM-02, ADR-012, SCR-030.md | #4 EP04 | #34 T018, #35 T019, #36 T020, #37 T021, #38 T022, #39 T023 | — |
| ADR-001, DD-02, SCR-040.md, API 5.1 | #5 EP05 | #40 T024, #41 T025 (sub: #115, #116), #42 T026, #43 T027, #44 T028, #45 T029, #46 T030, #107 T091 | — |
| ADR-001, DD-03, SCR-051-052.md | #6 EP06 | #47 T031, #48 T032, #49 T033 | SCR-050 せりセッション設定: không bắt buộc (DD-03), để Backlog sau khi khách trả lời Q-01 |
| ADR-007, DD-04, DD-09, SCR-061.md | #7 EP07 | #50 T034, #51 T035, #52 T036, #53 T037, #54 T038 (sub: #117, #118), #55 T039, #56 T040, #57 T041 | SCR-062 引渡し詳細: chưa spec → để mở (§4 G-04) |
| SM-06, DD-05, SCR-070-072.md | #8 EP08 | #58 T042, #59 T043, #60 T044, #61 T045, #62 T046 | — |
| ADR-004, DD-06, SCR-081-082.md | #9 EP09 | #63 T047, #64 T048, #65 T049, #66 T050, #67 T051 | SCR-083 承認経路設定: ngoài phạm vi theo Q-10 (duyệt 1 cấp) |
| BR-08/09, DD-07, SCR-091.md, API 5.7/5.8 | #10 EP10 | #68 T052, #69 T053, #70 T054, #71 T055, #72 T056, #73 T057, #74 T058, #75 T059 (sub: #119, #120), #76 T060, #77 T061, #78 T062, #79 T063, #80 T064, #81 T065, #108 T092 | — |
| ADR-006, DD-08, SCR-101-102.md | #11 EP11 | #82 T066, #83 T067, #84 T068, #85 T069, #86 T070 | — |
| ADR-009, Screen List (RPT/PRT) | #12 EP12 | #87 T071, #88 T072, #89 T073, #90 T074, #91 T075, #92 T076 | RPT-02〜12 mới có tên + tiêu chí trong Screen List; mỗi báo cáo cần spec cột trước khi tách issue nhỏ hơn |
| ADR-011 | #13 EP13 | #93 T077, #94 T078, #95 T079 | Mẫu nội dung mail (Q-24 chưa trả lời) |
| DB §5, BR-13 | #14 EP14 | #96 T080, #97 T081, #98 T082, #99 T083 | — |
| PREMISE LAB-4 §3 (Q-15), RFP 10-03 | #15 EP15 | #100 T084, #101 T085, #102 T086 (sub: #121, #122, #123), #103 T087 | Wave 2〜3 chưa có dữ liệu thật (Q-15, Q-16) → T086 đã có sub-issue, sẽ tách tiếp |
| QA-List, CR, AI-report LAB-4 | #16 EP16 | #104 T088, #105 T089, #106 T090, #111 T095 | UAT, đào tạo, cutover: giai đoạn sau, LAB-1 tính riêng |

## 3. Hạng mục chịu ràng buộc đặc thù — tách riêng

| Ràng buộc | Issue | Vì sao tách riêng |
|---|---|---|
| 完納奨励金 | #68 [INC-1] incentive_periods: khóa kỳ + chọn chế độ 本計算/再計算/次期差分 (DD-07 b1) | Khóa kỳ quyết định 本計算/再計算/次期差分 — sai ở đây là trả thưởng 2 lần |
| 完納奨励金 | #69 [INC-2] fn_resolve_rate theo ngày cuối kỳ (DD-07 b2 / DD-08) | Bản料率 theo ngày cuối kỳ — biến *thời điểm áp dụng* |
| 完納奨励金 | #70 [INC-3] Tính hạn thanh toán: cuối kỳ + N ngày, tính cả ngày hạn, không dời ngày nghỉ | Hạn thanh toán tính cả ngày hạn, không dời ngày nghỉ — biến *ngày* (Q-08) |
| 完納奨励金 | #71 [INC-4] Tổng 適格金額 từ trade_entries, loại 卸売業者, gồm 赤黒 (DD-07 b4) | 適格金額 gồm 赤黒, loại 卸売業者 — biến *đối tượng & số tiền* (Q-07, Q-29) |
| 完納奨励金 | #72 [INC-5] Đối chiếu 請求額 / đã trả trong hạn từ payment_lines (DD-07 b5) | Số phải trả / đã trả trong hạn — biến *nguồn dữ liệu* (Q-30) |
| 完納奨励金 | #73 [INC-6] fn_incentive_amount + 12 test vector (INC-EDGE-01〜03) | Công thức, làm tròn 1 lần, ngưỡng 以上, hệ số 110/100 — biến *công thức* (Q-06, Q-07) |
| 完納奨励金 | #74 [INC-7] Ghi 本計算/次期差分 + audit (DD-07 b7) | Ghi kết quả, 次期差分 sang kỳ sau |
| 完納奨励金 | #75 [INC-8] Import CSV công nợ/thanh toán, all-or-nothing, lỗi từng dòng (INC-01) | Import CSV all-or-nothing — phụ thuộc hệ thống kế toán (A-05) |
| 完納奨励金 | #76 [INC-9] Sửa tay dòng thanh toán có lý do (SCR-090) | Sửa tay có lý do |
| 完納奨励金 | #77 [INC-10] API INC-02/03/04 (chạy, xem, chốt kỳ) | API |
| 完納奨励金 | #78 [INC-11] SCR-091 UI: bản料率 áp dụng, lý do 0円, 次期差分 | Màn hình phải hiện lý do 0円 |
| 完納奨励金 | #79 [INC-12] RPT-07 / FORM-INC-01 xuất CSV | Báo cáo FORM-INC-01 |
| 完納奨励金 | #80 [INC-13] Test tích hợp: 赤黒 sau chốt kỳ (T9), đổi料率 giữa kỳ (T10), thiếu dữ liệu (T11) | Test tích hợp các ca biên T9/T10/T11 |
| 完納奨励金 | #81 [INC-14] Khách xác nhận Q-06/07/08/29/30 + ký test vector | Khách xác nhận 5 câu hỏi + ký test vector — chặn T059 |
| 完納奨励金 | #108 Dữ liệu test 12 vector 奨励金 + seed dùng chung BE/QA |  |
| 相対 là luồng chính, せり chỉ ghi kết quả | #5 EP05 và #6 EP06 (2 epic riêng) | Khác trạng thái đầu, khác người xác nhận (ADR-001). Gộp chung thì test sẽ bỏ sót ca "người nhập せり tự duyệt" (T033) |
| 許可 ≠ 承認 | #28 T012, #29 T013, #31 T015 | Căn cứ cố định theo loại người tham gia (BR-01); kiểm tra lúc xác nhận (BR-02) là một hàm riêng có 8 ca test |
| 赤黒 dưới 1 mã giao dịch | #40 T024, #63 T047, #67 T051 | Đổi mô hình dữ liệu ảnh hưởng 5 API đọc; tách để thấy rõ chi phí refactor (R-3) |
| 料率 tối đa 4 lần/năm | #83 T067 | Quy tắc đếm theo năm tài chính phụ thuộc Q-32; tách để đổi được mà không ảnh hưởng phần maker-checker |

Hạng mục 完納奨励金 (yêu cầu của đề): **15 issue, mỗi biến nghiệp vụ một issue** — thời điểm áp dụng料率, hạn thanh toán, đối tượng và số tiền, nguồn dữ liệu thanh toán, công thức và làm tròn, khóa kỳ và 次期差分. Khi khách trả lời Q-06/07/08/29/30 khác giả định, chỉ cần sửa đúng một issue; issue T065 (Question) chặn T059 trên board để phụ thuộc này hiện rõ.

## 4. Chỗ hở / mâu thuẫn của spec LAB-4 phát hiện khi break

| Mã | Spec | Chỗ hở / mâu thuẫn | Xử lý |
|---|---|---|---|
| S-01 | SCR-040 ↔ API Design §2 | Hai nơi mô tả hai cách chống gửi trùng khác nhau | **Đã sửa thiết kế** — PREMISE S-01 |
| S-02 | DD-07 bước 1 ↔ BR-16 | 再計算 xóa dòng 本計算, trái quy tắc không xóa cứng | **Đã sửa thiết kế** — PREMISE S-02 |
| S-03 | Screen List SCR-090 | Có ID nhưng không có spec, trong khi T059/T060 cần acceptance criteria | **Đã sửa thiết kế** (thêm spec) — PREMISE S-03 |
| G-01 | PREMISE LAB-4 §2 | Không nói refactor prototype hay viết lại | **Giả định** — PREMISE A5-01 |
| G-02 | ADR-007 / DD-09 | Chưa có screen spec SCR-160 | **Giả định** — PREMISE A5-02; viết trong #56 |
| G-03 | DD-07, SCR-090 | Nguồn của 請求額 (Q-30) chưa có trả lời → T059 chưa có định dạng file chắc chắn | **Tạo issue làm rõ** #81 (Question, chặn #75) |
| G-04 | Screen List | SCR-003 ホーム, SCR-062 引渡し詳細 chưa có spec | **Để mở**: không chặn Sprint 1〜2; tạo issue khi viết spec ở Sprint 3 |
| G-05 | Estimate LAB-1 ↔ backlog | Tổng giờ backlog chỉ bằng 22% 製造規模 của LAB-1 | **Để mở**, ghi rủi ro R-5 — xem estimate.md §5 |
