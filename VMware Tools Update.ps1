## 1. Install Power CLI if not installed
## Install-Module VMware.PowerCLI -Scope CurrentUser -AllowClobber

## 2. Check the Power CLi version
## Get-PowerCLIVersion

## 3. To update remove first then install as per 1.
## Get-module VMware.* -listAvailable | Uninstall-Module -Force

## Variables
$VCServer=''
$DatacentreName=''
$VMList='C:\VMs with Outdated Tools.txt'
$logfile="C:\VMware Tools Update.log"

## Import PowerCLI module
Import-Module VMware.VimAutomation.Core

## Allows connection to vCenter with invalid cert
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

## Connect to vCenter
Connect-VIServer $VCServer

## Creates a txt doc with all VMs with VMware Tools
Get-Datacenter -Name $DatacentreName | get-vm | Where-Object -Property PowerState -eq 'PoweredOn'| get-vmguest | Select -Expandproperty VMName | FT -autosize | Out-File -FilePath $VMList

## Imports VMs from above txt file and updates VMware Tools without reboot
## Creates a log file with details of any errors
Start-Transcript -Path $logfile
$VMs = Get-Content $VMList
foreach ($VM in $VMs) {Get-VM -Name $VM  | Update-Tools -NoReboot} 
Stop-Transcript

## Use to check versions after upgrades 
Get-VM | Where-Object -Property PowerState -eq 'PoweredOn'| Select-Object -Property Name,@{Name='ToolsVersion';Expression={$_.Guest.ToolsVersion}}

## Commands for installing via advanced if automatic fails
## /s /v "/qn REBOOT=ReallySuppress"