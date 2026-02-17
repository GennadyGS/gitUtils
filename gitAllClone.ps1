param(
    [Parameter(Mandatory, Position = 0)] [string] $FileName,
    [Parameter(ValueFromRemainingArguments)] [object[]] $RemainingArgs = @(),
    [int] $RetryCount,
    [switch] $Silent,
    [switch] $NoLog
)

. $PSScriptRoot/gitUtils.ps1

Get-Content $FileName `
    | ? { $_ } `
    | % { RunGit clone $_ @RemainingArgs -RetryCount $RetryCount -Silent:$Silent -NoLog:$NoLog }
