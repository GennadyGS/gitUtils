param(
    [Parameter(Mandatory)] $targetBranch,
    $sourceBranch = '',
    $remoteName = 'origin',
    [Alias("f")] [switch] $force,
    [Alias("r")] [switch] $returnToCurrentBranch
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch
"force: $force"
Write-Host "current branch is $currentBranch"

if ($currentBranch -eq $targetBranch -and -not $force) {
    Write-Warning "branch $targetBranch is already created"
    return
}

if ($sourceBranch -and ($currentBranch -ne $sourceBranch)) {
    CheckOutBranch $sourceBranch
}

$flag = $force ? "-B" : "-b"
RunGit checkout $flag $targetBranch
$pushArgs = @('push', '-u', $remoteName, $targetBranch) + ($force ? @('-f') : @())
RunGit @pushArgs
if ($returnToCurrentBranch) {
    CheckOutBranch $currentBranch
}
