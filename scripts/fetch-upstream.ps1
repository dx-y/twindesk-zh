#requires -Version 5.1
<#
  Download the upstream TwinDesk source for a given tag and unpack it to build\src\<TwinDesk-ver>.
  Usage: .\scripts\fetch-upstream.ps1 -Tag v3.2.1
  Direct github.com access is often blocked from mainland China, so mirror prefixes are tried
  first and gh api (api.github.com) is the last resort.
#>
[CmdletBinding()]
param(
  [string]$Tag  = '',
  [string]$Repo = 'InukaAsith/TwinDesk'
)

$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $PSScriptRoot
$build  = Join-Path $root 'build'
$srcDir = Join-Path $build 'src'
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null

if (-not $Tag) {
  $Tag = (gh api "repos/$Repo/tags?per_page=1" --jq '.[0].name' 2>$null)
  if (-not $Tag) { throw 'Could not resolve the latest upstream tag; pass -Tag explicitly.' }
  $Tag = $Tag.Trim()
}
Write-Host "Upstream: $Repo  tag: $Tag"

$ver   = $Tag -replace '^v', ''
$final = Join-Path $srcDir "TwinDesk-$ver"
if (Test-Path (Join-Path $final 'windows\package.json')) {
  Write-Host "Source already present: $final (download skipped)"
  return $final
}

$zip = Join-Path $build "upstream-$Tag.zip"
if (-not (Test-Path $zip)) {
  New-Item -ItemType Directory -Force -Path $build | Out-Null
  $url = "https://github.com/$Repo/archive/refs/tags/$Tag.zip"
  $ok  = $false
  foreach ($prefix in @('https://ghfast.top/', 'https://gh-proxy.com/', 'https://ghproxy.net/', '')) {
    try {
      Write-Host "Downloading: $prefix$url"
      Invoke-WebRequest -Uri ($prefix + $url) -OutFile $zip -UseBasicParsing -TimeoutSec 180
      if ((Get-Item $zip).Length -gt 1000000) { $ok = $true; break }
    } catch {
      Write-Host "  failed: $($_.Exception.Message)"
    }
  }
  if (-not $ok) {
    Write-Host 'All mirrors failed, falling back to gh api (api.github.com).'
    if (Test-Path $zip) { Remove-Item $zip -Force }
    $tok = (gh auth token).Trim()
    & curl.exe -sS -L --max-time 1800 -H "Authorization: Bearer $tok" -o $zip "https://api.github.com/repos/$Repo/zipball/$Tag"
    if (-not (Test-Path $zip) -or (Get-Item $zip).Length -lt 1000000) { throw 'gh api download failed.' }
  }
  Write-Host ("Archive: {0:N2} MB" -f ((Get-Item $zip).Length / 1MB))
}

$tmp = Join-Path $build ("unpack-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $tmp)
$inner = Get-ChildItem $tmp -Directory | Select-Object -First 1
Move-Item $inner.FullName $final
Write-Host "Source ready: $final"
return $final
