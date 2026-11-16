<#
.SYNOPSIS
  LAB-5: dung GitHub Project that cho repo sakura-market-delivery:
  16 epic -> 95 issue (sub-issue cua epic) -> 12 sub-issue; Project voi field Iteration (Sprint 1-5),
  Assignee (gia dinh), SWP, Estimate (h), Actual (h), Epic; trang thai Sprint 1 (gia lap).

.USAGE  (PowerShell 5.1 / 7, dung o thu muc goc repo)
  gh auth login ; gh auth refresh -s project
  .\github\setup-github-project.ps1 -DryRun   # xem truoc
  .\github\setup-github-project.ps1           # chay that (~15 phut)
  Chay lai an toan: item da co (nhan theo tien to [EPxx]/[Txxx]/[Txxx-n]) duoc bo qua.
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
$AssigneeField = $data.assignee_field
if (-not $Repo) { $Repo = $data.repo }

$script:GhExe = (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if (-not $script:GhExe) { throw 'Chua cai GitHub CLI: winget install GitHub.cli' }
function Invoke-Gh { param([string[]]$GhArgs, [switch]$Write)
  if ($DryRun -and $Write) { Write-Host "  [dry-run] gh $($GhArgs -join ' ')" -ForegroundColor DarkGray; return '' }
  $out = & $script:GhExe @GhArgs 2>&1
  if ($LASTEXITCODE -ne 0) { throw "gh $($GhArgs -join ' ') => $out" }
  return ($out -join "`n") }
function Invoke-GhJson { param([string[]]$GhArgs) $s = Invoke-Gh $GhArgs; if ($s) { return $s | ConvertFrom-Json } }

Write-Host "== 0. Kiem tra repo $Repo" -ForegroundColor Cyan
Invoke-Gh @('repo','view',$Repo,'--json','name') | Out-Null
if ((& $script:GhExe auth status 2>&1) -join ' ' -notmatch 'project') { Write-Warning "Co the thieu scope 'project' -> gh auth refresh -s project" }

Write-Host "== 1. Labels" -ForegroundColor Cyan
$colors = @{ 'type'='0e8a16'; 'constraint'='d93f0b'; 'gap-from-prototype'='fbca04'; 'blocked'='b60205' }
$all = $data.issues | ForEach-Object { $_.labels } | Sort-Object -Unique
foreach ($l in $all) { $k = ($l -split ':')[0]; $c = if ($colors[$k]) { $colors[$k] } elseif ($colors[$l]) { $colors[$l] } else { 'cccccc' }
  if ($l -eq 'type:epic') { $c = '5319e7' }
  Invoke-Gh -Write @('label','create',$l,'--color',$c,'--force','-R',$Repo) | Out-Null }

Write-Host "== 2. Issues (epic -> issue -> sub-issue)" -ForegroundColor Cyan
# PowerShell 5.1: ConvertFrom-Json tra ve ca mang nhu 1 object -> phai trai phang bang ForEach-Object
$existing = @((Invoke-GhJson @('issue','list','-R',$Repo,'--state','all','--limit','1000','--json','number,title,url,state')) | ForEach-Object { $_ })
$map = @{}
foreach ($e in $existing) { if ([string]$e.title -match '^\[((EP\d{2})|(T\d{3}(-\d)?))\]') { $map[$Matches[1]] = $e } }
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
  if (-not $DryRun -and $exp -and $exp -ne $num) { Write-Warning "$($i.key): so issue #$num khac so du kien #$exp trong tai lieu (repo khong moi?)" }
  Write-Host "   $($i.key) -> #$num"
  if (-not $DryRun) { Start-Sleep -Milliseconds 700 }
}
Remove-Item $tmp -ErrorAction SilentlyContinue

