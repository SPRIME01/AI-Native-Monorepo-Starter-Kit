param(
    [string]$DomainsFile = "domains.txt",
    [string]$Type = "application"
)

if (-not (Test-Path $DomainsFile)) {
    Write-Host "Creating example domains.txt file..."
    @"
allocation
payments
invoicing
inventory
shipping
analytics
"@ | Out-File -FilePath "domains.txt" -Encoding UTF8

    Write-Host "Edit domains.txt and run again: .\scripts\generate-domains.ps1"
    exit 0
}

Write-Host "Reading domains from $DomainsFile..."
Get-Content $DomainsFile | ForEach-Object {
    $domain = $_.Trim()
    # Skip empty lines and comments
    if ($domain -and -not $domain.StartsWith('#')) {
        Write-Host "Creating $Type stack for domain: $domain"
        make domain-stack DOMAIN=$domain
    }
}

Write-Host "Domain generation complete!"
