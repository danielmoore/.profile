function Get-ShellVerb
{
    <#
    .Synopsis
        Gets the Shell Verbs for a given file
    .Description
        Uses the Shell.Application COM Object to retrieve the verbs that apply to a particular file
    .Example
        Get-ChildItem | Get-ShellVerb
    #>
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [Alias('FullName')]
    [string]
    $file
    )
    
    begin {
        $shell = New-Object -ComObject Shell.Application
    }
    process {
        $folder = $shell.NameSpace("$(Split-Path $file)")
        if (-not $folder) { return } 
        $verbs = $folder.ParseName("$(Split-Path $file -leaf)").Verbs() | 
            Select-Object -ExpandProperty Name        
        
        New-Object Object | 
            Add-Member NoteProperty File $file -PassThru | 
            Add-Member NoteProperty Verbs $verbs -PassThru
    }
}
