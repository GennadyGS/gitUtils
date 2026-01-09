param (
    [string[]] $mainBranchNames = @(),
    $remoteName = "origin"
)

. $PSScriptRoot/gitUtils.ps1

$wellKnownMainBranchNames = @("main", "master")
$mainBranchNamesFileName = "mainBranchNames.txt"

$establishedMainBranchNames = $wellKnownMainBranchNames + $mainBranchNames
if (Test-Path $mainBranchNamesFileName) {
    $establishedMainBranchNames += Get-Content $mainBranchNamesFileName
}

Function IsUntouchedMessage() {
    param([string] $message)

    foreach ($mainBranchName in $establishedMainBranchNames) {
        $untouchedMessage =
        "On branch $mainBranchName Your branch is up to date with '$remoteName/$mainBranchName'.  " `
        + "nothing to commit, working tree clean"
        if ($message.Contains($untouchedMessage)) {
            return $true
        }
    }
    return $false
}

if (!(Test-Path ".\$gitDirectoryName")) {
    Get-ChildItem -Directory `
    | Where-Object { Test-Path "$_\$gitDirectoryName" } `
    | ForEach-Object {
        Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
        Push-Location $_
        $result = RunGit status
        if (!(IsUntouchedMessage($result))) {
            RunGit status
        }
        Pop-Location
    }
} else {
    RunGit status
}
