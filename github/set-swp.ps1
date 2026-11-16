<#
.SYNOPSIS  Ghi SWP da chot (data/swp.csv, cot swp_final) vao field "SWP" cua Project. Chay sau khi review ket qua skill.
.USAGE     .\github\set-swp.ps1 [-DryRun]
#>
param([string]$Csv = (Join-Path $PSScriptRoot '..\data\swp.csv'), [string]$Owner='@me', [string]$Title='', [switch]$DryRun)
$ErrorActionPreference='Stop'; [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
if (-not $Title) { $Title = (Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'issues.json') | ConvertFrom-Json).project_title }
$gh = (Get-Command gh -CommandType Application | Select-Object -First 1).Source
function J([string[]]$a){ $o = & $gh @a; if ($LASTEXITCODE) { throw "gh $a" }; ($o -join "`n") | ConvertFrom-Json }
$rows = Import-Csv -Encoding UTF8 $Csv | Where-Object { $_.swp_final -ne '' }
$p = (J @('project','list','--owner',$Owner,'--format','json','--limit','100')).projects | Where-Object { $_.title -eq $Title } | Select-Object -First 1
if (-not $p) { throw "Khong thay Project '$Title'" }
$f = ((J @('project','field-list',"$($p.number)",'--owner',$Owner,'--format','json','--limit','50')).fields | Where-Object { $_.name -eq 'SWP' }).id
$items = (J @('project','item-list',"$($p.number)",'--owner',$Owner,'--format','json','--limit','1000')).items
$n = 0
foreach ($r in $rows) {
  $it = $items | Where-Object { $_.content.title.StartsWith("[$($r.id)]") } | Select-Object -First 1
  if (-not $it) { Write-Warning "Khong thay item $($r.id)"; continue }
  if ($DryRun) { Write-Host "  [dry-run] $($r.id) SWP=$($r.swp_final)"; continue }
  & $gh project item-edit --id $it.id --project-id $p.id --field-id $f --number $r.swp_final | Out-Null
  if ($LASTEXITCODE) { throw "item-edit $($r.id)" }; $n++
}
Write-Host "Da ghi SWP cho $n issue."
