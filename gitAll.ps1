. $PSScriptRoot/gitUtils.ps1

$argsStr="$args"
$gitDirectoryName = ".git"
If (!(Test-Path ".\$gitDirectoryName")) {
    Get-ChildItem -Directory `
        | ? {Test-Path "$_\$gitDirectoryName"} `
        | % {
            Write-Host "$_>" -NoNewLine -ForegroundColor darkYellow
            Push-Location $_
            RunGit $argsStr
            Pop-Location
            Write-Host ""
        }
} Else {
    RunGit $argsStr
}
