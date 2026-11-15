# swp-report/

Thư mục chứa **báo cáo HTML do skill chấm SWP (bộ tkm của chương trình) xuất ra** — file bắt buộc của LAB-5.

Cách tạo (chạy trên máy học viên, sau khi `github/setup-github-project.ps1` đã tạo issue):

1. Mở Claude Code tại thư mục gốc repo, gọi skill chấm SWP của tkm cho 95 issue của repo `andq-2763/sakura-market-delivery` (epic và sub-issue không chấm).
2. Lưu file HTML skill xuất ra vào thư mục này.
3. Chép điểm vào `data/swp.csv` (mẫu: `data/swp-template.csv`): `scope`, `complexity`, `swp_skill` lấy từ skill; `swp_final` và `reason` do người review chốt (xem estimate.md §1).
4. `python tools/gen.py && python tools/render_docs.py` → `.\github\set-swp.ps1`.
