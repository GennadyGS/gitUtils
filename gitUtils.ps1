Function RunGit {
    param (
        [Parameter(Mandatory=$true)] $gitArgsStr,
        [switch] $noLog
    )

    if (!$noLog) {
        $t = $host.ui.RawUI.ForegroundColor
        $host.ui.RawUI.ForegroundColor = "yellow"
        Write-Host "git $gitArgsStr"
        $host.ui.RawUI.ForegroundColor = $t
    }

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
    $gitStatus = @(RunGit "status -b" -noLog)[0]
    return [regex]::match($gitStatus, "On branch (.*)").Groups[1].Value
}

Function GetRemoteUrl {
    param ([Parameter(Mandatory=$true)] $remoteName)
    return RunGit "config --get remote.$remoteName.url" -noLog
}

Function GetCurrentRepositoryName {
    param ([Parameter(Mandatory=$true)] $remoteName)
    $remoteUrl = GetRemoteUrl $remoteName
    [regex]::match($remoteUrl, ".*/(.*)$").Groups[1].Value
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
        | % { [regex]::match($_, "[0-9a-f]{7,12} (.*)").Groups[1].Value } `
}
