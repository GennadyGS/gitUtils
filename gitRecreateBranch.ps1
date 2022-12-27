param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    [switch] $deleteCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch

git branch -d $targetBranchName
RunGit "checkout $targetBranchName"

if ($deleteCurrentBranch) {
    git branch -d $currentBranch
}