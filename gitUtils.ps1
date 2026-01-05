$highlightedColor = "white"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()

function RetryBlock {
    param(
        [Parameter(Mandatory)] [ScriptBlock] $ScriptBlock,
        [int] $RetryCount = 0,
        [int] $DelaySeconds = 3
    )
    $attemptCount = [Math]::Max($RetryCount + 1, 1)
    for ($i = 1; $i -le $attemptCount; $i++) {
        try {
            & $ScriptBlock
            return
        } catch {
            if ($i -ge $attemptCount) {
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

Function RunAndLogCommand(
    [string] $Command,
    [switch] $NoLog,
    [switch] $Silent
)
{
    if(!$NoLog) {
        Write-Host "$Command $args" -ForegroundColor $highlightedColor
    }

    & $Command @args
}

function VerifyExitCode(
    [Parameter(Mandatory)] [ScriptBlock] $ScriptBlock,
    [string] $Description,
    [switch] $Silent)
{
    $global:LastExitCode = 0
    & $ScriptBlock
    if (!$Silent -and $global:LastExitCode -ne 0) {
        throw "'$Description' returned code $global:LastExitCode"
    }
}

Function RunGit {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(ValueFromRemainingArguments)] [string[]] $GitArgs,
        [int] $RetryCount = 0,
        [switch] $NoLog,
        [switch] $Silent
    )
    $arguments = $GitArgs
    $noLog = $NoLog
    $silent = $Silent
    RetryBlock {
        VerifyExitCode {
            RunAndLogCommand git @arguments -NoLog:$noLog
        } `
        -Description ("git " + ($arguments -join ' ')) `
        -Silent:$silent
    } `
    -RetryCount $RetryCount
}

Function CheckGitStash {
    $gitStashOutput = RunGit stash
    $gitStashOutput | Write-Host
    return [bool] ($gitStashOutput | Select-String "Saved working directory")
}

Function RunWithStashedChanges(
    [Parameter(Mandatory)] [ScriptBlock] $ScriptBlock
)
{
    $changesStashed = CheckGitStash
    try {
        & $ScriptBlock
    } finally {
        if ($changesStashed) {
            RunGit stash pop
        }
    }
}

Function GetCurrentBranch {
    $gitStatus = @(RunGit status -b -noLog)[0]
    return [regex]::match($gitStatus, "On branch (.*)").Groups[1].Value
}

Function GetRemoteUrl {
    param ([Parameter(Mandatory)] $remoteName)
    return RunGit config --get remote.$remoteName.url -noLog
}

Function GetCurrentRepositoryName {
    param ([Parameter(Mandatory)] $remoteName)
    $remoteUrl = GetRemoteUrl $remoteName
    [regex]::match($remoteUrl, ".*/(.*)$").Groups[1].Value
}

Function IsInsideWorkTree {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    return ($LastExitCode -eq 0)
}

Function IsCurrentRepository {
    param (
        [Parameter(Mandatory)] $repositoryName,
        [Parameter(Mandatory)] $remoteName
    )
    if (!(IsInsideWorkTree)) { return $false }
    (GetCurrentRepositoryName $remoteName) -eq $repositoryName
}

Function GetWorkItems {
    param (
        [Parameter(Mandatory)] $targetBranch,
        [Parameter(Mandatory)] $sourceBranch
    )
    RunGit log --oneline $targetBranch..$sourceBranch --no-merges -noLog `
        | % { [regex]::match($_, "#(\d+)").Groups[1].Value } `
        | ? { $_ } `
        | Sort-Object -Unique
}

Function GetCommitMessages {
    param (
        [Parameter(Mandatory)] $targetBranch,
        [Parameter(Mandatory)] $sourceBranch
    )
    RunGit log --oneline $targetBranch..$sourceBranch --no-merges -noLog `
        | % { [regex]::match($_, "[0-9a-f]{7,12} (.*)").Groups[1].Value } `
}

Function CheckoutBranch($branchName, $startPoint) {
    $arguments = $args
    RunWithStashedChanges {
        RunGit checkout @arguments $branchName $startPoint
        RunGit submodule update
    }
}
