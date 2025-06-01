param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("select", "whoami", "list")]
  [string]$action,

  [string]$profileName
)

# Hardcoded accounts
$accounts = @{
  "account1" = @{
    aws_access_key_id     = "YOUR_KEY"
    aws_secret_access_key = "YOUR_SECRET"
    region                = "ap-south-1"
  }
  "account2" = @{
    aws_access_key_id     = "YOUR_KEY"
    aws_secret_access_key = "YOUR_SECRET"
    region                = "ap-south-1"
  }
}

# AWS config/credentials file paths
$credsPath = "$HOME\.aws\credentials"
$configPath = "$HOME\.aws\config"


function Set-DefaultProfile($p) {
  $data = $accounts[$p]
  if (-not $data) {
    Write-Host "Profile '$p' not found." -ForegroundColor Red
    exit 1
  }

  # Create .aws directory if it doesn't exist
  $awsDir = Split-Path $credsPath -Parent
  if (-not (Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
  }

  # Write to credentials file
  $credContent = "[default]`n"
  $credContent += "aws_access_key_id = $($data.aws_access_key_id)`n"
  $credContent += "aws_secret_access_key = $($data.aws_secret_access_key)"
  Set-Content -Path $credsPath -Value $credContent

  # Write to config file
  $configContent = "[default]`n"
  $configContent += "region = $($data.region)`n"
  $configContent += "output = json"
  Set-Content -Path $configPath -Value $configContent

  Write-Host "Switched default AWS account to '$p'" -ForegroundColor Green
}

function WhoAmI() {
  if (-not (Test-Path $credsPath)) {
    Write-Host "Credentials file not found."
    exit 1
  }

  $creds = Get-Content $credsPath
  $currentKey = ($creds | Where-Object { $_ -match "aws_access_key_id" }) -replace ".*= ", ""

  foreach ($kv in $accounts.GetEnumerator()) {
    if ($kv.Value.aws_access_key_id -eq $currentKey) {
      Write-Host "Current account: $($kv.Key)"
      return
    }
  }

  Write-Host "Current account not recognized."
}

function ListProfiles() {
  Write-Host "Available profiles:"
  $accounts.Keys | ForEach-Object { Write-Host "$_" -ForegroundColor Blue }
}

# Command dispatcher
switch ($action) {
  "select" {
    if (-not $profileName) {
      Write-Host "Please provide a profile name: e.g. awsuse.ps1 select main"
      exit 1
    }
    Set-DefaultProfile $profileName
    break
  }
  "whoami" {
    WhoAmI
    break
  }
  "list" {
    ListProfiles
    break
  }
}