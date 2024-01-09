$outfile = 'C:\Program Files (x86)\Vitari\ActPrcSjekk\config.dat'
(Get-Credential).Password | ConvertFrom-SecureString | Out-File $outfile