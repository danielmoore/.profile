Function Import-IniFile
{
    <#
    .Synopsis
        Imports settings from an Ini file
    .Description
        Imports settings from an Ini file.
        Returns an object with a property for each section in the INI file
    .Example
        Import-IniFile "$env:UserProfile\appdata\Local\Microsoft\Windows Sidebar\Settings.ini"
    #>
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]
    $File
    )
    
    process {
        $Object = New-Object PSObject
        $CurrentSection = $null
        Get-Content $File | 
            ForEach-Object {
                if ($_ -like "[[]*[]]") {
                    $line = $_.Trim(" []") 
                    $Object | 
                        Add-Member NoteProperty $line (New-Object PSObject)
                    $CurrentSection = $Object.$Line
                } elseif ($_ -like "*=*" -and $CurrentSection) {
                    $str = $_.Trim()
                    if ($str.IndexOf("=") -eq -1) { return } 
                    $property = $str.Substring(0, $str.IndexOf("=")).Trim()
                    $value = $str.Substring($str.IndexOf("=") + 1).Trim()
                    $CurrentSection | 
                        Add-Member NoteProperty $Property $Value
                }
            } 
        $Object
    }
}
