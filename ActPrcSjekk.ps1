Function Log-Message([String]$Message) {
        Add-Content -Path '.\Log.txt' $Message
}

# Div variabler
$module = Get-Module -Name dbatools

$server = '192.168.50.43'

$database = 'vbsys'

$table = 'ActPrc'
$file = 'E:\Data\GIT\ActPrcSjekk\config.dat'
$user = 'sa'
$mycredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)


$smtpServer = 'smtp.bbnett.no'


$TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
Log-Message "$($TimeStamp) - Starting "

# checking if dbatools is available, if not import module
if ($module) {
        Write-Host "Module $($module.Name) - version $($module.Version) installed" -ForegroundColor Yellow
        Set-DbatoolsInsecureConnection -SessionOnly
} else {
        Import-Module -Name dbatools
        Write-Host 'Module dbatools imported' -ForegroundColor Yellow
        Set-DbatoolsInsecureConnection -SessionOnly
}


# remove -SqlCredential to use windows authentication
$TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
Log-Message "$($TimeStamp) - Connecting to $($server)"
$svr = Connect-DbaInstance -SqlInstance $server -SqlCredential $mycredential
$TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
Log-Message "$($TimeStamp) - Connected to $($server)"


# Finner informasjon om tabellen
$TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
Log-Message "$($TimeStamp) - Getting dataspace and rowcount"
$dataSpace = $svr.databases[$database].Tables[$table].DataSpaceUsed
$rowCount = $svr.databases[$database].Tables[$table].RowCount
#$dataSpace = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).DataSpaceUsed
#$rowCount = (Get-DbaDbTable -SqlInstance $server -Database $database -Table $table).RowCount
$TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
Log-Message "$($TimeStamp) - dataspace and rowcount collected"
Log-Message "$($TimeStamp) - DataSpaceUsed: $($dataSpace)"
Log-Message "$($TimeStamp) - RowCount: $($rowCount)"
try {
        $result = $dataSpace / $rowCount
} catch [System.DivideByZeroException] {
        <#Do this if a terminating exception happens#>
        $result = 0  
} finally {
        <#Do this after the try block regardless of whether an exception occurred or not#>
        if ($result -gt 3072) {
                # Truncate tabellen
                Invoke-DbaQuery -SqlInstance $server -SqlCredential $mycredential -Database $database -Query "TRUNCATE TABLE $table" -ErrorAction Stop
                # Send mail
                $to = 'orjan.berg@exsitec.no'
                $from = 'noreply@bbnett.no'
                $subject = "Test: $table har vokst for mye"
                $body = "Størrelsen på tabellen $table oversteg verdien 3 megabyte per rad.  
                Rutinene for å redusere tabellen er kjørt."
                # Send-MailMessage er ikke anbefalt brukt, men jeg har ikke funnet noe annet alternativ enda
                Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $smtpServer -Encoding utf8
                $TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
                Log-Message "$($TimeStamp) - Mail sent"
        
        } else {
                $TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
                Log-Message "$($TimeStamp) - Dataspace normal, no mail sent"
        }
        
        Disconnect-DbaInstance
        $TimeStamp = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
        Log-Message "$($TimeStamp) - Disconnected from $($server)"

}



