$ErrorActionPreference = 'Stop'

$secretDir = Join-Path $env:LOCALAPPDATA 'Nozofibi'
$secretPath = Join-Path $secretDir 'release-signing-secrets.json'

New-Item -ItemType Directory -Force -Path $secretDir | Out-Null

Write-Host 'Set release signing secrets (stored with Windows DPAPI for current user).' -ForegroundColor Cyan

$storeSecure = Read-Host 'Enter keystore password (NOZOFIBI_STORE_PASSWORD)' -AsSecureString
$keySecure = Read-Host 'Enter key password (NOZOFIBI_KEY_PASSWORD)' -AsSecureString

$encryptedStore = ConvertFrom-SecureString -SecureString $storeSecure
$encryptedKey = ConvertFrom-SecureString -SecureString $keySecure

$secretDoc = [pscustomobject]@{
  storePassword = $encryptedStore
  keyPassword = $encryptedKey
  updatedAt = (Get-Date).ToString('o')
}

$secretDoc | ConvertTo-Json -Depth 3 | Set-Content -Path $secretPath -Encoding UTF8

Write-Host "Saved encrypted secrets to: $secretPath" -ForegroundColor Green
Write-Host "Next step (in same terminal): . .\\scripts\\signing\\load_release_signing_secrets.ps1" -ForegroundColor Yellow