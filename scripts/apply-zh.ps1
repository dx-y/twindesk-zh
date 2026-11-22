#requires -Version 5.1
<#
  Apply the Simplified Chinese layer to an upstream source tree:
    1) copy i18n\zh-extra.js to shared\lang, web\lang and android\app\src\main\assets\web
    2) apply patches\<tag>-zh-CN.patch (in-code English literals + catalog fallback chain)
  Usage: .\scripts\apply-zh.ps1 -Tag v3.2.1 [-Src <source dir>]
  If a newer upstream release changed the same lines, git apply reports a conflict and
  patches\<newtag>-zh-CN.patch has to be regenerated.
#>
[CmdletBinding()]
param(
  [string]$Tag = 'v3.2.1',
  [string]$Src = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$ver  = $Tag -replace '^v', ''
if (-not $Src) { $Src = Join-Path $root "build\src\TwinDesk-$ver" }
if (-not (Test-Path $Src)) { throw "Source tree not found: $Src (run fetch-upstream.ps1 first)." }

$patch = Join-Path $root ("patches\" + $Tag + "-zh-CN.patch")
if (-not (Test-Path $patch)) { throw "Patch not found: $patch" }

$extra = Join-Path $root 'i18n\zh-extra.js'
$targets = @(
  'shared\lang\zh-extra.js',
  'web\lang\zh-extra.js',
  'android\app\src\main\assets\web\zh-extra.js'
)
foreach ($t in $targets) {
  $dst = Join-Path $Src $t
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item $extra $dst -Force
  Write-Host "catalog -> $t"
}

Push-Location $Src
try {
  if (-not (Test-Path (Join-Path $Src '.git'))) {
    git init -q
    git config user.email 'zh@local'
    git config user.name  'twindesk-zh'
    git config core.autocrlf false
  }
  git apply --whitespace=nowarn -v $patch
  if ($LASTEXITCODE -ne 0) { throw "git apply failed (exit $LASTEXITCODE); upstream probably changed the same lines." }
  Write-Host 'Patch applied.'
} finally {
  Pop-Location
}

$i18n = Join-Path $Src 'shared\i18n.js'
if (-not (Select-String -Path $i18n -Pattern 'zh-extra' -Quiet)) { throw 'Verification failed: shared\i18n.js has no zh-extra fallback.' }
Write-Host 'Verified: shared\i18n.js carries the zh-extra fallback.'
return $Src
