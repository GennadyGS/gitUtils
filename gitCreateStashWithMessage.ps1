param(
    [Parameter(Mandatory)] [string] $Message
)

. $PSScriptRoot/gitUtils.ps1

$commit = RunGit stash create
RunGit stash store -m $Message $commit