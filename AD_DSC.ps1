#The following modules are needed for this DSC configuration;
#1) Install-Module xPSDesiredStateConfiguration
#2) Install-Module xActiveDirectory
#3) Install-Module xNetworking (this is optional if you want to use DSC to configure your networking at a later time)

Configuration NewDomain
{

param(

    [parameter(Mandatory=$true)]
    [pscredential]$domainCred,

    [parameter(Mandatory=$true)]
    [pscredential]$safemodeAdministratorCred

)

Import-Module PSDesiredStateConfiguration
Import-DscResource -ModuleName xActiveDirectory
Import-DscResource –ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xNetworking

Node $AllNodes.Where{$_.Role -eq "Primary DC"}.NodeName
    {
        
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        File ADFiles
        {
            DestinationPath = 'C:\NTDS'
            Type = 'Directory'
            Ensure = 'Present'
        }
        
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        WindowsFeature ADDSTools
        {
            Ensure='Present'
            Name = 'RSAT-ADDS'
        }

        xADDomain FirstDomain
        {
            DomainName = "MCSADOMAIN.local"
            DomainNETBIOSName = "MCSADOMAIN"
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'    
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

    }#Node

}#Config Closing

#AD Config

$ADConfig = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            Role = "Primary DC"
            DomainName = "MCSADOMAIN.local"
            RetryCount = 20
            RetryIntervalSec = 30
            PsDscAllowPlainTextPassword = $true
        }

    )
}

NewDomain -ConfigurationData $ADConfig `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName MCSADOMAIN\administrator `
        -Message "New Domain Admin Credential") `



Set-DscLocalConfigurationManager -Path .\NewDomain -Verbose -Force

#Build your domain
Start-DscConfiguration -Wait -Force -Path .\NewDomain -Verbose