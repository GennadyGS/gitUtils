param(
  [Parameter(Mandatory, Position = 0)]
  [string] $fileName,

  [Parameter(ValueFromRemainingArguments)]
  [object[]] $remainingArgs = @()
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $fileName `
    | ? { $_ } `
    | % { RunGit clone $_ @remainingArgs }
