$ErrorActionPreference = 'Stop'

$secretPath = Join-Path (Join-Path $env:LOCALAPPDATA 'Nozofibi') 'release-signing-secrets.json'

if (-not (Test-Path $secretPath)) {
  throw "Encrypted secret file not found at $secretPath. Run .\\scripts\\signing\\set_release_signing_secrets.ps1 first."
}

$json = Get-Content -Path $secretPath -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($json.storePassword) -or [string]::IsNullOrWhiteSpace($json.keyPassword)) {
  throw 'Encrypted secret file is invalid. Re-run set_release_signing_secrets.ps1.'
}

$storeSecure = ConvertTo-SecureString -String $json.storePassword
$keySecure = ConvertTo-SecureString -String $json.keyPassword

$storePlain = [System.Net.NetworkCredential]::new('', $storeSecure).Password
$keyPlain = [System.Net.NetworkCredential]::new('', $keySecure).Password

$env:NOZOFIBI_STORE_PASSWORD = $storePlain
$env:NOZOFIBI_KEY_PASSWORD = $keyPlain

if ([string]::IsNullOrWhiteSpace($env:NOZOFIBI_KEY_ALIAS)) {
  $env:NOZOFIBI_KEY_ALIAS = 'upload'
}

Write-Host 'Release signing secrets loaded into current shell environment.' -ForegroundColor Green