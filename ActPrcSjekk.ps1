# Import the dbatools module

# Import-Module dbatools


Function Log-Message([String]$Message) {
        Add-Content -Path '.\Log.txt' $Message
}

# Div variabler
$module = Get-Module -Name dbatools
$today = Get-Date
$server = 'byraa18.local'

$database = 'vbsys'

$table = 'ActPrc'
$file = 'E:\Data\GIT\ActPrcSjekk\config.dat'
$user = 'sa'
$mycredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)


$smtpServer = 'smtp.bbnett.no'


Write-Host "Running today $today"

# checking if dbatools is available, if not import module
if ($module) {
        Write-Host "Module $($module.Name) - version $($module.Version) installed" -ForegroundColor Yellow
} else {
        Import-Module -Name dbatools
        Write-Host 'Module dbatools imported' -ForegroundColor Yellow
}


# remove -SqlCredential to use windows authentication

Connect-DbaInstance -SqlInstance $server -SqlCredential $mycredential



# Finner informasjon om tabellen

$dataSpace = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).DataSpaceUsed

$rowCount = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).RowCount





if ($dataSpace / $rowCount -gt 3072) {

        # Truncate tabellen

        Invoke-DbaQuery -SqlInstance $server -Database $database -Query "TRUNCATE TABLE $table" -ErrorAction Stop

        # Send mail

        $to = 'orjan.berg@exsitec.no'

        $from = 'noreply@bbnett.no'

        $subject = "Test: $table har vokst for mye"

        $body = "Størrelsen på tabellen $table oversteg verdien 3 megabyte per rad.  

        Rutinene for å redusere tabellen er kjørt."

        # Send-MailMessage er ikke anbefalt brukt, men jeg har ikke funnet noe annet alternativ enda

        Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $smtpServer

}


Disconnect-DbaInstance

