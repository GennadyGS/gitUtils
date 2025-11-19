param(
    [Parameter(Mandatory = $true)] [string] $Message
)

. $PSScriptRoot/gitUtils.ps1

$commit = RunGit2 stash create
RunGit2 stash store -m $Message $commit