[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory, Position = 0)] [string] $Command,
    [Parameter(ValueFromRemainingArguments)] [string[]] $CommandArgs,
    [string] $BadCommit = "HEAD",
    [string] $GoodCommit = "stable",
    [switch] $FirstParent
)

. $PSScriptRoot/gitUtils.ps1

RunGit bisect start $BadCommit $GoodCommit $($FirstParent ? '--first-parent' : '')
git bisect run pwsh -Command $PSScriptRoot/PwshCommandRunner.ps1 $PWD $Command @CommandArgs
RunGit bisect log
RunGit --no-pager bisect visualize --oneline
