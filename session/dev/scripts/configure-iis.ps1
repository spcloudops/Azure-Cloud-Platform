$ErrorActionPreference = "Stop"

try {
    $installation = Install-WindowsFeature `
        -Name Web-Server `
        -IncludeManagementTools

    if (-not $installation.Success) {
        throw "IIS installation did not succeed."
    }

    if ($installation.RestartNeeded -eq "Yes") {
        throw "IIS installation requires a restart; review before proceeding."
    }

    $webRoot = "C:\inetpub\wwwroot"

    $page = @"
<!DOCTYPE html>
<html>
<head>
    <title>Rapid Platform VMSS</title>
</head>
<body>
    <h1>Azure Rapid Platform</h1>
    <p>Application: private VMSS web tier</p>
    <p>Serving instance: $env:COMPUTERNAME</p>
</body>
</html>
"@

    Set-Content `
        -Path "$webRoot\index.html" `
        -Value $page `
        -Encoding UTF8

    Import-Module WebAdministration

    Start-Service W3SVC

    if ((Get-Website -Name "Default Web Site").State -ne "Started") {
        Start-Website -Name "Default Web Site"
    }

    $response = Invoke-WebRequest `
        -Uri "http://localhost/index.html" `
        -UseBasicParsing

    if ($response.StatusCode -ne 200) {
        throw "The local website did not return HTTP 200."
    }

    if ($response.Content -notmatch $env:COMPUTERNAME) {
        throw "The website does not contain the expected instance name."
    }

    Write-Output "IIS configured and validated on $env:COMPUTERNAME."
}
catch {
    Write-Error $_
    exit 1
}