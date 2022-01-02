<#PSScriptInfo

.VERSION 1.0

.GUID 31e6b3a7-2fa3-480e-abcb-f96a1180d1ca

.AUTHOR ben@benlavender.co.uk

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI https://github.com/benlavender/get-oui/blob/main/LICENSE

.PROJECTURI https://github.com/benlavender/get-oui

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Gets the vendor reference from organizational unique identifiers and MAC addresses. 
 Requires access to Wireshark Foundation's GitLab on port 443
 Respects numerous MAC formats other than IEEE 802...

 .PARAMETER MAC
 MAC address or OUI string

 .Example 
 .\get-oui.ps1 -MAC '0015-5D68-5588'

#> 

#Requires -Version 3.0

Param(
    [Parameter(Mandatory=$true)][string]$MAC
)

# Script settings:
$URI='https://gitlab.com/wireshark/wireshark/-/raw/master/manuf'

# Confirms access to the GitLab repository:
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'stop'
Invoke-WebRequest -UseBasicParsing -Uri $URI | Out-Null
$ErrorActionPreference = 'continue'
$ProgressPreference = 'continue'

# Translates the strings to a usable lookup
if ($MAC -match '^([0-9A-Fa-f]{2}[.]){5}([0-9A-Fa-f]{2})$') {
    $MAC = $MAC.Substring(0,8)
}
elseif ($MAC -match '^([0-9A-Fa-f]{2}[-]){5}([0-9A-Fa-f]{2})$') {
    $MAC = ($MAC -replace '[-]',':').Substring(0,8)
}
elseif ($MAC -match '^([0-9A-Fa-f]{2}[.]){5}([0-9A-Fa-f]{2})$') {
    $MAC = ($MAC -replace '[.]',':').Substring(0,8)
}
elseif ($MAC -match '^([0-9A-Fa-f]{4}[-]){2}([0-9A-Fa-f]{4})$') {
    [string]$MAC = ($MAC -replace '[-]','')
    $MAC = $MAC.Insert(2,':').Insert(5,':').Insert(8,':').Insert(11,':').Insert(14,':').Substring(0,8)
}
elseif ($MAC -match '^([0-9A-Fa-f]{2}[-]){2}([0-9A-Fa-f]{2})$') {
    $MAC = ($MAC -replace '[-]',':')
}
elseif ($MAC -match '^([0-9A-Fa-f]{2}[.]){2}([0-9A-Fa-f]{2})$') {
    $MAC = ($MAC -replace '[.]',':')
}
elseif ($MAC -match '^([0-9A-Fa-f]{4}[-]){1}([0-9A-Fa-f]{2})$') {
    [string]$MAC = ($MAC -replace '[-]','')
    $MAC = $MAC.Insert(2,':').Insert(5,':')
}

# Queries for the translated OUI value:
if ($MAC -notmatch '^([0-9A-Fa-f]{2}[:]){2}([0-9A-Fa-f]{2})$') {
    Write-Host -ForegroundColor Red 'OUI value not valid for this operation'
}
else {
    (Invoke-WebRequest -UseBasicParsing -Uri $URI).Content.ToString() -split '[\r\n]' | Select-String -Pattern $MAC
}