$ErrorActionPreference = 'Stop'
function Invoke-CheckedCommand {
  param([Parameter(Mandatory = $true)][string]$Command)
  Invoke-Expression $Command
  if ($LASTEXITCODE -ne 0) { throw "Failed: $Command" }
}

Write-Host '== Nozofibi Release Preflight ==' -ForegroundColor Cyan

if (-not (Test-Path 'android/key.properties')) { throw 'Missing android/key.properties' }
if (-not (Test-Path 'android/app/proguard-rules.pro')) { throw 'Missing proguard-rules.pro' }

Write-Host '1/4 flutter pub get' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter pub get'

Write-Host '2/4 flutter analyze' -ForegroundColor Yellow
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$analyzeOutput = & flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1
$ErrorActionPreference = $previousErrorActionPreference
$analyzeText = ($analyzeOutput | Out-String)
Write-Output $analyzeOutput

if ($analyzeText -match '(?m)^\s*error\s*-') {
  throw 'flutter analyze reported at least one error. Fix errors before release.'
}

Write-Host 'Analyze passed (no error-level issues)' -ForegroundColor Green

Write-Host '3/4 flutter test' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter test'

Write-Host '4/4 flutter build appbundle --release' -ForegroundColor Yellow
Invoke-CheckedCommand 'flutter build appbundle --release'

Write-Host 'Preflight completed successfully!' -ForegroundColor Green
