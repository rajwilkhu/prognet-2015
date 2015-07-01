Configuration cWebFeaturesInstaller
{
    WindowsFeature Web-AppInit { Ensure = 'Present'; Name = 'Web-AppInit' }
    WindowsFeature Web-Asp-Net45 { Ensure = 'Present'; Name = 'Web-Asp-Net45' }
    WindowsFeature Web-Server { Ensure = 'Present'; Name = 'Web-Server' }
    WindowsFeature Web-WebSockets { Ensure = 'Present'; Name = 'Web-WebSockets' }
}