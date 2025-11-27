param(
    [Parameter(Mandatory)] $targetBranch,
    $sourceBranch = '',
    $remoteName = 'origin',
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$changesStashed = CheckGitStash
try {
    $currentBranch = GetCurrentBranch
    "current branch is $currentBranch"
    if ($currentBranch -eq $targetBranch) {
        "branch $targetBranch is already created"
        exit
    }
    if ($sourceBranch -and ($currentBranch -ne $sourceBranch)) {
        CheckOutBranch $sourceBranch
    }
    RunGit checkout -b $targetBranch
    RunGit push -u $remoteName $targetBranch
    if ($returnToCurrentBranch) {
        CheckOutBranch $currentBranch
    }
} finally {
    if ($changesStashed) {
        RunGit stash pop
    }
}
