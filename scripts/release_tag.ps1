# Usage: ./release_tag.ps1 -Version 1.2.3 -Flavor cn
param(
  [Parameter(Mandatory=$true)][string]$Version,
  [Parameter(Mandatory=$true)][ValidateSet('cn','intl')][string]$Flavor
)

$tag = "v$Version+$Flavor"

git status --porcelain | ForEach-Object {
  if ($_ -ne $null -and $_.Trim().Length -gt 0) {
    Write-Error "Working tree not clean. Please commit or stash changes first."
    exit 1
  }
}

Write-Host "Creating tag $tag"

git tag $tag
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git push origin $tag
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Pushed tag $tag"
