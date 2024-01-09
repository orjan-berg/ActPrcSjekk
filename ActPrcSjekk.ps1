# Import the dbatools module

# Import-Module dbatools

$today = Get-Date

# Div variabler

$server = 'ON-SQL-04\ENTOTRE'

$database = 'vbsys'

$table = 'ActPrc'
$file = 'C:\Program Files (x86)\Vitari\ActPrcSjekk\config.dat'
$user = 'sa'
$mycredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)


$smtpServer = 'mx01.minedata.no'


Write-Host "Running today $today"


# remove -SqlCredential to use windows authentication

Connect-DbaInstance -SqlInstance $server -SqlCredential $mycredential



# Finner informasjon om tabellen

$dataSpace = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).DataSpaceUsed

$rowCount = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).RowCount





if ($dataSpace / $rowCount -gt 30) {

        # Truncate tabellen

        Invoke-DbaQuery -SqlInstance $server -Database $database -Query "TRUNCATE TABLE $table" -ErrorAction Stop

        # Send mail

        $to = 'orjan.berg@exsitec.no'

        $from = 'post@123regnskap.no'

        $subject = "$table har vokst for mye"

        $body = "St�rrelsen p� tabellen $table oversteg verdien 3 megabyte per rad.  

        Rutinene for � redusere tabellen er kj�rt."

        # Send-MailMessage er ikke anbefalt brukt, men jeg har ikke funnet noe annet alternativ enda

        Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $smtpServer

}


Disconnect-DbaInstance

