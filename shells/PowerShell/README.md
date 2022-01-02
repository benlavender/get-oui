# PowerShell

## Script file

To invoke the script file:

```powershell
.\get-oui.ps1 -MAC 'mac.addr'
```

## Module

Ideally, save the module to the $env:PSModulePath location...

```powershell
# Import the module from the working directory:
Import-Module -Name .\get-oui.psm1 
```