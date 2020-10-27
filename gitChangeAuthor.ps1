param (
    [Parameter(mandatory=$true)]$oldEmail,
    [Parameter(mandatory=$true)]$newName,
    [Parameter(mandatory=$true)]$newEmail
)

. $PSScriptRoot/gitUtils.ps1

$confirmation = Read-Host "Are you sure to rewrite history for repository $remoteUrl ?"
if ($confirmation -ne 'Y') { Exit }

$filter =
    "if [ `"`$GIT_COMMITTER_EMAIL`" = `"$oldEmail`" ]; " +
    "then " + 
    "        GIT_COMMITTER_NAME=`"$newName`"; " +
    "        GIT_AUTHOR_NAME=`"$newName`"; " + 
    "        GIT_COMMITTER_EMAIL=`"$newEmail`"; " + 
    "        GIT_AUTHOR_EMAIL=`"$newEmail`"; " +
    "        git commit-tree `"$@`"; " + 
    "else " +
    "        git commit-tree `"$@`"; " +
    "fi"
git filter-branch --commit-filter $filter HEAD

$confirmation = Read-Host "Are you sure to push changes?"
if ($confirmation -ne 'Y') { Exit }
RunGit "push -u --force origin master"
