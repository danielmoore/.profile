#requires -version 2.0
function New-ScriptCmdlet
{
    <#
    .Synopsis
        Creates a new script cmdlet
    .Description
        Creates a new script cmdlet automatically
    .Example
        New-ScriptCmdlet New-FooBar        
    .Example
        New-ScriptCmdlet -Name Start-ProcessAsAdministrator -FromCommand (Get-Command Start-Process) -RemoveParameter Verb -ProcessBlock {  
            $null = $psBoundParameters.Verb = "RunAs"
            Start-Process @psBoundParameters
        }
    .Example
        New-ScriptCmdlet -Name -FromCommand (Get-Command Get-Process) -RemoveParameter Verb
    .Example
        New-ScriptCmdlet -Name Get-Process -ProxyCommand (Get-Command Get-Process)
    .Parameter ProxyCommand
        The command to create a proxy of
    .Parameter Name
        The name of the script cmdlet to create
    .Parameter ParameterBlock
        The parameter block in a manually written script cmdlet
    .Parameter FromCommand
        The command the script cmdlet should mimic.
        The parameters of this command will be used as a template for the script cmdlet
    .Parameter AdditionalParameter
        Any additional parameters added to the command
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param(    
    [Parameter(Mandatory=$true,
        ParameterSetName="ProxyCommand",
        ValueFromPipeline=$true,
        Position=1)]
    [Management.Automation.CommandInfo]
    [Alias('Proxy')]
    $ProxyCommand,

    [Parameter(Mandatory=$true,Position=0)]
    [String]
    $Name,
    
    [Parameter(ParameterSetName="Name")]
    [String]
    $ParameterBlock,
    
    [Parameter(ParameterSetName="FromCommand", Mandatory=$true)]
    [Management.Automation.CommandInfo]
    $FromCommand,
    
    [Parameter(ParameterSetName="FromCommand")]
    [Management.Automation.ParameterMetaData[]]
    $AdditionalParameter,
    
    [Parameter(ParameterSetName="FromCommand")]
    [Parameter(ParameterSetName="ProxyCommand")]
    [string[]]
    $RemoveParameter,
    
    [Parameter(ParameterSetName="Name")]
    [Parameter(ParameterSetName="FromCommand")]
    [String]
    $BeginBlock,
    
    [Parameter(ParameterSetName="Name")]
    [Parameter(ParameterSetName="FromCommand")]
    [String]
    $ProcessBlock,
    
    [Parameter(ParameterSetName="Name")]
    [Parameter(ParameterSetName="FromCommand")]
    [string]
    $EndBlock,
    
    [Parameter(ParameterSetName="Name")]
    [Parameter(ParameterSetName="FromCommand")]
    [String]
    $HelpBlock
    )

    Process
    {
        Switch ($psCmdlet.ParameterSetName) {
            Name {[ScriptBlock]::Create("
function $name {
    $HelpBlock
    param(
        $ParameterBlock
    )
    begin {
        $BeginBlock
    }
    process {
        $ProcessBlock
    }
    end {
        $EndBlock
    }
}") 
            }
            ProxyCommand {
                $MetaData = New-Object Management.Automation.CommandMetaData $ProxyCommand
                foreach ($rp in $removeParameter) {
                    if (-not $rp) { continue }
                    $null = $MetaData.Parameters.Remove($rp)
                }
                foreach ($ap in $additionalParameter) {
                    if (-not $ap) { continue }
                    $null = $MetaData.Parameters.Add($ap.Name, $ap)
                }
                [ScriptBlock]::Create("
function $Name {
    $([Management.Automation.ProxyCommand]::Create($MetaData))
}")
            }
            FromCommand {
                $MetaData = New-Object Management.Automation.CommandMetaData $FromCommand
                foreach ($rp in $removeParameter) {
                    if (-not $rp) { continue }
                    $null = $MetaData.Parameters.Remove($rp)
                }
                foreach ($ap in $additionalParameter) {
                    if (-not $ap) { continue }
                    $null = $MetaData.Parameters.Add($ap.Name, $ap)
                }
                [ScriptBlock]::Create("
function $Name {
    $HelpBlock
    $([Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($metaData))
    param(
        $([Management.Automation.ProxyCommand]::GetParamBlock($metaData))
    )
    
    begin {
        $BeginBlock
    }
    process {
        $ProcessBlock
    }
    end {
        $EndBlock
    }
}")
            }
        }
    }
}
