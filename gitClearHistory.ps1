param(
    $remoteName = 'origin',
    $message = 'Initial commit'
)

. $PSScriptRoot/gitUtils.ps1

$remoteUrl = RunGit config --get remote.origin.url
if (!$remoteUrl) {
    "Not git repository"
    Exit
}

$confirmation = Read-Host "Are you sure to clear history for repository $remoteUrl ?"
if ($confirmation -ne 'Y') { Exit }
Remove-Item -Recurse -Force .git

RunGit init
RunGit add .
RunGit commit -m '$message'

RunGit remote add origin $remoteurl

$confirmation = Read-Host "Are you sure to push changes?"
if ($confirmation -ne 'Y') { Exit }
RunGit push -u --force origin master
