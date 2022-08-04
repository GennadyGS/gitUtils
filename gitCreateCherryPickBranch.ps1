param(
    [Parameter(Mandatory=$true)] $toTargetBranchName,
    $fromTargetBranchName = "master",
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

if ($sourceBranchName -eq $toTargetBranchName) {
    "branch $toTargetBranchName is already created"
    exit
}
if ($currentBranch -ne $sourceBranchName) {
    RunGit "checkout $sourceBranchName"
}

. $PsScriptRoot\gitRecreateBranch.ps1 $toTargetBranchName

$newBranchName = "$sourceBranchName-to-$toTargetBranchName"

RunGit "checkout -b $newBranchName"

git cherry-pick --abort
RunGit "cherry-pick $remoteName/$fromTargetBranchName..$sourceBranchName"

RunGit "push -u $remoteName $newBranchName"

if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
