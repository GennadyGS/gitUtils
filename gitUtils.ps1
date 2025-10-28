$commandColor = "yellow"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

function Retry-Block {
    param(
        [Parameter(Mandatory=$true)][ScriptBlock] $ScriptBlock,
        [int] $Attempts,
        [int] $DelaySeconds = 3
    )
    $establishedAttempts = [Math]::Max($Attempts, 1)
    for ($i = 1; $i -le $establishedAttempts; $i++) {
        try {
            & $ScriptBlock
            return
        } catch {
            if ($i -ge $establishedAttempts) {
                throw $_
            } else {
                Write-Warning (
                    "Attempt $i failed: $($_.Exception.Message). " +
                    "Retrying in $DelaySeconds second(s)...")
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }
}

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
        [Parameter(Mandatory=$true)] $GitArgsStr,
        [switch] $NoLog,
        [switch] $Silent,
        [switch] $Retry
    )

    if (!$NoLog) {
        Write-Host "git $GitArgsStr" -ForegroundColor $commandColor
    }

    Retry-Block {
        Invoke-Expression "git $GitArgsStr"
        if (!$Silent -and $LastExitCode -ne 0) {
            throw "'git $GitArgsStr' returned code $LastExitCode"
        }
    } -Attempts ($Retry ? 3 : 1)
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

Function CheckoutBranch([Parameter(Mandatory=$true)] $branchName, $startPoint, $params) {
    $paramsArg = $params ? "$params " : "";
    $startPointArg = $startPoint ? " $startPoint" : "";
    $command = "checkout $paramsArg$branchName$startPointArg"
    RunGit $command
    RunGit "submodule update"
}
