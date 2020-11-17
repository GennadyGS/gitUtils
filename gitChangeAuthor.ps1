param (
    [Parameter(mandatory=$true)]$oldEmail,
    [Parameter(mandatory=$true)]$newName,
    [Parameter(mandatory=$true)]$newEmail,
    $remoteName = "origin"
)

. $PSScriptRoot/gitUtils.ps1

$currentBranch = GetCurrentBranch
$currentBranch
$confirmation = Read-Host "Are you sure to rewrite history for branch $($currentBranch)?"
if ($confirmation -ne 'Y') { Exit }

$filter =
    "if [ `"`$GIT_COMMITTER_EMAIL`" = `"$oldEmail`" ]; " +
    "then " + 
    "        GIT_COMMITTER_NAME='$newName'; " +
    "        GIT_AUTHOR_NAME='$newName'; " + 
    "        GIT_COMMITTER_EMAIL='$newEmail'; " + 
    "        GIT_AUTHOR_EMAIL='$newEmail'; " +
    "        git commit-tree `"$@`"; " + 
    "else " +
    "        git commit-tree `"$@`"; " +
    "fi"

$Env:FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch --commit-filter $filter HEAD

$confirmation = Read-Host "Do you want to push changes?"
if ($confirmation -ne 'Y') { Exit }
RunGit "push -u --force $remoteName $currentBranch"

$confirmation = Read-Host "Do you want to remove backup reference?"
if ($confirmation -ne 'Y') { Exit }
RunGit "update-ref -d refs/original/refs/heads/$currentBranch"
