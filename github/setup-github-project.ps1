<#
.SYNOPSIS
  LAB-5: dựng GitHub Project thật cho repo sakura-market-delivery:
  16 epic → 95 issue (sub-issue của epic) → 12 sub-issue; Project với field Iteration (Sprint 1〜5),
  Assignee (giả định), SWP, Estimate (h), Actual (h), Epic; trạng thái Sprint 1 (giả lập).

.USAGE  (PowerShell 5.1 / 7, đứng ở thư mục gốc repo)
  gh auth login ; gh auth refresh -s project
  .\github\setup-github-project.ps1 -DryRun   # xem trước
  .\github\setup-github-project.ps1           # chạy thật (~15 phút)
  Chạy lại an toàn: item đã có (nhận theo tiền tố [EPxx]/[Txxx]/[Txxx-n]) được bỏ qua.
#>
param(
  [string]$DataFile = (Join-Path $PSScriptRoot 'issues.json'),
  [string]$Repo = '', [string]$Owner = '@me', [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
$utf8 = New-Object System.Text.UTF8Encoding $false
$data = Get-Content -Raw -Encoding UTF8 $DataFile | ConvertFrom-Json
if (-not $Repo) { $Repo = $data.repo }

$script:GhExe = (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if (-not $script:GhExe) { throw 'Chưa cài GitHub CLI: winget install GitHub.cli' }
function Invoke-Gh { param([string[]]$GhArgs, [switch]$Write)
  if ($DryRun -and $Write) { Write-Host "  [dry-run] gh $($GhArgs -join ' ')" -ForegroundColor DarkGray; return '' }
  $out = & $script:GhExe @GhArgs 2>&1
  if ($LASTEXITCODE -ne 0) { throw "gh $($GhArgs -join ' ') => $out" }
  return ($out -join "`n") }
function Invoke-GhJson { param([string[]]$GhArgs) $s = Invoke-Gh $GhArgs; if ($s) { return $s | ConvertFrom-Json } }

Write-Host "== 0. Kiểm tra repo $Repo" -ForegroundColor Cyan
Invoke-Gh @('repo','view',$Repo,'--json','name') | Out-Null
if ((& $script:GhExe auth status 2>&1) -join ' ' -notmatch 'project') { Write-Warning "Có thể thiếu scope 'project' -> gh auth refresh -s project" }

Write-Host "== 1. Labels" -ForegroundColor Cyan
$colors = @{ 'type'='0e8a16'; 'constraint'='d93f0b'; 'gap-from-prototype'='fbca04'; 'blocked'='b60205' }
$all = $data.issues | ForEach-Object { $_.labels } | Sort-Object -Unique
foreach ($l in $all) { $k = ($l -split ':')[0]; $c = if ($colors[$k]) { $colors[$k] } elseif ($colors[$l]) { $colors[$l] } else { 'cccccc' }
  if ($l -eq 'type:epic') { $c = '5319e7' }
  Invoke-Gh -Write @('label','create',$l,'--color',$c,'--force','-R',$Repo) | Out-Null }

Write-Host "== 2. Issues (epic -> issue -> sub-issue)" -ForegroundColor Cyan
$existing = @(Invoke-GhJson @('issue','list','-R',$Repo,'--state','all','--limit','1000','--json','number,title,url,state'))
$map = @{}
foreach ($e in $existing) { if ($e.title -match '^\[((EP\d{2})|(T\d{3}(-\d)?))\]') { $map[$Matches[1]] = $e } }
$tmp = [System.IO.Path]::GetTempFileName(); $fake = 9000
foreach ($i in $data.issues) {
  if ($map.ContainsKey($i.key)) { continue }
  [System.IO.File]::WriteAllText($tmp, $i.body, $utf8)
  $a = @('issue','create','-R',$Repo,'--title',$i.title,'--body-file',$tmp,'--label',($i.labels -join ','))
  if ($i.kind -ne 'epic' -and $i.iteration -eq 'Sprint 1') { $a += @('--assignee','@me') }
  $url = (Invoke-Gh -Write $a).Trim()
  if ($DryRun) { $fake++; $url = "https://github.com/$Repo/issues/$fake" }
  $num = [int]($url -split '/')[-1]
  $map[$i.key] = [pscustomobject]@{ number = $num; url = $url; state = 'OPEN' }
  $exp = $data.expected_numbers.($i.key)
  if (-not $DryRun -and $exp -and $exp -ne $num) { Write-Warning "$($i.key): số issue #$num khác số dự kiến #$exp trong tài liệu (repo không mới?)" }
  Write-Host "   $($i.key) -> #$num"
  if (-not $DryRun) { Start-Sleep -Milliseconds 700 }
}
Remove-Item $tmp -ErrorAction SilentlyContinue

Write-Host "== 3. Quan hệ sub-issue" -ForegroundColor Cyan
foreach ($i in $data.issues | Where-Object { $_.parent }) {
  $parent = $map[$i.parent]; $child = $map[$i.key]
  if ($DryRun) { Write-Host "  [dry-run] sub-issue #$($child.number) -> #$($parent.number)" -ForegroundColor DarkGray; continue }
  $childId = (Invoke-GhJson @('api',"repos/$Repo/issues/$($child.number)")).id
  try { Invoke-Gh @('api','-X','POST',"repos/$Repo/issues/$($parent.number)/sub_issues",'-F',"sub_issue_id=$childId") | Out-Null }
  catch { if ("$_" -notmatch 'already|exists|422') { throw } }
}

Write-Host "== 4. Project + fields" -ForegroundColor Cyan
$proj = (Invoke-GhJson @('project','list','--owner',$Owner,'--format','json','--limit','100')).projects | Where-Object { $_.title -eq $data.project_title } | Select-Object -First 1
if (-not $proj) {
  if ($DryRun) { Write-Host '  [dry-run] project create (dừng dry-run tại đây)'; exit 0 }
  $proj = Invoke-GhJson @('project','create','--owner',$Owner,'--title',$data.project_title,'--format','json')
}
$num = $proj.number; $projId = $proj.id
try { Invoke-Gh -Write @('project','link',"$num",'--owner',$Owner,'--repo',$Repo) | Out-Null } catch { Write-Warning "link: $_" }
$fields = (Invoke-GhJson @('project','field-list',"$num",'--owner',$Owner,'--format','json','--limit','50')).fields
$want = @(
  @{ name='SWP'; type='NUMBER' }, @{ name='Estimate (h)'; type='NUMBER' }, @{ name='Actual (h)'; type='NUMBER' },
  @{ name='Assignee (giả định)'; type='SINGLE_SELECT'; options=$data.members },
  @{ name='Epic'; type='SINGLE_SELECT'; options=$data.epics })
foreach ($w in $want) {
  if ($fields | Where-Object { $_.name -eq $w.name }) { continue }
  $a = @('project','field-create',"$num",'--owner',$Owner,'--name',$w.name,'--data-type',$w.type)
  if ($w.options) { if ($w.options | Where-Object { $_ -like '*,*' }) { throw "Option có dấu phẩy: $($w.name)" }; $a += @('--single-select-options',($w.options -join ',')) }
  Invoke-Gh -Write $a | Out-Null; Write-Host "   field: $($w.name)" }

# Iteration: gh CLI chưa hỗ trợ -> GraphQL
$q = 'query($id:ID!){ node(id:$id){ ... on ProjectV2 { field(name:"Iteration"){ ... on ProjectV2IterationField { id configuration { iterations { id title } completedIterations { id title } } } } } } }'
$it = (Invoke-GhJson @('api','graphql','-f',"query=$q",'-F',"id=$projId")).data.node.field
if (-not $it) {
  $iters = ($data.iterations | ForEach-Object { '{title:"' + $_.title + '",startDate:"' + $_.startDate + '",duration:' + $_.duration + '}' }) -join ','
  $m = 'mutation($p:ID!){ createProjectV2Field(input:{projectId:$p,dataType:ITERATION,name:"Iteration",iterationConfiguration:{startDate:"' + $data.iterations[0].startDate + '",duration:14,iterations:[' + $iters + ']}}){ projectV2Field{ ... on ProjectV2IterationField { id } } } }'
  try { Invoke-Gh @('api','graphql','-f',"query=$m",'-F',"p=$projId") | Out-Null; Write-Host '   field: Iteration (Sprint 1〜5)' }
  catch { Write-Warning "Không tạo được field Iteration qua API: $_`nTạo tay trên web: + New field > Iteration, tên 'Iteration', bắt đầu 2027-03-01, 2 tuần, 5 iteration 'Sprint 1'..'Sprint 5'; rồi chạy lại script." }
  $it = (Invoke-GhJson @('api','graphql','-f',"query=$q",'-F',"id=$projId")).data.node.field
}
$iterId = @{}; if ($it) { foreach ($x in @($it.configuration.iterations) + @($it.configuration.completedIterations)) { if ($x) { $iterId[$x.title] = $x.id } } }
$fields = (Invoke-GhJson @('project','field-list',"$num",'--owner',$Owner,'--format','json','--limit','50')).fields
function FieldId([string]$n) { ($fields | Where-Object { $_.name -eq $n }).id }
function OptId([string]$n, [string]$v) { (($fields | Where-Object { $_.name -eq $n }).options | Where-Object { $_.name -eq $v }).id }
$statusMap = @{ 'Done'='Done'; 'In Progress'='In Progress'; 'Todo'='Todo'; 'Blocked'='Todo' }

Write-Host "== 5. Gắn item + điền field" -ForegroundColor Cyan
$items = (Invoke-GhJson @('project','item-list',"$num",'--owner',$Owner,'--format','json','--limit','1000')).items
foreach ($i in $data.issues) {
  $u = $map[$i.key].url
  $item = $items | Where-Object { $_.content.url -eq $u } | Select-Object -First 1
  if (-not $item) { $item = Invoke-GhJson @('project','item-add',"$num",'--owner',$Owner,'--url',$u,'--format','json') }
  $e = New-Object System.Collections.ArrayList
  [void]$e.Add(@('--field-id',(FieldId 'Status'),'--single-select-option-id',(OptId 'Status' $statusMap[$i.status])))
  [void]$e.Add(@('--field-id',(FieldId 'Epic'),'--single-select-option-id',(OptId 'Epic' $i.epic)))
  [void]$e.Add(@('--field-id',(FieldId 'Estimate (h)'),'--number',"$($i.hours)"))
  if ($i.member) { [void]$e.Add(@('--field-id',(FieldId 'Assignee (giả định)'),'--single-select-option-id',(OptId 'Assignee (giả định)' $i.member))) }
  if ($null -ne $i.actual) { [void]$e.Add(@('--field-id',(FieldId 'Actual (h)'),'--number',"$($i.actual)")) }
  if ($null -ne $i.swp) { [void]$e.Add(@('--field-id',(FieldId 'SWP'),'--number',"$($i.swp)")) }
  if ($i.iteration -and $iterId[$i.iteration]) { [void]$e.Add(@('--field-id',$it.id,'--iteration-id',$iterId[$i.iteration])) }
  foreach ($x in $e) {
    if (-not $x[1] -or -not $x[3]) { Write-Warning "$($i.key): bỏ qua $($x -join ' ')"; continue }
    Invoke-Gh -Write (@('project','item-edit','--id',$item.id,'--project-id',$projId) + $x) | Out-Null }
  if ($i.close -and $map[$i.key].state -ne 'CLOSED') { Invoke-Gh -Write @('issue','close',$u,'-R',$Repo,'-c','Sprint 1 完了（模擬データ / LAB-5）') | Out-Null }
  Write-Host "   $($i.key) $($i.status)"
}
Write-Host "`nXong. Project: gh project view $num --owner $Owner --web" -ForegroundColor Green
Write-Host "Nhớ: Project Settings > Visibility = Public; dán link vào README.md."