Write-Host "== 3. Quan he sub-issue" -ForegroundColor Cyan
foreach ($i in $data.issues | Where-Object { $_.parent }) {
  $parent = $map[$i.parent]; $child = $map[$i.key]
  if ($DryRun) { Write-Host "  [dry-run] sub-issue #$($child.number) -> #$($parent.number)" -ForegroundColor DarkGray; continue }
  $childId = (Invoke-GhJson @('api',"repos/$Repo/issues/$($child.number)")).id
  try { Invoke-Gh @('api','-X','POST',"repos/$Repo/issues/$($parent.number)/sub_issues",'-F',"sub_issue_id=$childId") | Out-Null; Write-Host "   #$($child.number) -> #$($parent.number)" }
  catch { if ("$_" -notmatch 'already|exists|422') { throw }; Write-Host "   #$($child.number) -> #$($parent.number) (da co)" }
}

Write-Host "== 4. Project + fields" -ForegroundColor Cyan
$proj = (Invoke-GhJson @('project','list','--owner',$Owner,'--format','json','--limit','100')).projects | Where-Object { $_.title -eq $data.project_title } | Select-Object -First 1
if (-not $proj) {
  if ($DryRun) { Write-Host '  [dry-run] project create (dung dry-run tai day)'; exit 0 }
  $proj = Invoke-GhJson @('project','create','--owner',$Owner,'--title',$data.project_title,'--format','json')
}
$num = $proj.number; $projId = $proj.id
$login = if ($Owner -eq '@me') { (Invoke-Gh @('api','user','--jq','.login')).Trim() } else { $Owner }
try { Invoke-Gh -Write @('project','link',"$num",'--owner',$login,'--repo',$Repo) | Out-Null } catch { Write-Warning "link: $_" }
$fields = (Invoke-GhJson @('project','field-list',"$num",'--owner',$Owner,'--format','json','--limit','50')).fields
$want = @(
  @{ name='SWP'; type='NUMBER' }, @{ name='Estimate (h)'; type='NUMBER' }, @{ name='Actual (h)'; type='NUMBER' },
  @{ name=$AssigneeField; type='SINGLE_SELECT'; options=$data.members },
  @{ name='Epic'; type='SINGLE_SELECT'; options=$data.epics })
foreach ($w in $want) {
  if ($fields | Where-Object { $_.name -eq $w.name }) { continue }
  $a = @('project','field-create',"$num",'--owner',$Owner,'--name',$w.name,'--data-type',$w.type)
  if ($w.options) { if ($w.options | Where-Object { $_ -like '*,*' }) { throw "Option co dau phay: $($w.name)" }; $a += @('--single-select-options',($w.options -join ',')) }
  Invoke-Gh -Write $a | Out-Null; Write-Host "   field: $($w.name)" }

