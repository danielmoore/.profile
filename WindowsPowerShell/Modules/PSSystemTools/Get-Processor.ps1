Function Get-Processor
{
    <#
    .Synopsis
    Gets processor information for local and remote computers.

    .Description
    The Get-Processor function gets information about the processors
    on local and remote computers, including the processor architecture.

    .Parameter Computer
    Enter the names of the local and remote computers. The default
    is the local computer ("localhost")

    .Notes
    This function uses the Win32_Processor WMI class. It adds a 
    NoteProperty named "Architecture" that contains the name of
    the processor architecture to every output object.

    .Outputs
    Get-Processor returns a System.Management.ManagementObject#root\cimv2\Win32_Processor
    object with the Architecture note property for every processor.

    .Example
    Get-Processor

    .Example
    Get-Processor –computer localhost, Server01, Server02

    .Example
    C:\PS> (Get-Processor).architecture
    x86

    #>
    param($Computer = "localhost")

    Function Get-Architecture {
        switch ($args) 
        {
            0 {"X86"}
    	   1 {"MIPS"}
    	   2 {"Alpha"}
    	   3 {"PowerPC"}
    	   6 {"Intel Itanium"}
    	   9 {"X64"}
    	   default {"unable to determine processor type"}
        }
    }

    
    Get-WmiObject -Class win32_processor -ComputerName $Computer | 
        ForEach-Object {
            $_ | Add-Member NoteProperty Architecture -Force -PassThru `
                (Get-Architecture $_.Architecture)
        }
}
