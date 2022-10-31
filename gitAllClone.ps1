param (
    [parameter(mandatory=$true, position=0)][string]$fileName,
    [parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$remainingArgs
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $fileName `
    | ? { $_ } `
    | % { RunGit "clone $_ $remainingArgs" }