# Sinh toàn bộ phần số liệu của repo LAB-5 từ backlog.py (+ data/swp.csv nếu đã chấm SWP bằng skill)
import csv, json, os, sys, collections
HERE=os.path.dirname(os.path.abspath(__file__)); ROOT=os.path.join(HERE,'..'); sys.path.insert(0,HERE)
from backlog import *
REPO="andq-2763/sakura-market-delivery"; SPEC_REPO="https://github.com/andq-2763/sakura-market-prototype/blob/main/specs/"
ITER={"S1":("Sprint 1","2027-03-01"),"S2":("Sprint 2","2027-03-15"),"S3":("Sprint 3","2027-03-29"),"S4":("Sprint 4","2027-04-12"),"S5":("Sprint 5","2027-04-26"),"Backlog":(None,None)}
# ---- SWP từ skill (nếu có)
SWP={}; p=os.path.join(ROOT,'data','swp.csv')
if os.path.exists(p):
    for r in csv.DictReader(open(p,encoding='utf-8-sig')):
        if r.get('swp_final'): SWP[r['id']]=r
HAS=bool(SWP)
def swp(i): return float(SWP[i]['swp_final']) if i in SWP else None
def fmt(x): return ('—' if x is None else (str(int(x)) if float(x).is_integer() else f"{x:.1f}"))
# ---- số issue dự kiến (repo mới, script tạo theo thứ tự: epic → issue → sub-issue)
NUM={}; n=0
for k in EPICS: n+=1; NUM[k]=n
for t in T: n+=1; NUM[t[0]]=n
for pid in SUBS:
    for s in SUBS[pid]: n+=1; NUM[s[0]]=n
def st(t): return SIM[t[0]][0] if t[7]=="S1" else "Todo"
def labels(t):
    L=[f"type:{t[3].lower()}"]; c=EPICS[t[1]][2]
    if c: L.append(c)
    if t[0] in ("T024","T051"): L.append("constraint:red-black")
    if t[3]=="Refactor": L.append("gap-from-prototype")
    if st(t)=="Blocked": L.append("blocked")
    return L
# ---- issues.json
iss=[]
for k,v in EPICS.items():
    body=f"## Epic {k}: {v[0]}\n\n**Spec LAB-4:** {EPIC_SPEC[k]} — {SPEC_REPO}\n\n**Căn cứ:** {v[1]}\n\nCác issue con là sub-issue của epic này."
    iss.append({"key":k,"kind":"epic","title":f"[{k}] {v[0]}","body":body,"labels":["type:epic"]+([v[2]] if v[2] else []),"parent":None,
                "iteration":None,"member":None,"hours":sum(t[5] for t in T if t[1]==k),"actual":None,"status":"Todo","epic":f"{k} {v[0]}","close":False})
for t in T:
    ac=[x for x in t[9] if x]
    body=(f"**Epic:** #{NUM[t[1]]} {t[1]} {EPICS[t[1]][0]}\n\n**Spec LAB-4:** {t[8]}\n\n**Người phụ trách (giả định):** {t[6]} · **Ước lượng:** {t[5]}h · **Iteration:** {ITER[t[7]][0] or 'chưa xếp'}\n\n"
          +(f"**Phụ thuộc:** {', '.join(f'#{NUM[d]} ({d})' for d in t[10].split(','))}\n\n" if t[10] else "")
          +("**Định nghĩa xong (DoD):**\n"+"\n".join(f"- [ ] {x}" for x in ac)+"\n- [ ] Code review + test tự động pass\n" if ac else "")
          +"\n_SWP: chấm bằng skill, xem estimate.md_")
    iss.append({"key":t[0],"kind":"issue","title":f"[{t[0]}] {t[2]}","body":body,"labels":labels(t),"parent":t[1],"iteration":ITER[t[7]][0],
                "member":t[6],"hours":t[5],"actual":SIM[t[0]][2] if t[7]=="S1" else None,"status":st(t),"epic":f"{t[1]} {EPICS[t[1]][0]}",
                "close":st(t)=="Done","swp":swp(t[0])})
tm={t[0]:t for t in T}
for pid,subs in SUBS.items():
    t=tm[pid]
    for sid,title,h,s in subs:
        s_=s if t[7]=="S1" else "Todo"
        iss.append({"key":sid,"kind":"sub","title":f"[{sid}] {title}","body":f"Sub-issue của #{NUM[pid]} ({pid}). Ước lượng {h}h. SWP tính ở issue cha.",
                    "labels":["type:sub-task"],"parent":pid,"iteration":ITER[t[7]][0],"member":t[6],"hours":h,"actual":None,"status":s_,
                    "epic":f"{t[1]} {EPICS[t[1]][0]}","close":s_=="Done"})
json.dump({"assignee_field":"Assignee (giả định)","repo":REPO,"project_title":"桜水産市場 業務支援システム — Delivery (LAB-5)",
  "iterations":[{"title":v[0],"startDate":v[1],"duration":14} for k,v in ITER.items() if v[0]],
  "members":sorted({t[6] for t in T}),"epics":[f"{k} {v[0]}" for k,v in EPICS.items()],"expected_numbers":NUM,"issues":iss},
  open(os.path.join(ROOT,'github','issues.json'),'w',encoding='utf-8'),ensure_ascii=False,indent=1)
