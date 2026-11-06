# Release the configs with a calendar version YYYY.MM.N (N counts releases within the month):
# writes VERSION, commits it and tags v<version>. The Indie Image Sensor Evaluation app shows this
# version next to each sensor.
#   powershell -ExecutionPolicy Bypass -File release.ps1         # tag the next version locally
#   powershell -ExecutionPolicy Bypass -File release.ps1 -Push   # and push the commit and tag
# Same as release.sh.
param([switch]$Push)
$ErrorActionPreference = "Continue"   # git writes progress to stderr; failures are checked via $LASTEXITCODE
Set-Location $PSScriptRoot

if (git status --porcelain) { throw "Commit or stash your changes first." }
git fetch -q --tags origin
if ($LASTEXITCODE) { Write-Warning "Could not fetch tags; numbering from local tags." }

$month = Get-Date -Format "yyyy.MM"
$numbers = @(git tag -l "v$month.*" | ForEach-Object { [int]($_ -replace "^v$([regex]::Escape($month))\.", "") })
$next = if ($numbers.Count) { ($numbers | Measure-Object -Maximum).Maximum + 1 } else { 0 }
$version = "$month.$next"

[IO.File]::WriteAllText((Join-Path $PSScriptRoot "VERSION"), "$version`n")   # UTF-8 without BOM, LF
git add VERSION
git commit -qm "Release $version"
if ($LASTEXITCODE) { throw "git commit failed" }
git tag "v$version"
if ($LASTEXITCODE) { throw "git tag failed" }
Write-Host "Tagged v$version" -ForegroundColor Green
if ($Push) {
    git push origin HEAD "v$version"
    if ($LASTEXITCODE) { throw "git push failed" }
}
