param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    $remoteName = "origin",
    [switch] $deleteCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch

if ($currentBranch -eq $targetBranchName) {
    Write-Host "Already on branch $targetBranchName"
    Return
}

RunGit "checkout -B $targetBranchName $remoteName/$targetBranchName"

if ($deleteCurrentBranch) {
    git branch -d $currentBranch
}