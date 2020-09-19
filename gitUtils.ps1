Function RunGit {
    param ([Parameter(Mandatory=$true)] $gitArgsStr)

    Write-Host "git $gitArgsStr" -ForegroundColor yellow

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
    param ([Parameter(Mandatory=$true)] $remoteName = "origin")
    return RunGit "config --get remote.$remoteName.url"
}

Function GetWorkItems {
    param (
        [Parameter(Mandatory=$true)] $targetBranchName,
        [Parameter(Mandatory=$true)] $sourceBranchName
    )
    RunGit "log --oneline $targetBranchName..$sourceBranchName" `
        | % { [regex]::match($_, "#(\d+)").Groups[1].Value } `
        | ? { $_ } `
        | Sort-Object -Unique
}
