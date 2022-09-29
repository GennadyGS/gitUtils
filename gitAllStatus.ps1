param (
    $remoteName = "origin",
    $branchName = "master"
)

. $PSScriptRoot/gitUtils.ps1

$untouchedMessage = "On branch $branchName Your branch is up to date with '$remoteName/$branchName'.  nothing to commit, working tree clean"

$gitDirectoryName = ".git"
If (!(Test-Path ".\$gitDirectoryName")) {
    Get-ChildItem -Directory `
        | ? {Test-Path "$_\$gitDirectoryName"} `
        | % {
            Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
            Push-Location $_
            $result = RunGit status
            if (!(([string]$result).Contains($untouchedMessage))) {
                RunGit status
            }
            Pop-Location
            Write-Output ""
        }
} Else {
    RunGit status
}
