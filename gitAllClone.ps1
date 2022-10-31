param (
    [Parameter(mandatory=$true)] $fileName
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $fileName `
    | % { RunGit "clone $_ $args" }