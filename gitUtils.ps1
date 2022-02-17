Function RunGit {
    param ([Parameter(Mandatory=$true)] $gitArgsStr)

    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "yellow"
    Write-Output "git $gitArgsStr"
    $host.ui.RawUI.ForegroundColor = $t

    Invoke-Expression "git $gitArgsStr"
    if ($LastExitCode -ne 0) {
        throw "'git $gitArgsStr' returned code $LastExitCode"
    }
}

Function CheckGitStash {
    $gitStashOutput = RunGit "stash"
    $gitStashOutput | Write-Host
    return [bool] ($gitStashOutput | Select-String "Saved working directory")
}

Function GetCurrentBranch {
    return [regex]::match((RunGit "status -b")[0], "On branch (.*)").Groups[1].Value
}

Function GetRemoteUrl {
    param ([Parameter(Mandatory=$true)] $remoteName)
    return RunGit "config --get remote.$remoteName.url"
}

Function GetWorkItems {
    param (
        [Parameter(Mandatory=$true)] $targetBranchName,
        [Parameter(Mandatory=$true)] $sourceBranchName
    )
    RunGit "log --oneline $targetBranchName..$sourceBranchName --no-merges" `
        | % { [regex]::match($_, "#(\d+)").Groups[1].Value } `
        | ? { $_ } `
        | Sort-Object -Unique
}

Function GetCommitMessages {
    param (
        [Parameter(Mandatory=$true)] $targetBranchName,
        [Parameter(Mandatory=$true)] $sourceBranchName
    )
    RunGit "log --oneline $targetBranchName..$sourceBranchName --no-merges" `
        | % { [regex]::match($_, "[0-9a-f]{9} (.*)").Groups[1].Value } `
}
