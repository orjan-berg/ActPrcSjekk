﻿# used to store encrypted password for the sql-user used to connect to the sql-server
function Load-Module ($n) {
    if (Get-Module | Where-Object { $_.name -eq $n }) {
        Write-Host "Module $n is already imported."
    } else {
        if (Get-Module -ListAvailable | Where-Object { $_.name -eq $n }) {
            Import-Module $n -Verbose
        } else {
            if (Find-Module -Name $n | Where-Object { $_.name -eq $n }) {
                Install-Module -Name $n -Force -Verbose -Scope CurrentUser
                Import-Module $n -Verbose
            } else {
                Write-Host "Module $n not imported, not available and not in an online gallery, exiting."
                Exit 1
            }
        }
    }
}

Load-Module 'dbatools'

$instPath = Read-Host 'Enter installation path'


# change $outfile path to reflect your path
$outfile = "$instPath\config.dat"
(Get-Credential).Password | ConvertFrom-SecureString | Out-File $outfile

