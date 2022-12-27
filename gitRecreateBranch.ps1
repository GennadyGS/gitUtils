param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    [switch] $deleteCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch

if ($currentBranch -eq $targetBranchName) {
    Write-Host "Already on branch $targetBranchName"
    Return
}

git branch -d $targetBranchName
RunGit "checkout $targetBranchName"

if ($deleteCurrentBranch) {
    git branch -d $currentBranch
}