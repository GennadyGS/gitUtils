param(
    [Parameter(Mandatory)] $toTargetBranch,
    $fromTargetBranch = "master",
    $sourceBranch,
    $remoteName = "origin",
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch
Write-Host "current branch is $currentBranch"

if (!$sourceBranch) {
    $sourceBranch = $currentBranch
}

if ($sourceBranch -eq $toTargetBranch) {
    Write-Warning "branch $toTargetBranch is already created"
    exit
}
if ($currentBranch -ne $sourceBranch) {
    CheckOutBranch $sourceBranch
}

. $PsScriptRoot\gitRecreateBranch.ps1 $toTargetBranch

$newBranchName = "$sourceBranch-to-$toTargetBranch"

RunGit checkout -b $newBranchName

RunGit cherry-pick --abort -Silent

$commits = RunGit log $fromTargetBranch..$sourceBranch
if (!($commits)) {
    $fromTargetRef = "$fromTargetBranch~1"
}
else {
    $fromTargetRef = $fromTargetBranch
}

RunGit cherry-pick $fromTargetRef..$sourceBranch --no-merges

RunGit push -u $remoteName $newBranchName

if ($returnToCurrentBranch) {
    CheckOutBranch $currentBranch
}
