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

$commits = RunGit "log $fromTargetBranchName..$sourceBranchName"
if (!($commits)) {
    $fromTargetRef = "$fromTargetBranchName~1"
}
else {
    $fromTargetRef = $fromTargetBranchName
}

RunGit "cherry-pick $fromTargetRef..$sourceBranchName"

RunGit "push -u $remoteName $newBranchName"

if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
