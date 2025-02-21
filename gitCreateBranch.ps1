param(
    [Parameter(Mandatory=$true)] $targetBranch,
    $sourceBranch = '',
    $remoteName = 'origin',
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$changesShashed = CheckGitStash
$currentBranch = GetCurrentBranch
"current branch is $currentBranch"
if ($currentBranch -eq $targetBranch) {
    "branch $targetBranch is already created"
    exit
}
if ($sourceBranch -and ($currentBranch -ne $sourceBranch)) {
    RunGit "checkout $sourceBranch"
}
RunGit "checkout -b $targetBranch"
RunGit "push -u $remoteName $targetBranch"
if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
if ($changesShashed) {
    RunGit "stash pop"
}
