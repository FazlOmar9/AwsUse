param (
    # We will still parse arguments manually to allow flexible --region placement
)

# Hardcoded accounts
$accounts = @{
    "main"      = @{
        aws_access_key_id     = "redacted_main_key" # Replace with actual key
        aws_secret_access_key = "redacted_main_secret" # Replace with actual secret
        default_region        = "ap-south-1"
    }
    "veritex" = @{
        aws_access_key_id     = "redacted_veritex_key" # Replace with actual key
        aws_secret_access_key = "redacted_veritex_secret" # Replace with actual secret
        default_region        = "ap-south-1"
    }
    "clients" = @{
        aws_access_key_id     = "redacted_clients_key" # Replace with actual key
        aws_secret_access_key = "redacted_clients_secret" # Replace with actual secret
        default_region        = "ap-south-1"
    }
}

# AWS config/credentials file paths
$credsPath = "$HOME\.aws\credentials"
$configPath = "$HOME\.aws\config"


function Set-DefaultProfile($p, $dynamicRegion = $null) {
    $data = $accounts[$p]
    if (-not $data) {
        Write-Host "Profile '$p' not found." -ForegroundColor Red
        exit 1
    }

    # Determine the region to use: dynamicRegion if provided, otherwise default_region from account data
    $selectedRegion = if ($dynamicRegion) {
        $dynamicRegion
    } else {
        $data.default_region
    }

    if ([string]::IsNullOrEmpty($selectedRegion)) {
        Write-Host "No region specified for profile '$p' and no default region found." -ForegroundColor Red
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
    $configContent += "region = $($selectedRegion)`n" # Use the determined region
    $configContent += "output = json"
    Set-Content -Path $configPath -Value $configContent

    Write-Host "Switched default AWS account to '$p' with region '$selectedRegion'" -ForegroundColor Green
}

function WhoAmI() {
    if (-not (Test-Path $credsPath)) {
        Write-Host "Credentials file not found."
        exit 1
    }

    $creds = Get-Content $credsPath
    $currentKey = ($creds | Where-Object { $_ -match "aws_access_key_id" }) -replace ".*= ", ""

    $currentProfileName = $null
    foreach ($kv in $accounts.GetEnumerator()) {
        if ($kv.Value.aws_access_key_id -eq $currentKey) {
            $currentProfileName = $kv.Key
            break
        }
    }

    if ($null -eq $currentProfileName) {
        Write-Host "Current account: Not recognized (Access Key ID: $currentKey)" -ForegroundColor Yellow
    } else {
        Write-Host "Current account: $currentProfileName" -ForegroundColor Green
    }

    # Read and display current region from config file
    if (Test-Path $configPath) {
        $configContent = Get-Content $configPath
        $currentRegion = ($configContent | Where-Object { $_ -match "^\s*region\s*=" }) -replace "^\s*region\s*=\s*", ""
        if (-not ([string]::IsNullOrEmpty($currentRegion))) {
            Write-Host "Current region: $currentRegion" -ForegroundColor Blue
        } else {
            Write-Host "Current region: Not found in config file." -ForegroundColor Yellow
        }
    } else {
        Write-Host "AWS config file not found ($configPath)." -ForegroundColor Yellow
    }
}

function ListProfiles() {
    Write-Host "Available profiles:"
    $accounts.Keys | ForEach-Object { Write-Host "$_" -ForegroundColor Blue}
}


# --- Updated Command Dispatcher Logic ---

# Check if any arguments were passed
if ($args.Count -eq 0) {
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  awsuse select <profileName> [--region <region>]" -ForegroundColor Cyan
    Write-Host "  awsuse whoami" -ForegroundColor Cyan
    Write-Host "  awsuse list" -ForegroundColor Cyan
    exit 1
}

$action = $args[0].ToLower()
$profileName = $null
$region = $null

switch ($action) {
    "select" {
        if ($args.Count -lt 2) {
            Write-Host "Error: 'select' action requires a profile name." -ForegroundColor Red
            Write-Host "Usage: awsuse select <profileName> [--region <region>]" -ForegroundColor Red
            exit 1
        }
        $profileName = $args[1]

        # Parse for --region flag from the third argument onwards
        for ($i = 2; $i -lt $args.Count; $i++) {
            if ($args[$i].ToLower() -eq "--region") {
                if ($i + 1 -lt $args.Count) {
                    $region = $args[$i + 1]
                    $i++ # Skip the next argument as it's the region value
                } else {
                    Write-Host "Error: --region flag requires a value." -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "Error: Unexpected argument '$($args[$i])'. Expected '--region'." -ForegroundColor Red
                exit 1
            }
        }

        Set-DefaultProfile $profileName $region
    }
    "whoami" {
        # Ensure no extra arguments are passed for whoami
        if ($args.Count -gt 1) {
            Write-Host "Error: 'whoami' action does not take additional arguments." -ForegroundColor Red
            exit 1
        }
        WhoAmI
    }
    "list" {
        # Ensure no extra arguments are passed for list
        if ($args.Count -gt 1) {
            Write-Host "Error: 'list' action does not take additional arguments." -ForegroundColor Red
            exit 1
        }
        ListProfiles
    }
    default {
        Write-Host "Error: Invalid action '$action'. Valid actions are 'select', 'whoami', 'list'." -ForegroundColor Red
        Write-Host "Usage:" -ForegroundColor Cyan
        Write-Host "  awsuse select <profileName> [--region <region>]" -ForegroundColor Cyan
        Write-Host "  awsuse whoami" -ForegroundColor Cyan
        Write-Host "  awsuse list" -ForegroundColor Cyan
        exit 1
    }
}
