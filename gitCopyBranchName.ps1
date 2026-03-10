. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch
Set-Clipboard $currentBranch

Write-Host "Current branch name '$currentBranch' has been copied to clipboard." -ForegroundColor green