# Iteration: gh CLI chua ho tro -> GraphQL. Gui body bang file (--input) vi PowerShell 5.1 lam mat dau " trong tham so.
function Invoke-Gql([string]$query, [hashtable]$vars) {
  $f = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($f, (@{ query = $query; variables = $vars } | ConvertTo-Json -Depth 10 -Compress), $utf8)
  try { return (Invoke-GhJson @('api','graphql','--input',$f)) } finally { Remove-Item $f -ErrorAction SilentlyContinue }
}
# Khong dung field(name:) vi GitHub bao loi khi field chua ton tai -> lay danh sach field roi loc
$q = 'query($id:ID!){ node(id:$id){ ... on ProjectV2 { fields(first:50){ nodes { ... on ProjectV2IterationField { id name configuration { iterations { id title } completedIterations { id title } } } } } } } }'
function Get-IterField { @((Invoke-Gql $q @{ id = $projId }).data.node.fields.nodes | ForEach-Object { $_ }) | Where-Object { $_.name -eq 'Iteration' } | Select-Object -First 1 }
$it = Get-IterField
if (-not $it) {
  $iters = @($data.iterations | ForEach-Object { @{ title = $_.title; startDate = $_.startDate; duration = [int]$_.duration } })
  $m = 'mutation($input:CreateProjectV2FieldInput!){ createProjectV2Field(input:$input){ projectV2Field{ ... on ProjectV2IterationField { id } } } }'
  $inp = @{ projectId = $projId; dataType = 'ITERATION'; name = 'Iteration'; iterationConfiguration = @{ startDate = $data.iterations[0].startDate; duration = 14; iterations = $iters } }
  try { $r = Invoke-Gql $m @{ input = $inp }; if ($r.errors) { throw ($r.errors | ConvertTo-Json -Depth 5) }; Write-Host '   field: Iteration (Sprint 1-5)' }
  catch { Write-Warning "Khong tao duoc field Iteration qua API: $_`nTao tay tren web: + New field > Iteration, ten 'Iteration', bat dau 2027-03-01, 2 tuan, 5 iteration 'Sprint 1'..'Sprint 5'; roi chay lai script." }
  $it = Get-IterField
}
$iterId = @{}; if ($it) { foreach ($x in @($it.configuration.iterations) + @($it.configuration.completedIterations)) { if ($x) { $iterId[$x.title] = $x.id } } }
$fields = (Invoke-GhJson @('project','field-list',"$num",'--owner',$Owner,'--format','json','--limit','50')).fields
function FieldId([string]$n) { ($fields | Where-Object { $_.name -eq $n }).id }
function OptId([string]$n, [string]$v) { (($fields | Where-Object { $_.name -eq $n }).options | Where-Object { $_.name -eq $v }).id }
$statusMap = @{ 'Done'='Done'; 'In Progress'='In Progress'; 'Todo'='Todo'; 'Blocked'='Todo' }

Write-Host "== 5. Gan item + dien field" -ForegroundColor Cyan
$items = (Invoke-GhJson @('project','item-list',"$num",'--owner',$Owner,'--format','json','--limit','1000')).items
foreach ($i in $data.issues) {
  $u = $map[$i.key].url
  $item = $items | Where-Object { $_.content.url -eq $u } | Select-Object -First 1
  if (-not $item) { $item = Invoke-GhJson @('project','item-add',"$num",'--owner',$Owner,'--url',$u,'--format','json') }
  $e = New-Object System.Collections.ArrayList
  [void]$e.Add(@('--field-id',(FieldId 'Status'),'--single-select-option-id',(OptId 'Status' $statusMap[$i.status])))
  [void]$e.Add(@('--field-id',(FieldId 'Epic'),'--single-select-option-id',(OptId 'Epic' $i.epic)))
  [void]$e.Add(@('--field-id',(FieldId 'Estimate (h)'),'--number',"$($i.hours)"))
  if ($i.member) { [void]$e.Add(@('--field-id',(FieldId $AssigneeField),'--single-select-option-id',(OptId $AssigneeField $i.member))) }
  if ($null -ne $i.actual) { [void]$e.Add(@('--field-id',(FieldId 'Actual (h)'),'--number',"$($i.actual)")) }
  if ($null -ne $i.swp) { [void]$e.Add(@('--field-id',(FieldId 'SWP'),'--number',"$($i.swp)")) }
  if ($i.iteration -and $iterId[$i.iteration]) { [void]$e.Add(@('--field-id',$it.id,'--iteration-id',$iterId[$i.iteration])) }
  foreach ($x in $e) {
    if (-not $x[1] -or -not $x[3]) { Write-Warning "$($i.key): bo qua $($x -join ' ')"; continue }
    Invoke-Gh -Write (@('project','item-edit','--id',$item.id,'--project-id',$projId) + $x) | Out-Null }
  if ($i.close -and $map[$i.key].state -ne 'CLOSED') {
    try { Invoke-Gh -Write @('issue','close',$u,'-R',$Repo,'-c','Sprint 1 done (simulated data / LAB-5)') | Out-Null }
    catch { if ("$_" -notmatch 'already closed') { throw } }
  }
  Write-Host "   $($i.key) $($i.status)"
}
Write-Host "`nXong. Project: gh project view $num --owner $Owner --web" -ForegroundColor Green
Write-Host "Nho: Project Settings > Visibility = Public; dan link vao README.md."
