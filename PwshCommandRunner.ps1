param(
    [string] $WorkingDir,
    [string] $Command
)

try {
    Write-Host "Running command '$Command' in working directory '$WorkingDir'"
    Push-Location $WorkingDir
    $global:LastExitCode = 0
    & pwsh -Command $Command @args
    Pop-Location
    exit $global:LastExitCode
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    exit 125
}