# ---- CSV
with open(os.path.join(ROOT,'data','backlog.csv'),'w',newline='',encoding='utf-8-sig') as f:
    w=csv.writer(f); w.writerow(["#","ID","Loại","Epic","Tiêu đề","Iteration","Người phụ trách (giả định)","Giờ ước lượng","Giờ thực tế","SWP","Trạng thái","Spec LAB-4","Phụ thuộc"])
    for i in iss:
        w.writerow([NUM[i['key']],i['key'],i['kind'],i['epic'],i['title'],i['iteration'] or '',i['member'] or '',i['hours'],i['actual'] if i['actual'] is not None else '',
                    fmt(i.get('swp')) if i['kind']=='issue' else '',i['status'],'' if i['kind']!='issue' else tm[i['key']][8],'' if i['kind']!='issue' else tm[i['key']][10]])
# ---- số liệu dùng trong các file md (ghi ra JSON để kiểm tra chéo)
s1=[t for t in T if t[7]=="S1"]
stats={"issues":len(T),"epics":len(EPICS),"subs":sum(len(v) for v in SUBS.values()),"hours":sum(t[5] for t in T),
 "s1_issues":len(s1),"s1_hours":sum(t[5] for t in s1),"s1_done_hours_est":sum(t[5] for t in s1 if SIM[t[0]][0]=="Done"),
 "s1_done_hours_act":sum(SIM[t[0]][2] for t in s1 if SIM[t[0]][0]=="Done"),"s1_actual_total":sum(SIM[t[0]][2] for t in s1),
 "s1_status":{k:sum(1 for t in s1 if SIM[t[0]][0]==k) for k in ["Done","In Progress","Todo","Blocked"]},
 "s1_swp_total":sum(swp(t[0]) or 0 for t in s1) if HAS else None,"s1_swp_done":sum(swp(t[0]) or 0 for t in s1 if SIM[t[0]][0]=="Done") if HAS else None}
json.dump(stats,open(os.path.join(ROOT,'data','stats.json'),'w'),indent=1)
# ---- bảng markdown dùng chung
def epic_table():
    L=["| Epic | Số issue | Sub-issue | Tổng SWP | Tổng giờ | Ghi chú |","|---|---|---|---|---|---|"]
    for k,v in EPICS.items():
        ts=[t for t in T if t[1]==k]; sw=sum(swp(t[0]) or 0 for t in ts) if HAS else None
        sub=sum(len(SUBS.get(t[0],[])) for t in ts)
        L.append(f"| #{NUM[k]} {k} {v[0]} | {len(ts)} | {sub} | {fmt(sw) if HAS else '⏳'} | {sum(t[5] for t in ts)} | {('`'+v[2]+'`') if v[2] else ''} |")
    L.append(f"| **Tổng** | **{len(T)}** | **{stats['subs']}** | **{fmt(sum(swp(t[0]) or 0 for t in T)) if HAS else '⏳'}** | **{stats['hours']}** | |")
    return "\n".join(L)
def lab1_table():
    L=["| Phần (epic ↔ chức năng LAB-1) | LAB-1 製造規模 (人日) | LAB-5 (giờ → 人日 = giờ/8) | Chênh | Vì sao |","|---|---|---|---|---|"]
    why={"EP01":"LAB-1 tính hạ tầng là việc cố định; LAB-5 thêm CI/CD, component UI, layout chung vào epic này",
         "EP07":"Offline (F16) đã tách đủ task; còn thiếu SCR-062 引渡し詳細 chưa có spec","EP10":"DD-07 đã làm rõ thuật toán ở LAB-4 → phần 詳細設計 trong 製造規模 LAB-1 không còn",
         "EP12":"10 báo cáo RPT-02〜12 mới ở mức task thô, chưa spec","EP15":"Wave 2〜3 chưa có dữ liệu khách (Q-15, Q-16)","EP16":"Việc PM/BrSE — LAB-1 tính ở 管理・横断作業, không nằm trong 製造規模"}
    a=b=0
    for k,(f,d) in LAB1.items():
        h=sum(t[5] for t in T if t[1]==k)/8; a+=d; b+=h
        L.append(f"| {k} ↔ {f} | {d:g} | {h:.1f} | {h-d:+.1f} | {why.get(k,'Chỉ chi tiết phần có spec LAB-4; chưa gồm review, sửa bug, kiểm thử tích hợp')} |")
    L.append(f"| **Tổng** | **{a:g}** | **{b:.1f}** | **{b-a:+.1f} ({(b-a)/a*100:+.0f}%)** | Xem giải thích bên dưới bảng |")
    return "\n".join(L)
json.dump({"epic_table":epic_table(),"lab1_table":lab1_table(),"NUM":NUM,"HAS_SWP":HAS},open(os.path.join(ROOT,'data','tables.json'),'w',encoding='utf-8'),ensure_ascii=False,indent=1)
print(json.dumps(stats,ensure_ascii=False)); print('HAS_SWP',HAS)
