Configuration ConfigureWebsite
{
  param ($MachineName)
  Node $MachineName
  {
    ### IIS 
    WindowsFeature IIS
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    ### ASP.NET 4.5
    WindowsFeature AspNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    ### Management Service
    WindowsFeature ManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    } 
  }
}