#requires -Version 5.1
<#
  Build the Windows installer (electron-builder / NSIS).
  Usage: .\scripts\build-windows.ps1 [-Src <source dir>] [-SkipHelper]
  On a machine without the Windows SDK (UnionMetadata\Windows.winmd) the C# helper and the
  C++ pieces cannot be compiled; -SkipHelper reuses windows-helper\bin\macshare-winhelper.exe
  as shipped by upstream.
#>
[CmdletBinding()]
param(
  [string]$Src = '',
  [switch]$SkipHelper,
  [string]$NpmRegistry = 'https://registry.npmmirror.com',
  [string]$ElectronMirror = 'https://npmmirror.com/mirrors/electron/'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Src) {
  $latest = Get-ChildItem (Join-Path $root 'build\src') -Directory -Filter 'TwinDesk-*' |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latest) { throw 'No source tree found; run fetch-upstream.ps1 first.' }
  $Src = $latest.FullName
}

$win = Join-Path $Src 'windows'
$ver = (Get-Content (Join-Path $win 'package.json') -Raw | ConvertFrom-Json).version
Write-Host "Source: $Src  version: $ver"

$env:ELECTRON_MIRROR     = $ElectronMirror
$env:npm_config_registry = $NpmRegistry
$env:CSC_IDENTITY_AUTO_DISCOVERY = 'false'
if ($SkipHelper) { $env:TWINDESK_SKIP_HELPER_BUILD = '1' }

Push-Location $win
try {
  if (-not (Test-Path 'node_modules')) {
    npm install --no-audit --no-fund
    if ($LASTEXITCODE -ne 0) { throw "npm install failed: $LASTEXITCODE" }
  }
  npm run dist
  if ($LASTEXITCODE -ne 0) { throw "build failed: $LASTEXITCODE" }
} finally {
  Pop-Location
}

$dist  = Join-Path $win 'dist'
$setup = Get-ChildItem $dist -Filter "TwinDesk-Setup-$ver.exe" -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -notmatch 'arm64|portable|FullKVM' } | Select-Object -First 1
if (-not $setup) { $setup = Get-ChildItem $dist -Filter '*Setup*.exe' | Select-Object -First 1 }
if (-not $setup) { throw 'Installer not found in dist.' }

$target = Join-Path $dist "TwinDesk-Setup-$ver-zh-CN.exe"
Move-Item $setup.FullName $target -Force
$hash = (Get-FileHash $target -Algorithm SHA256).Hash
Write-Host ("Done: {0}  {1:N2} MB  SHA256 {2}" -f $target, ((Get-Item $target).Length / 1MB), $hash)
return $target
