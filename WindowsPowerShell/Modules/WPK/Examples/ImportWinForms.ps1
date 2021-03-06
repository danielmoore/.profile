Measure-Command {
$controls = [windows.Forms.Control].Assembly.GetTypes() | ? {
    $_.IsPublic -and
    (-not $_.IsAbstract) -and 
    $_.Fullname -notlike "*Internal*" -and (
    $_.IsSubClassOf([windows.Forms.Control]) -or
    $_.IsSubclassOf([Windows.Forms.CommonDialog])
    ) -and
    (-not (Get-Command -Name "New-$($_.Name)" -ErrorAction SilentlyContinue))
} 

$winforms = $controls | ConvertFrom-TypeToScriptCmdlet -ErrorAction SilentlyContinue
. ([ScriptBLock]::Create($winForms))

}
