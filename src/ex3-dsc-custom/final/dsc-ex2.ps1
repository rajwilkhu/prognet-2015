configuration DscEx2
{
    param ([string[]]$computerName = 'localhost')

    Import-DscResource -Module cProgNet

    Node $computerName
    {
        File Just-Eat-Root { Type = "Directory"; DestinationPath = "C:\deployment"; Ensure = "Present"; }

        Environment Just-Eat-Env { Name = "deployment_root"; Value = "C:\deployment"; Ensure = "Present"; DependsOn = "[File]Just-Eat-Root" }

        Service Disable-WSUS { Name = "wuauserv"; State = "Stopped"; StartupType = "Disabled"; }

        cWebFeaturesInstaller Install-Web-Features { }
    }
}