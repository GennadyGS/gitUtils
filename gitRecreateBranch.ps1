param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    $remoteName = 'origin'
)

. $PSScriptRoot/gitUtils.ps1

Invoke-Expression "git branch -d $targetBranchName"
RunGit "checkout $targetBranchName"
