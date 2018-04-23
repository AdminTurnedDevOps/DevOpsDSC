#** Install modules if you haven't done so already **
#Install-Module xPSDesiredStateConfiguration -force
#Install-Module -Name xWebAdministration -force

Import-Module xPSDesiredStateConfiguration -force
Import-module xWebAdministration -force
#Ensure you are in the directory of where your DSC config will be
Set-Location C:\DSCConfig

Configuration NewIISConfig 
{
    Param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$ComputerName,

        [string]$WebsiteName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    Node $ComputerName 
    {
        WindowsFeature IIS 
        {
            Ensure = "Present"
            Name   = "Web-Server"
        }#Feature1

        WindowsFeature AspNet45 
        {
            Ensure = 'Present'
            Name   = "Web-Asp-Net45"
        }#Feature2

        
        xWebsite DefaultSite
        {
            Ensure       = 'Present'
            Name         = $WebsiteName
            State        = 'Started'
            PhysicalPath = 'C:\inetpub\wwwroot'
            DependsOn    = "[WindowsFeature]IIS"
        }#DefaultWebsiteConfig

    }
}#Config
NewIISConfig

Set-DscLocalConfigurationManager -ComputerName $ComputerName -Path C:\DSCConfig\NewIISConfig -Verbose -Force
Start-DscConfiguration -ComputerName $ComputerName -Path C:\DSCConfig\NewIISConfig -Verbose -Wait -Force
