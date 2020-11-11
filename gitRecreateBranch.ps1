param(
    [Parameter(Mandatory=$true)] $targetBranchName
)

. $PSScriptRoot/gitUtils.ps1

git branch -d $targetBranchName
RunGit "checkout $targetBranchName"
