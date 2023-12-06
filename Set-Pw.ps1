set-location 'C:\Program Files (x86)\Vitari\ActPrcSjekk'
$file = ".\pw.txt"
(Get-Credential).Password | ConvertFrom-SecureString | Out-File pw.txt
$user = "sa"
$mycredential = New-Object -TypeName System.Management.Automation.pscredential -ArgumentList $User,(Get-Content $file | ConvertTo-SecureString)