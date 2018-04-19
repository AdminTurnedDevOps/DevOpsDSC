Configuration ScheduleWinUpdateInstallDSC
{
    Import-DscResource -ModuleName xWindowsUpdate

    Node localhost
    {
    
        xWindowsUpdateAgent MuSecurityImportant
        {
            
        IsSingleInstance = 'Yes'
        UpdateNow        = $false
        Category         = @('Security,Important')
        Source           = 'WindowsUpdate'
        Notifications    = 'ScheduledInstallation'

        }
    }
}

ScheduleWinUpdateInstallDSC
Start-DscConfiguration -ComputerName localhost -Path C:\ScheduleWinUpdateInstallDSC -Wait -Force
