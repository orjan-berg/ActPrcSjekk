Function Log-Message([String]$Message) {
        Add-Content -Path '.\Log.txt' $Message
}

# Read configuration
$config = Get-Content .\config.json | ConvertFrom-Json

# Misc variables
$module = Get-Module -Name dbatools
$server = $config.server
$database = 'vbsys'
$table = 'ActPrc'
$file = 'E:\Data\GIT\ActPrcSjekk\config.dat'
$user = $config.SqlUser
$mycredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)
$smtpServer = $config.SmtpServer


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
                $to = $config.MailReceiver
                $from = $config.MailSender
                $subject = "$($config.company): $table har vokst for mye"
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



