param (
    [Parameter(mandatory=$true)] $fileName
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $fileName `
    | ? { $_ } `
    | % { RunGit "clone $_ $args" }