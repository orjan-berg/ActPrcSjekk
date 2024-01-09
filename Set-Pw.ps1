# script for setting encrypted password for sql user
Set-Location 'E:\data\GIT\ActPrcSjekk'
$file = '.\pw.txt'
$user = 'sa'
(Get-Credential).Password | ConvertFrom-SecureString | Out-File pw.txt
$mycredential = New-Object -TypeName System.Management.Automation.pscredential -ArgumentList $User, (Get-Content $file | ConvertTo-SecureString)