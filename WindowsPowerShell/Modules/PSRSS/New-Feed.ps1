function New-Feed
{
    <#
    .Synopsis
    Subscribes to an RSS feed.

    .Description
    The New-Feed function creates a new subscription to an RSS feed.
    By default, it downloads the articles in the feed, but you can use the DoNotDownload parameter
     to prevent the download. The new feed appears immediately in your Web browser.

    .Parameter Name
    [Required] Enter a name for the RSS subscription. You can enter any name.
    The name does not have to be related to the actual blog name.
    For details, see "Valid Feed and Folder Names" in MSDN (http://msdn.microsoft.com/en-us/library/ms686419(VS.85).aspx.)

    .Parameter Url
    [Required] Enter the URL for the RSS feed (not the URL for the blog).

    .Parameter DoNotDownload
    Does not automatically download articles when the subscription is created.
    This parameter does not prevent the feed from downloading articles after the subscription is created.

    .Notes
    The New-Feed function is exported by the PSRSS module. For more information, see about_PSRSS_Module.

    The New-Feed function uses the CreateFeed method of the Microsoft.FeedsManager COM object.

    .Example
    New-Feed –name "Windows PowerShell Blog" –url http://blogs.msdn.com/powershell/rss.xml

    .Example
    #Get-PowerShellBlog.ps1
    New-Feed "Windows PowerShell Blog" http://blogs.msdn.com/powershell/rss.xml

    .Link
    about_PSRSS_Module

    .Link
    Remove-Feed

    .Link
    "Windows RSS Platform" in MSDN
    http://msdn.microsoft.com/en-us/library/ms684701(VS.85).aspx

    .Link
    "Microsoft.FeedsManager Object" in MSDN
    http://msdn.microsoft.com/en-us/library/ms684749(VS.85).aspx

    #>

    param(
        # The Name of the Feed
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        # The url to the feed
        [Parameter(Mandatory=$true)]
        [Uri]
        $Url,
        # If set, will not download the articles automatically
        [Switch]
        $DoNotDownload
    )
    
    process {
        $feedsManager = New-Object -ComObject Microsoft.FeedsManager
        $result = $feedsManager.GetFolder("").CreateFeed(
            $Name,
            $Url
        )
        if (-not $DoNotDownload) {
            if ($result) {
                $result.Download()
            }
        }
        $result
    }
}
