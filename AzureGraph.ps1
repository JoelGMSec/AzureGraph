#================================#
#    AzureGraph by @JoelGMSec    #
#      https://darkbyte.net      #
#================================#

# Design
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$OSVersion = [Environment]::OSVersion.Platform
While ($true){ if ($OSVersion -like "*Win*") {
$Host.UI.RawUI.BackgroundColor = "Black" }
$Host.UI.RawUI.WindowTitle = "AzureGraph - by @JoelGMSec" 
$Host.UI.RawUI.ForegroundColor = "White"

# Banner
function Show-Banner {
Clear-Host
Write-Host
Write-Host "     _                         ____                 _      " -ForegroundColor Blue
Write-Host "    / \    _____   _ _ __ ___ / ___|_ __ __ _ _ __ | |__   " -ForegroundColor Blue
Write-Host "   / _ \  |_  / | | | '__/ _ \ |  _| '__/ _' | '_ \| '_ \  " -ForegroundColor Blue
Write-Host "  / ___ \  / /| |_| | | |  __/ |_| | | | (_| | |_) | | | | " -ForegroundColor Blue
Write-Host " /_/   \_\/___|\__,_|_|  \___|\____|_|  \__,_| .__/|_| |_| " -ForegroundColor Blue
Write-Host "                                             |_|           " -ForegroundColor Blue
Write-Host "  -------------------- by @JoelGMSec --------------------  " -ForegroundColor Green
Write-Host }

# Help
function Show-Help {
Write-host ; Write-Host " Info: " -ForegroundColor Yellow -NoNewLine ; Write-Host " This tool helps you to obtain information from Azure AD"
Write-Host "        like Users or Devices, using de Microsft Graph REST API"
Write-Host ; Write-Host " Usage: " -ForegroundColor Yellow -NoNewLine ; Write-Host ".\AzureGraph.ps1 -h" -ForegroundColor Blue 
Write-Host "          Show this help, more info on my blog: darkbyte.net" -ForegroundColor Green
Write-Host ; Write-Host "        .\AzureGraph.ps1" -ForegroundColor Blue 
Write-Host "          Execute AzureGraph in fully interactive mode" -ForegroundColor Green
Write-Host ; Write-Host " Warning: " -ForegroundColor Red -NoNewLine  ; Write-Host "You need previously generated MS Graph token to use it"
Write-Host "         " -NoNewLine ; Write-Host " You can use a refresh token too, or generate a new one" ; Write-Host }

# Proxy Aware
[System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy()
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$AllProtocols = [System.Net.SecurityProtocolType]"Ssl3,Tls,Tls11,Tls12" ; [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

# Main function
if ($args[0] -like "-h*") { Show-Banner ; Show-Help ; break }
Show-Banner ; if ($SearchMode) { $StartMode = $False ; $xmin = 6 ; $ymin = 13
if (!$Token) { $Token = $(Get-Content "$pwd\AzureGraph\token.txt") }

# MS Graph headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers = @{}
$headers.Add("Authorization","Bearer $($Token)")
$headers.Add("ConsistencyLevel","eventual")

# Selection options
if (($selection -like "*token*") -or ($selection2 -like "*token*")) { $selection2 = "token"
$SearchMode = $True ; $StartMode = $True ; $xmin = 6 ; $ymin = 11
$List = @("Generate MS Graph Token with credentials","Generate MS Graph Token with Refresh Token"
"Get MS Graph Token from input")
[array]$List = $List + "GO BACK"

if (($selection -like "*credentials*") -or ($selection2 -like "*credentials*")) { $selection2 = "credentials"
do { Write-Host "[+] Enter your TenantID: " -NoNewLine -ForegroundColor Yellow
$TenantID = Read-Host } until ($TenantID) ; $SearchMode = $null ; $StartMode = $True 

$Credential = Get-Credential
$AuthUri = "https://login.microsoftonline.com/$TenantID/oauth2/token"
$Resource = "graph.microsoft.com"
$AuthBody = "grant_type=client_credentials&client_id=$($Credential.UserName)&client_secret=$($Credential.GetNetworkCredential().Password)"
$AuthBody = $AuthBody + "&resource=https%3A%2F%2F$Resource%2F"

$Response = Invoke-WebRequest -UseBasicParsing -Method "POST" -Uri $AuthUri -Body $AuthBody
if ($Response.access_token) { Write-Host "`n[+] MS Graph Token updated successfully!`n" -ForegroundColor Green ; $Token = $Response.access_token }
else { Write-Host "`n[!] Unauthorized! Check your MS Graph token!`n" -ForegroundColor Red }
$Token > "$pwd\AzureGraph\token.txt" ; Start-Sleep -milliseconds 3000 }

if (($selection -like "*refresh*") -or ($selection2 -like "*refresh*")) { $selection2 = "refresh"
do { Write-Host "[+] Paste your refresh token here: " -NoNewLine -ForegroundColor Yellow
$RefreshToken = Read-Host } until ($RefreshToken) ; $SearchMode = $null ; $StartMode = $True

$headers = [System.Collections.Generic.Dictionary[string,string]]::new()
$headers.Add("Host", "login.microsoftonline.com")
$headers.Add("Accept", "*/*")
$headers.Add("Origin", "https://developer.microsoft.com")
$Uri = "https://login.microsoftonline.com:443/common/oauth2/v2.0/token"
$Body = "grant_type=refresh_token&refresh_token=$RefreshToken"
$Response = (Invoke-WebRequest -Method "POST" -Uri $Uri -Headers $headers -Body $Body)

if (!$Response) { Write-Host "`n[!] Unauthorized! Check your MS Graph token!`n" -ForegroundColor Red }
else { $JsonToken = ($Response.Content | ConvertFrom-Json) ; New-Item -ItemType Directory "AzureGraph" -Force 2>&1> $null 
$Token = $JsonToken.access_token ; $NewRefreshToken = $JsonToken.refresh_token 
$NewRefreshToken > "$pwd\AzureGraph\refresh_token.txt" ; 
Write-Host "`n[+] MS Graph Token updated successfully!`n" -ForegroundColor Green }
$Token > "$pwd\AzureGraph\token.txt" ; Start-Sleep -milliseconds 3000 }

if (($selection -like "*from*") -or ($selection2 -like "*from*")) { $selection2 = "from"
do { Write-Host "[+] Paste your token here: " -NoNewLine -ForegroundColor Yellow
$TempToken = Read-Host } until ($TempToken) ; $SearchMode = $null ; $StartMode = $True

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers = @{}
$headers.Add("Authorization","Bearer $($TempToken)")
$headers.Add("ConsistencyLevel","eventual")
$Uri = "https://graph.microsoft.com/v1.0/me"

$Response = (Invoke-WebRequest -UseBasicParsing -Method GET -Uri $Uri -Headers $Headers).content | ConvertFrom-Json
if (!$Response) { Write-Host "`n[!] Unauthorized! Check your MS Graph token!`n" -ForegroundColor Red }
else { $Token = $TempToken ; Write-Host "`n[+] MS Graph Token updated successfully!`n" -ForegroundColor Green }
$Token > "$pwd\AzureGraph\token.txt" ; Start-Sleep -milliseconds 3000 }}

if (($selection -like "*username*") -or ($selection2 -like "*users*")) { $selection2 = "users"
do { Write-Host "[+] Enter username to search: " -NoNewLine -ForegroundColor Yellow
if (!$Query) { $Query = Read-Host } else { Write-Host $Query }
if ($Query -like "*@*") { $filter = "mail" }
elseif ($Query -match '^[0-9]+$') { $filter = "mobilePhone" }
else { $filter = "displayName" }} until ($Query)
$Uri = "https://graph.microsoft.com/v1.0/users?`$count=true&`$search=`"$filter`:$Query`"&`$orderBy=displayName" }

if (($selection -like "*group*") -or ($selection2 -like "*groups*")) { $selection2 = "groups"
do { Write-Host "[+] Enter group to search: " -NoNewLine -ForegroundColor Yellow
if (!$Query) { $Query = Read-Host } else { Write-Host $Query }} until ($Query)
$Uri = "https://graph.microsoft.com/v1.0/groups?`$count=true&`$search=`"displayName`:$Query`"&`$orderBy=displayName" }

if (($selection -like "*device*") -or ($selection2 -like "*devices*")) { $selection2 = "devices"
do { Write-Host "[+] Enter device to search: " -NoNewLine -ForegroundColor Yellow
if (!$Query) { $Query = Read-Host } else { Write-Host $Query }} until ($Query)
$Uri = "https://graph.microsoft.com/v1.0/devices?`$count=true&`$search=`"displayName`:$Query`"&`$orderBy=displayName" }

if (($selection -like "*service*") -or ($selection2 -like "*servicePrincipals*")) { $selection2 = "servicePrincipals"
do { Write-Host "[+] Enter service to search: " -NoNewLine -ForegroundColor Yellow
if (!$Query) { $Query = Read-Host } else { Write-Host $Query }} until ($Query)
$Uri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$count=true&`$search=`"displayName`:$Query`"&`$orderBy=displayName" }

if (($selection -like "*application*") -or ($selection2 -like "*applications*")) { $selection2 = "applications"
do { Write-Host "[+] Enter application to search: " -NoNewLine -ForegroundColor Yellow
if (!$Query) { $Query = Read-Host } else { Write-Host $Query }} until ($Query)
$Uri = "https://graph.microsoft.com/v1.0/applications?`$count=true&`$search=`"displayName`:$Query`"&`$orderBy=displayName" }

if (($selection -like "*organization*") -or ($selection2 -like "*organization*")) { $selection2 = "organization"
Write-Host "[+] Select your organization: " -ForegroundColor Yellow
$Uri = "https://graph.microsoft.com/v1.0/organization" ; $xmin = 6 ; $ymin = 13 }

if (($selection -like "*domains*") -or ($selection2 -like "*domains*")) { $selection2 = "domains"
Write-Host "[+] Select one domain: " -ForegroundColor Yellow
$Uri = "https://graph.microsoft.com/v1.0/domains" ; $xmin = 6 ; $ymin = 13 }

if (($selection -like "*download*") -or ($selection2 -like "*download*")) { $selection2 = "download"
Write-Host "[+] Downloading all info.." -ForegroundColor Yellow 
Write-Host "`n[!] WARNING: This can take a while!`n" -ForegroundColor Red 

# Download List
$DownloadList = @("users", "groups", "devices", "servicePrincipals", "applications", "organization", "domains")

# Check if file exists
$DownloadComplete = foreach ($_ in $DownloadList) { Test-Path "$pwd\AzureGraph\$_.txt" }

# Download Process
Write-Host "[>] Downloading token.. " -NoNewLine -ForegroundColor Blue
if ($DownloadComplete -like "*False*") { New-Item -ItemType Directory "AzureGraph" -Force 2>&1> $null 
$Token > "$pwd\AzureGraph\token.txt" } ; Start-Sleep -milliseconds 500 ; Write-Host "[OK]" -ForegroundColor Green
foreach ($_ in $DownloadList) { $DownloadArray = @()
Write-Host "[>] Downloading $_.. " -NoNewLine -ForegroundColor blue
Start-Sleep -milliseconds 500 ; if ($DownloadComplete -like "*False*") {
$Uri = "https://graph.microsoft.com/v1.0/$_"
[array]$Array = Invoke-WebRequest -UseBasicParsing -Method GET -Uri $Uri -Headers $Headers | ConvertFrom-Json
$DownloadArray += $Array.Value | ConvertTo-Json -Depth 10
$NextLink = $Array.'@odata.NextLink'
While ($NextLink -ne $Null) {
$Array = iwr -Method GET -Uri $NextLink -Headers $headers | ConvertFrom-Json
$DownloadArray += $Array.Value| ConvertTo-Json -Depth 10
$NextLink = $Array.'@odata.NextLink' }
$DownloadArray > "$pwd\AzureGraph\$_.txt" } Write-Host "[OK]" -ForegroundColor Green }
$Host.UI.RawUI.ForegroundColor = "Yellow" ; Write-Host ; pause
$SearchMode = $True ; $StartMode = $True ; $selection2 = $null
$Host.UI.RawUI.ForegroundColor = "White" ; $xmin = 6 ; $ymin = 11
Clear-Host ; Show-Banner }

# Access MS Graph data
if ((!$StartMode) -and ($selection2)) {
if (Test-Path "$pwd\AzureGraph\$selection2.txt") { $Json = cat "$pwd\AzureGraph\$selection2.txt" | ConvertFrom-Json }
else { $Json = (Invoke-WebRequest -UseBasicParsing -Method GET -Uri $Uri -Headers $Headers).content | ConvertFrom-Json
if (!$Json) { Write-Host "`n[!] Unauthorized! Check your MS Graph token!`n" -ForegroundColor Red ; Start-Sleep -milliseconds 3000 }
$Query = $null ; $skip = 0 ; $SearchMode = $null ; $StartMode = $True ; $xmin = 6 ; $ymin = 13 ; $selection2 = $null ; continue }

# Split results
if ($Json) { if (!$skip) { $skip = 0 }
if ($Json."@odata.count") { Write-Host "[+] Results found: " -NoNewLine -ForegroundColor Yellow ; $Json."@odata.count" }
else { Write-Host "[+] Results found: " -NoNewLine -ForegroundColor Yellow ; $Json.value.count }
if ($selection2 -notlike "*domains*") { $List = $Json.value.displayName | Select -Skip $skip -First 8 }
else { $List = $Json.value.id | Select -Skip $skip -First 8 }
[array]$List = $List + "NEXT RESULTS.."
[array]$List = $List + "GO BACK" }}}

# Main options
if ((!$SearchMode) -or (!$selection)) { Clear-Host ; Show-Banner
$List = @("Generate or input Auth Token", "Search for Username, Mail or Phone", "Search for User Groups"
"Search for Device Name", "Search for Service Principal", "Search for Application", "Show Organization Info",
"Show Registered Domains", "Download all data", "Exit")
$SearchMode = $True ; $StartMode = $True ; $xmin = 6 ; $ymin = 11 }

# Write menu
Write-Host "Use the up/down arrows to navigate and press Enter" -ForegroundColor Yellow
[Console]::SetCursorPosition(0, $ymin)
foreach ($name in $List) { for ($i = 0; $i -lt $xmin; $i++) { Write-Host " " -NoNewline }
Write-Host "   " + $name }

# Highlight selected line
function Write-Highlighted { Start-Sleep -Milliseconds 10
[Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
Write-Host ">" -BackgroundColor Green -ForegroundColor Black -NoNewline
Write-Host " " + $List[$cursorY] -BackgroundColor Green -ForegroundColor Black
[Console]::SetCursorPosition(0, $cursorY + $ymin)}
 
# Undoes highlight
function Write-Normal {
[Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
Write-Host "  " + $List[$cursorY]}
 
# Highlight first item by default
$cursorY = 0 ; $selection = "" ; $menu_active = $true
Write-Highlighted

# Menu actions
while ($menu_active) {
if ([console]::KeyAvailable) { $x = $Host.UI.RawUI.ReadKey()
[Console]::SetCursorPosition(1, $cursorY) ; Write-Normal
switch ($x.VirtualKeyCode) { 

38 { # down key
if ($cursorY -gt 0) {
$cursorY = $cursorY - 1 }}

40 { # Up key
if ($cursorY -lt $List.Length - 1) {
$cursorY = $cursorY + 1 }}

13 { # Enter key
$selection = $List[$cursorY]
$menu_active = $false
Clear-host ; Show-Banner

if ($selection -eq "Exit") { 
Write-Host "[!] Exiting..`n" -ForegroundColor Red
Start-Sleep -Milliseconds 3000 ; exit }

if (!$StartMode){ if ($selection -eq "GO BACK") { $Query = $null ; $skip = 0
$SearchMode = $null ; $selection2 = $null ; $selection = $null }
elseif ($selection -eq "NEXT RESULTS..") { $skip = $skip + 9 }

else { Write-host "[+] MS Graph Data:`n" -ForegroundColor Yellow
if ($selection2 -notlike "*domains*") {
$Json.value | where { $_.displayName -eq $selection } | Select -Last 1 }
else { $Json.value | where { $_.id -eq $selection } | Select -Last 1 }
$Host.UI.RawUI.ForegroundColor = "Yellow" ; pause }}}}}

Write-Highlighted } Start-Sleep -Milliseconds 10 }
