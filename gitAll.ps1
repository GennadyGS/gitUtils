[CmdletBinding(PositionalBinding = $false)]
param (
    [Parameter(ValueFromRemainingArguments)] [string[]] $GitArgs,
    [int] $RetryCount,
    [switch] $Silent
)

. $PSScriptRoot/gitUtils.ps1

$arguments = $GitArgs
if (!(IsInsideWorkTree)) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        RunGit @arguments -Silent:$Silent -RetryCount $RetryCount
        Pop-Location
    }
} else {
    RunGit @arguments -Silent:$Silent -RetryCount $RetryCount
}
