# Sinh estimate.md và progress-report.md từ data/stats.json, data/tables.json, data/swp.csv (chạy sau gen.py)
import json, os, sys, csv
HERE=os.path.dirname(os.path.abspath(__file__)); ROOT=os.path.join(HERE,'..'); sys.path.insert(0,HERE)
from backlog import *
S=json.load(open(os.path.join(ROOT,'data','stats.json'))); TB=json.load(open(os.path.join(ROOT,'data','tables.json'),encoding='utf-8'))
NUM=TB['NUM']; HAS=TB['HAS_SWP']
SW={}; p=os.path.join(ROOT,'data','swp.csv')
if os.path.exists(p): SW={r['id']:r for r in csv.DictReader(open(p,encoding='utf-8-sig'))}
tm={t[0]:t for t in T}
SAMPLE=["T054","T012","T025","T057","T059","T001","T027","T065","T024","T067"]
def cell(i,k): return SW[i][k] if i in SW and SW[i].get(k) else '⏳'
samp="\n".join(f"| #{NUM[i]} {i} {tm[i][2][:60]} | {cell(i,'scope')} × {cell(i,'complexity')} → **{cell(i,'swp_skill')}** | **{cell(i,'swp_final')}** | {cell(i,'reason')} |" for i in SAMPLE)
html=[f for f in os.listdir(os.path.join(ROOT,'swp-report')) if f.endswith('.html')] if os.path.isdir(os.path.join(ROOT,'swp-report')) else []
hpath=f"[`swp-report/{html[0]}`](swp-report/{html[0]})" if html else "`swp-report/<file>.html` — ⏳ chưa có (chạy skill theo §0)"
# h/SWP
ratio=""
if HAS:
    rs=sorted(tm[i][5]/float(SW[i]['swp_final']) for i in SW if i in tm and SW[i].get('swp_final') and float(SW[i]['swp_final'])>0)
    med=rs[len(rs)//2]; out=[i for i in SW if i in tm and SW[i].get('swp_final') and float(SW[i]['swp_final'])>0 and not (0.5*med<=tm[i][5]/float(SW[i]['swp_final'])<=1.5*med)]
    ratio=f"Trung vị **{med:.1f} giờ/SWP**. {len(out)} issue lệch quá ±50% so với trung vị: {', '.join('#'+str(NUM[i])+' '+i for i in out) or 'không có'} — đã xem lại từng issue (ghi ở cột Lý do của data/swp.csv)."
else:
    ratio="⏳ Tính sau khi có SWP: trung vị giờ/SWP, danh sách issue lệch quá ±50% để xem lại."
est=f"""# Estimate — SWP (skill chấm) + giờ ước lượng

Báo cáo HTML của skill chấm SWP: {hpath}

## 0. Quy trình chấm

1. Script `github/setup-github-project.ps1` tạo 95 issue trên repo này (SWP để trống).
2. Chạy **skill chấm SWP của chương trình** (bộ tkm) trên 95 issue → skill xuất báo cáo HTML vào `swp-report/` và bảng điểm Scope × Complexity → SWP.
3. Người review kiểm **các issue mẫu** (§1). Sửa chỗ skill chấm sai và ghi lý do. Kết quả chốt lưu ở `data/swp.csv` (cột `swp_skill` là điểm skill chấm, `swp_final` là điểm đã chốt).
4. Agent ghi SWP đã chốt lên field **SWP** của Project bằng `github/set-swp.ps1` (đọc `data/swp.csv`). Chạy `python tools/gen.py && python tools/render_docs.py` để cập nhật file này và progress-report.md.

## 1. Issue mẫu đã kiểm skill

Mẫu chọn để phủ đủ các loại: việc nhỏ thuần logic (T054), hàm có nhiều ca (T012, T057), giao dịch đồng thời (T025), import phụ thuộc khách (T059), hạ tầng (T001), màn hình (T027), câu hỏi khách (T065), refactor mô hình dữ liệu (T024), quy tắc quản trị (T067).

| Issue | Skill chấm (Scope × Complexity → SWP) | Bạn chốt | Lý do |
|---|---|---|---|
{samp}

{"" if HAS else "> ⏳ Bảng trên được điền tự động từ `data/swp.csv` sau khi chạy skill. Issue nào giữ nguyên điểm skill thì cột Lý do ghi vì sao giữ (ví dụ: “Scope 1 file hàm + test; Complexity thấp; khớp DD-07 b3”)."}

## 2. Cách quy ra giờ

- **Cách đã chọn: ước lượng giờ trực tiếp cho từng issue** (PREMISE A5-06), sau đó đối chiếu với SWP. Không quy đổi SWP ra giờ, vì: (1) giờ được ước trước khi có skill; (2) đội chưa có dữ liệu lịch sử giờ/SWP của chính mình — quy đổi bằng một hệ số chung sẽ che mất những issue khó bất thường (T024, T059).
- **Quy tắc ước giờ**, áp dụng giống nhau cho mọi issue:
  - Giờ = giờ làm thuần của người phụ trách, gồm cả unit test của chính issue đó; chưa gồm review chéo và sửa bug sau kiểm thử tích hợp.
  - 1 ngày = 6 giờ tập trung.
  - Issue > 32 giờ thì tách sub-issue.
  - Issue loại Question chỉ tính giờ BrSE soạn câu hỏi và xử lý trả lời, không tính thời gian chờ khách.
- **Kiểm chéo giờ ↔ SWP:** {ratio}

## 3. Tổng theo epic

{TB['epic_table']}

## 4. So với estimate LAB-1

LAB-1 ước lượng theo 製造規模 (詳細設計 + 製造 + 単体テスト) của từng nhóm chức năng, đơn vị 人日 (8h).

{TB['lab1_table']}

**Vì sao LAB-5 thấp hơn LAB-1 tới 78%, và chênh này không có nghĩa LAB-1 ước lượng dư:**

1. **Phạm vi chưa break hết.** LAB-4 mới có spec chi tiết cho 15/49 màn hình và 9 hàm. Phần còn lại (34 màn hình, 10 báo cáo, migration wave 2〜3) chỉ có issue thô hoặc chưa có issue (task-breakdown §2, cột "Phần spec chưa thành issue").
2. **Định nghĩa giờ khác nhau.** Giờ LAB-5 không gồm review chéo, sửa bug sau test tích hợp, họp; LAB-1 tính các phần này trong 製造規模 qua hệ số.
3. **詳細設計 đã làm ở LAB-4.** Với EP10, thuật toán đã rõ ở DD-07 (thay đổi S-02, S-03 ở PREMISE làm rõ thêm), nên ước lượng LAB-5 không còn phần thiết kế.
4. **Có thể AI ước lượng lạc quan.** Sprint 1 thực tế vượt ước lượng 8% chỉ trên các task nhỏ; T024 vượt 50%.

**Hành động:** không dùng tổng giờ LAB-5 để báo giá lại. Sau mỗi sprint so sánh giờ thực tế/SWP với ước lượng và cộng thêm issue khi viết spec phần còn lại; đánh giá lại tổng ở Sprint 3. Ghi thành rủi ro R-5 trong progress-report.md.
"""
open(os.path.join(ROOT,'estimate.md'),'w').write(est)
# ---------- progress report
st=S['s1_status']; s1=[t for t in T if t[7]=="S1"]
def sw(ids): return (str(sum(float(SW[i]['swp_final']) for i in ids if i in SW and SW[i].get('swp_final'))) if HAS else '⏳')
def ids(k): return [t[0] for t in s1 if SIM[t[0]][0]==k]
note={"Done":"Gồm toàn bộ lõi tư cách (DD-01), lô, xác nhận 相対 (DD-02), công thức 奨励金 (12 test vector pass)",
      "In Progress":"T001 hạ tầng (~75%), T027 màn hình 相対, T030 danh sách giao dịch",
      "Todo":"T028 test đồng thời — chưa bắt đầu vì T025 xong ngày 3/11","Blocked":"T065 chờ khách trả lời Q-06/07/08/29/30"}
strows="\n".join(f"| {k} | {st[k]} | {sw(ids(k))} | {sum(t[5] for t in s1 if SIM[t[0]][0]==k)} | {note[k]} |" for k in ["Done","In Progress","Todo","Blocked"])
pr=f"""# Progress report — Sprint 1 (giả lập)

| | |
|---|---|
| Iteration trên Project | **Sprint 1** (field Iteration, 2027-03-01〜03-14) |
| Khoảng thời gian giả lập | 2027-03-01 (Thứ 2) 〜 2027-03-12 (Thứ 6), 10 ngày làm việc |
| Ngày báo cáo | 2027-03-12 |
| Ghi chú | Dữ liệu giả lập cho LAB-5. Bản tiếng Nhật gửi khách: [`reports/sprint-1-report_ja.md`](reports/sprint-1-report_ja.md) |

## 1. Trạng thái

| Trạng thái | Số issue | Tổng SWP | Giờ ước lượng | Ghi chú |
|---|---|---|---|---|
{strows}
| **Tổng** | **{S['s1_issues']}** | **{sw([t[0] for t in s1])}** | **{S['s1_hours']}** | Capacity 380h (BE×3, FE×2, QA×1: 60h/người; BrSE 20h) |

- Mức hoàn thành: **{st['Done']}/{S['s1_issues']} issue**; {S['s1_hours']-76}/{S['s1_hours']} giờ ước lượng ({(S['s1_hours']-76)/S['s1_hours']*100:.0f}%){'' if not HAS else f"; SWP {S['s1_swp_done']:g}/{S['s1_swp_total']:g} ({S['s1_swp_done']/S['s1_swp_total']*100:.0f}%)"}.
- Các issue đã xong: ước lượng {S['s1_done_hours_est']}h, thực tế {S['s1_done_hours_act']}h (**+{(S['s1_done_hours_act']/S['s1_done_hours_est']-1)*100:.0f}%**). Tổng giờ thực tế của sprint: {S['s1_actual_total']}h.

## 2. Burndown

![Burndown Sprint 1 theo giờ](reports/sprint-1-burndown-hours.png)

Burndown vẽ theo **giờ ước lượng còn lại**, vì SWP chỉ có sau khi chạy skill (bản theo SWP sẽ thêm khi có `data/swp.csv`).

Thực tế lệch kế hoạch ở đâu:
- **3/2〜3/5 chậm 60〜76 giờ so với đường kế hoạch.** Tài khoản AWS do IT phía khách cấp trễ 3 ngày (giả định A-04 của LAB-1), nên T001 không xong. Đồng thời T024 (chuyển sang mô hình bút toán, ADR-004) mất 30h so với 20h ước lượng.
- **3/8 thu hẹp còn ~39 giờ**: T024, T019, T093, T095, T010 cùng xong trong ngày. Sau đó khoảng cách **lại tăng lên 50〜76 giờ**, vì phần việc còn lại dồn vào FE và test, mà các việc này phải chờ API.
- **Cuối sprint còn 76h.** Màn hình 相対 (T027, T030) phải chờ API T026, mà T026 xong ngày cuối → FE bị dồn việc. Bài học: đưa API contract (mock) lên trước (R-4).

## 3. Rủi ro trễ

| Rủi ro | Issue | Ảnh hưởng tới mốc nào | Hành động | Ai làm, khi nào |
|---|---|---|---|---|
| R-1 Khách chưa trả lời Q-30 (nguồn 請求額) và Q-06/07/08/29 | #{NUM['T065']}, chặn #{NUM['T059']} → #{NUM['T056']}, #{NUM['T058']} | Epic 完納奨励金 trễ 1 sprint → UAT奨励金 (6/21〜) bị dồn | Hỏi lại ở họp định kỳ 3/16, hạn trả lời 3/19; nếu không có trả lời thì làm theo giả định A4-04 dưới dạng cấu hình có thể đổi | BrSE-An, 3/16〜3/19 |
| R-2 AWS cấp tài khoản trễ | #{NUM['T001']}, kéo theo #{NUM['T002']} | Có môi trường stg để test tích hợp trễ khoảng 1 tuần | Dựng trước ở tài khoản dev của đội (không dùng dữ liệu thật), chuyển sang khi khách cấp | BE-Hùng, xong 3/17 |
| R-3 Refactor ADR-004 lớn hơn ước lượng | #{NUM['T051']} (đã tăng 5→8 size, 18→28h), #{NUM['T047']}, #{NUM['T055']} | Sprint 2 có thể vượt cam kết | Ước lượng lại trước sprint planning; Sprint 2 cam kết ~70% capacity | BE-Nam, 3/15 |
| R-4 FE chờ API | #{NUM['T027']}, #{NUM['T030']}, #{NUM['T032']} | Màn hình hoàn thành cuối sprint, không kịp test | Chốt API contract + mock ở ngày 1 của sprint | Tech lead, mỗi sprint planning |
| R-5 Tổng ước lượng backlog chỉ bằng 22% LAB-1 | Toàn backlog | Nguy cơ hiểu sai năng lực → cam kết quá mức các sprint sau | Không dùng để báo giá lại; đánh giá lại ở Sprint 3 khi đủ spec | PM, Sprint 3 review |
"""
open(os.path.join(ROOT,'progress-report.md'),'w').write(pr)
print('docs ok, HAS_SWP=',HAS)
