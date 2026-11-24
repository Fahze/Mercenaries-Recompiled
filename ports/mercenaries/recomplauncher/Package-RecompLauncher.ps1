# Builds the RecompLauncher release asset for this fork. The package holds
# only the manifest, the setup step, its README and the project license; the
# game is built on the player's PC from their own disc.
[CmdletBinding()]
param(
    [string]$OutputDirectory
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$here = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $here "..\..\.."))
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot "artifacts\recomplauncher" }

$manifest = Get-Content -LiteralPath (Join-Path $here "recomplauncher.json") -Raw | ConvertFrom-Json
$prepareArgs = @($manifest.prepare.args)
$refIndex = [Array]::IndexOf($prepareArgs, "-SourceRef")
if ($refIndex -lt 0 -or $refIndex + 1 -ge $prepareArgs.Count) { throw "recomplauncher.json does not pin -SourceRef." }
$sourceRef = $prepareArgs[$refIndex + 1]

$staging = Join-Path $OutputDirectory "staging"
if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
New-Item -ItemType Directory -Force -Path $staging | Out-Null
foreach ($name in @("recomplauncher.json", "Prepare.cmd", "Setup-RecompLauncher.ps1", "README.txt")) {
    Copy-Item -LiteralPath (Join-Path $here $name) -Destination $staging
}
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE") -Destination (Join-Path $staging "LICENSE.txt")

$zip = Join-Path $OutputDirectory "Mercenaries-Recompiled-USA-EU-FR-$sourceRef-RecompLauncher.zip"
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zip
Remove-Item -LiteralPath $staging -Recurse -Force
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
Write-Host "Package: $zip"
Write-Host "SHA-256: $hash"
Write-Host "Source tag the package builds: $sourceRef"
