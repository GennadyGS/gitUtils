param(
    [Parameter(Mandatory=$true)] $toTargetBranchName,
    $fromTargetBranchName = "master",
    $sourceBranch,
    $remoteName = "origin",
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

CheckGitStash | Out-Null

$currentBranch = GetCurrentBranch
"current branch is $currentBranch"

if (!$sourceBranch) {
    $sourceBranch = $currentBranch
}

if ($sourceBranch -eq $toTargetBranchName) {
    "branch $toTargetBranchName is already created"
    exit
}
if ($currentBranch -ne $sourceBranch) {
    RunGit "checkout $sourceBranch"
}

. $PsScriptRoot\gitRecreateBranch.ps1 $toTargetBranchName

$newBranchName = "$sourceBranch-to-$toTargetBranchName"

RunGit "checkout -b $newBranchName"

git cherry-pick --abort

$commits = RunGit "log $fromTargetBranchName..$sourceBranch"
if (!($commits)) {
    $fromTargetRef = "$fromTargetBranchName~1"
}
else {
    $fromTargetRef = $fromTargetBranchName
}

RunGit "cherry-pick $fromTargetRef..$sourceBranch"

RunGit "push -u $remoteName $newBranchName"

if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
