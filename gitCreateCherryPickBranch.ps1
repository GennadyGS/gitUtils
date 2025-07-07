param(
    [Parameter(Mandatory=$true)] $toTargetBranch,
    $fromTargetBranch = "master",
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

if ($sourceBranch -eq $toTargetBranch) {
    "branch $toTargetBranch is already created"
    exit
}
if ($currentBranch -ne $sourceBranch) {
    CheckOutBranch $sourceBranch
}

. $PsScriptRoot\gitRecreateBranch.ps1 $toTargetBranch

$newBranchName = "$sourceBranch-to-$toTargetBranch"

RunGit "checkout -b $newBranchName"

git cherry-pick --abort

$commits = RunGit "log $fromTargetBranch..$sourceBranch"
if (!($commits)) {
    $fromTargetRef = "$fromTargetBranch~1"
}
else {
    $fromTargetRef = $fromTargetBranch
}

RunGit "cherry-pick $fromTargetRef..$sourceBranch --no-merges"

RunGit "push -u $remoteName $newBranchName"

if ($returnToCurrentBranch) {
    CheckOutBranch $currentBranch
}
