$commandColor = "yellow"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Function RunAndLogCommand {
    if (!$args) {
        Throw "Command is not specified for function Run"
    }

    $commandText = [string]$args
    Write-Host $commandText -ForegroundColor $commandColor
    Invoke-Expression $commandText
}

Function RunGit {
    param (
        [Parameter(Mandatory=$true)] $gitArgsStr,
        [switch] $noLog,
        [switch] $silent
    )

    if (!$noLog) {
        Write-Host "git $gitArgsStr" -ForegroundColor $commandColor
    }

    Invoke-Expression "git $gitArgsStr"
    if (!$silent -and $LastExitCode -ne 0) {
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

Function IsInsideWorkTree {
    $output = @(Invoke-Expression "git rev-parse --is-inside-work-tree" -ErrorAction Ignore)
    ($output | Select-Object -First 1) -eq "true"
}

Function IsCurrentRepository {
    param (
        [Parameter(Mandatory=$true)] $repositoryName,
        [Parameter(Mandatory=$true)] $remoteName
    )
    if (!(IsInsideWorkTree)) { return $false }
    (GetCurrentRepositoryName $remoteName) -eq $repositoryName
}

Function GetWorkItems {
    param (
        [Parameter(Mandatory=$true)] $targetBranch,
        [Parameter(Mandatory=$true)] $sourceBranch
    )
    RunGit "log --oneline $targetBranch..$sourceBranch --no-merges" -noLog `
        | % { [regex]::match($_, "#(\d+)").Groups[1].Value } `
        | ? { $_ } `
        | Sort-Object -Unique
}

Function GetCommitMessages {
    param (
        [Parameter(Mandatory=$true)] $targetBranch,
        [Parameter(Mandatory=$true)] $sourceBranch
    )
    RunGit "log --oneline $targetBranch..$sourceBranch --no-merges" -noLog `
        | % { [regex]::match($_, "[0-9a-f]{7,12} (.*)").Groups[1].Value } `
}
