param (
    $remoteName = "origin"
)

. $PSScriptRoot/gitUtils.ps1

If (!(Test-Path ".\$gitDirectoryName")) {
    Get-ChildItem -Directory `
        | ? {Test-Path "$_\$gitDirectoryName"} `
        | % {
            Push-Location $_
            git config --get remote.$remoteName.url
            Pop-Location
        }
}
