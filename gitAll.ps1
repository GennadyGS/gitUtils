[CmdletBinding(PositionalBinding = $false)]
param (
    [Parameter(ValueFromRemainingArguments)] [object[]] $GitArgs = @(),
    [int] $RetryCount,
    [switch] $Silent,
    [switch] $NoLog
)

. $PSScriptRoot/gitUtils.ps1

$arguments = $GitArgs
if (!(IsInsideWorkTree)) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        RunGit @arguments -RetryCount $RetryCount -Silent:$Silent -NoLog:$NoLog
        Pop-Location
    }
} else {
    RunGit @arguments -RetryCount $RetryCount -Silent:$Silent -NoLog:$NoLog
}
