#Self-Elevates the Powershell to Admin
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

#Enables AIP
Clear
start-process powershell -verb runas
Set-ExecutionPolicy RemoteSigned -Force
$UserCredential = Get-Credential -Message "Enter Admin Credentials for the Office 365 Account you are wanting to access."
Write-Host
$UserToTest = Read-Host "Enter the Email Address you want to check"
Write-Host
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
Get-IRMConfiguration
Install-Module -Name AIPService
Get-Command -Module aadrm
Connect-AadrmService -Credential $UserCredential
Enable-Aadrm
$rmsConfig = Get-AadrmConfiguration
$rmsConfig.LicensingIntranetDistributionPointUrl
$LicenseUri = $RMSConfig.LicensingIntranetDistributionPointUrl
Set-IRMConfiguration -LicensingLocation $LicenseUri
Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true
Get-IRMconfiguration
Test-IRMConfiguration -sender $UserToTest
read-host “Press Any Key to Close.”
Remove-PSSession $Session