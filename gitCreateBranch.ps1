param(
    [Parameter(Mandatory)] $targetBranch,
    $sourceBranch = '',
    $remoteName = 'origin',
    [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

RunWithStashedChanges {
    $currentBranch = GetCurrentBranch
    Write-Host "current branch is $currentBranch"

    if ($currentBranch -eq $targetBranch) {
        Write-Warning "branch $targetBranch is already created"
        return
    }

    if ($sourceBranch -and ($currentBranch -ne $sourceBranch)) {
        CheckOutBranch $sourceBranch
    }

    RunGit checkout -b $targetBranch
    RunGit push -u $remoteName $targetBranch
    if ($returnToCurrentBranch) {
        CheckOutBranch $currentBranch
    }
}
