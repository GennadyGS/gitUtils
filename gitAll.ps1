param (
    [switch] $silent
)

. $PSScriptRoot/gitUtils.ps1

$argsStr = [string]$args
$gitDirectoryName = ".git"
if (!(Test-Path ".\$gitDirectoryName")) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        RunGit $argsStr -silent:$silent
        Pop-Location
    }
} else {
    RunGit $argsStr
}
