param(
    [Parameter(Mandatory=$true)] $targetBranchName,
    $sourceBranchName = '',
    $remoteName = 'origin',
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$changesShashed = CheckGitStash
$currentBranch = GetCurrentBranch
"current branch is $currentBranch"
if ($currentBranch -eq $targetBranchName) {
    "branch $targetBranchName is already created"    
    exit   
}
if ($sourceBranchName -and ($currentBranch -ne $sourceBranchName)) {
    RunGit "checkout $sourceBranchName"
}
RunGit "checkout -b $targetBranchName"
RunGit "push -u $remoteName $targetBranchName"
if ($returnToCurrentBranch) {
    RunGit "checkout $currentBranch"
}
if ($changesShashed) {
    RunGit "stash pop"
}
