param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    $sourceBranchName,
    $remoteName = "origin",
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

CheckGitStash | Out-Null

$currentBranch = GetCurrentBranch
"current branch is $currentBranch"

if (!$sourceBranchName) {
    $sourceBranchName = $currentBranch
}

if ($sourceBranchName -eq $targetBranchName) {
    "branch $targetBranchName is already created"
    exit
}
if ($currentBranch -ne $sourceBranchName) {
    RunGit "checkout $sourceBranchName"
}

. $PsScriptRoot\gitRecreateBranch.ps1 $targetBranchName

$newBranchName = "$sourceBranchName-to-$targetBranchName"

RunGit "checkout -b $newBranchName"

git cherry-pick --abort
RunGit "cherry-pick $sourceBranchName"

RunGit "push -u $remoteName $newBranchName"

if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
