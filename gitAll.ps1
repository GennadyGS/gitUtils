param (
    [switch] $Silent,
    [switch] $Retry
)

. $PSScriptRoot/gitUtils.ps1

$arguments = $args
if (!(IsInsideWorkTree)) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        RunGit @arguments -Silent:$Silent -Retry:$Retry
        Pop-Location
    }
} else {
    RunGit @arguments -Silent:$Silent -Retry:$Retry
}
