param(
    [Parameter(Mandatory)] [string] $BranchName,
    $RemoteName = "origin"
)

. $PSScriptRoot/gitUtils.ps1

RunGit fetch $RemoteName "$($BranchName):refs/heads/$BranchName"
