param (
    [switch] $Silent,
    [switch] $Retry
)

. $PSScriptRoot/gitUtils.ps1

$arguments = $args
if (!(Test-InGitRepo)) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        RunGit2 @arguments -Silent:$Silent -Retry:$Retry
        Pop-Location
    }
} else {
    RunGit2 @arguments -Silent:$Silent -Retry:$Retry
}
