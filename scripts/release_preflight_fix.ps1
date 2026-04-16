$ErrorActionPreference = 'Stop'
function Invoke-CheckedCommand {
  param([Parameter(Mandatory = $true)][string]$Command)
  Invoke-Expression $Command
  if ($LASTEXITCODE -ne 0) { throw "Failed: $Command" }
}

Write-Host '== Nozofibi Release Preflight ==' -ForegroundColor Cyan

if (-not (Test-Path 'android/key.properties')) { throw 'Missing android/key.properties' }
if (-not (Test-Path 'android/app/proguard-rules.pro')) { throw 'Missing proguard-rules.pro' }

Write-Host '0/4 load release signing secrets' -ForegroundColor Yellow
. .\scripts\signing\load_release_signing_secrets.ps1
if (-not $env:NOZOFIBI_STORE_PASSWORD -or -not $env:NOZOFIBI_KEY_PASSWORD) {
  throw 'Release signing secrets are missing in shell environment.'
}

Write-Host '1/4 flutter pub get' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter pub get'

Write-Host '2/4 flutter analyze' -ForegroundColor Yellow
$ErrorActionPreference = 'Continue'
flutter analyze --no-fatal-infos
$ErrorActionPreference = 'Stop'
Write-Host 'Analyze passed with info-level lints' -ForegroundColor Green

Write-Host '3/4 flutter test' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter test'

Write-Host '4/4 flutter build appbundle --release' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter build appbundle --release'

Write-Host 'Preflight completed successfully!' -ForegroundColor Green
