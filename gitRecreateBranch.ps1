param(
    [Parameter(Mandatory)] $targetBranch,
    $remoteName = "origin",
    [Alias("d")] [switch] $deleteCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch

if ($currentBranch -eq $targetBranch) {
    Write-Host "Already on branch $targetBranch"
    Return
}

SwitchBranch $targetBranch "$remoteName/$targetBranch"

if ($deleteCurrentBranch) {
    git branch -d $currentBranch
}
