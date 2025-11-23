param(
  [Parameter(Mandatory, Position = 0)]
  [string] $fileName,

  [Parameter(Position = 1, ValueFromRemainingArguments)]
  [string[]] $remainingArgs
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $fileName `
    | ? { $_ } `
    | % { RunGit clone $_ @remainingArgs }
