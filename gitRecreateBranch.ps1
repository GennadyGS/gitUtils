param(
    [Parameter(Mandatory=$true)] $targetBranch,
    $remoteName = "origin",
    [Alias("d")] [switch] $deleteCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch

if ($currentBranch -eq $targetBranch) {
    Write-Host "Already on branch $targetBranch"
    Return
}

RunGit "checkout -B $targetBranch $remoteName/$targetBranch"

if ($deleteCurrentBranch) {
    git branch -d $currentBranch
}