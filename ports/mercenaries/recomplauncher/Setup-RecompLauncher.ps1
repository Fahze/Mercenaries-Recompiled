# Mercenaries Recompiled (USA + EU-FR) - RecompLauncher setup step.
#
# Builds the game on the player's PC from their own retail Xbox disc image,
# using the public source of this fork at a pinned tag. The package that ships
# this script contains no game code and no game data.
#
#   1. Checks (and, when the player ticked it, installs) Python 3.12 and the
#      pinned MSVC 14.44.35207 + Windows SDK 10.0.26100.0 toolchain.
#   2. Downloads the fork's source at -SourceRef.
#   3. Runs the project's own Build-From-Iso.ps1 against the disc image.
#   4. Installs the result into <InstallDir>\Game, places the extracted game
#      files where the game's launcher expects them, and keeps saves and
#      settings across updates.
#
# Progress lines ("progress <0..1> <text>") are read by RecompLauncher.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IsoPath,

    [string]$InstallDir = $PSScriptRoot,

    [string]$Repo = "Fahze/Mercenaries-Recompiled",

    [Parameter(Mandatory = $true)]
    [string]$SourceRef,

    [switch]$AcceptPythonLicense,

    [switch]$AcceptVsLicense
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$MsvcVersion = "14.44.35207"
$SdkVersion = "10.0.26100.0"
$SupportedXbe = @{
    "AA08EA21D952AC35F49C02C7E2ED08AA25AD7535FBBBCCC95636775F37BE99D7" = "USA"
    "9DD26D6CE030F467462A4A8132AC82217ECEA69ECFEF5FAB9238392642FDC356" = "EU-FR"
}

$InstallDir = [IO.Path]::GetFullPath($InstallDir)
$gameDir = Join-Path $InstallDir "Game"
$workDir = Join-Path $InstallDir "build-work"
$logPath = Join-Path $InstallDir "setup.log"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Start-Transcript -LiteralPath $logPath -Force | Out-Null

function Write-Progress-Line([double]$Fraction, [string]$Text) {
    $value = $Fraction.ToString("0.00", [Globalization.CultureInfo]::InvariantCulture)
    [Console]::Out.WriteLine("progress $value $Text")
    [Console]::Out.Flush()
}

function Stop-Setup([string]$Message, [int]$Code = 1) {
    Write-Host "ERROR: $Message"
    Write-Host "Full log: $logPath"
    Stop-Transcript | Out-Null
    exit $Code
}

function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
        [Environment]::GetEnvironmentVariable("Path", "User")
}

function Test-Python312 {
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) { return $false }
    & py -3.12 -c "import sys" 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Get-VsInstallations {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path -LiteralPath $vswhere)) { return @() }
    $paths = & $vswhere -version "[17.0,18.0)" -products * -property installationPath 2>$null
    return @($paths | Where-Object { $_ })
}

function Test-Toolchain {
    $sdk = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\Include\$SdkVersion"
    if (-not (Test-Path -LiteralPath $sdk)) { return $false }
    foreach ($vs in Get-VsInstallations) {
        if (Test-Path -LiteralPath (Join-Path $vs "VC\Tools\MSVC\$MsvcVersion\bin\Hostx64\x64\cl.exe")) {
            return $true
        }
    }
    return $false
}

function Invoke-Checked([string]$FilePath, [string[]]$Arguments, [string]$What) {
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) { Stop-Setup "$What failed (exit code $LASTEXITCODE)." }
}

Write-Host "=== Mercenaries Recompiled (USA + EU-FR) setup ==="
Write-Host "Source: $Repo @ $SourceRef"
Write-Host "Install folder: $InstallDir"

# --- Disc image ------------------------------------------------------------
if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
    Stop-Setup "Disc image not found: $IsoPath" 2
}
$IsoPath = (Resolve-Path -LiteralPath $IsoPath).Path
Write-Host "Disc image: $IsoPath"

# --- Build tools -----------------------------------------------------------
Write-Progress-Line 0.02 "Checking build tools"
if (-not (Test-Python312)) {
    if (-not $AcceptPythonLicense) {
        Stop-Setup "Python 3.12 is needed to build the game. Tick the Python option on the setup screen." 3
    }
    Write-Progress-Line 0.04 "Installing Python 3.12"
    $installer = Join-Path $env:TEMP "python-3.12.10-amd64.exe"
    Invoke-WebRequest "https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe" `
        -OutFile $installer -UseBasicParsing
    Invoke-Checked $installer @("/quiet", "InstallAllUsers=0", "Include_launcher=1",
        "InstallLauncherAllUsers=0", "PrependPath=0", "Include_test=0") "Python 3.12 installation"
    Update-SessionPath
    if (-not (Test-Python312)) { Stop-Setup "Python 3.12 is still not available through 'py -3.12'." }
}
Write-Host "Python 3.12: OK"

if (-not (Test-Toolchain)) {
    if (-not $AcceptVsLicense) {
        Stop-Setup "MSVC $MsvcVersion and Windows SDK $SdkVersion are needed. Tick the Visual Studio Build Tools option on the setup screen." 3
    }
    Write-Progress-Line 0.06 "Installing Visual Studio 2022 Build Tools (Windows asks for admin rights)"
    $components = @(
        "--add", "Microsoft.VisualStudio.Workload.VCTools",
        "--add", "Microsoft.VisualStudio.Component.VC.14.44.17.14.x86.x64",
        "--add", "Microsoft.VisualStudio.Component.Windows11SDK.26100"
    )
    $existing = @(Get-VsInstallations)
    $bootstrapper = Join-Path $env:TEMP "vs_BuildTools.exe"
    Invoke-WebRequest "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile $bootstrapper -UseBasicParsing
    if ($existing.Count -gt 0) {
        $arguments = @("modify", "--installPath", $existing[0]) + $components +
            @("--quiet", "--norestart", "--wait")
    } else {
        $arguments = $components + @("--includeRecommended", "--quiet", "--norestart", "--wait")
    }
    $process = Start-Process -FilePath $bootstrapper -ArgumentList $arguments -Wait -PassThru
    # 3010 = success, restart recommended.
    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
        Stop-Setup "Visual Studio Build Tools installation failed (exit code $($process.ExitCode))."
    }
    if (-not (Test-Toolchain)) { Stop-Setup "MSVC $MsvcVersion / Windows SDK $SdkVersion are still missing after installation." }
}
Write-Host "MSVC $MsvcVersion + Windows SDK ${SdkVersion}: OK"

# --- Source ----------------------------------------------------------------
Write-Progress-Line 0.10 "Downloading the source"
if (Test-Path -LiteralPath $workDir) { Remove-Item -LiteralPath $workDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $workDir | Out-Null
$sourceDir = Join-Path $workDir "source"
# Build-From-Iso records the git revision when git is installed, and under
# Windows PowerShell 5.1 that probe fails on a tree that is not a repository.
# Clone when git is available; the plain archive is only for PCs without git.
if (Get-Command git -ErrorAction SilentlyContinue) {
    $ErrorActionPreference = "Continue"
    & git -c advice.detachedHead=false clone --quiet --depth 1 --branch $SourceRef `
        "https://github.com/$Repo.git" $sourceDir 2>&1 | ForEach-Object { Write-Host "$_" }
    $cloneExit = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    if ($cloneExit -ne 0) { Stop-Setup "Downloading the source with git failed (exit code $cloneExit)." }
} else {
    $archive = Join-Path $workDir "source.zip"
    Invoke-WebRequest "https://codeload.github.com/$Repo/zip/refs/tags/$SourceRef" -OutFile $archive -UseBasicParsing
    Expand-Archive -LiteralPath $archive -DestinationPath $workDir
    Remove-Item -LiteralPath $archive
    $unpacked = @(Get-ChildItem -LiteralPath $workDir -Directory)[0].FullName
    Rename-Item -LiteralPath $unpacked -NewName "source"
}
$buildScript = Join-Path $sourceDir "ports\mercenaries\scripts\Build-From-Iso.ps1"
if (-not (Test-Path -LiteralPath $buildScript)) { Stop-Setup "The downloaded source is incomplete." }

# --- Build -----------------------------------------------------------------
Write-Progress-Line 0.15 "Building the game from your disc (20-40 minutes)"
$extracted = Join-Path $sourceDir "game_files\mercenaries-retail"
# Run the official pipeline in its own process. Its output is echoed through
# this host so the transcript keeps it, and a few milestones move the bar.
# Stderr is merged here only; the child never redirects its own tools, which
# is what keeps Windows PowerShell 5.1 from turning their warnings into errors.
$milestones = @(
    @{ Pattern = "^Retail default\.xbe revision"; Fraction = 0.20; Text = "Disc verified, extracting game files" },
    @{ Pattern = "^Parsing XBE metadata"; Fraction = 0.25; Text = "Analysing the game code" },
    @{ Pattern = "^Lifting functions"; Fraction = 0.40; Text = "Translating the game code to C" },
    @{ Pattern = "^Applied generated patch"; Fraction = 0.50; Text = "Applying the port's fixes" },
    # MSBuild prints the bare file name; the lifter prints full paths.
    @{ Pattern = "^recomp_0000\.c$"; Fraction = 0.60; Text = "Compiling (the longest step)" },
    @{ Pattern = "mercenaries_recomp\.vcxproj ->"; Fraction = 0.88; Text = "Finishing the build" }
)
$reached = 0.15
$ErrorActionPreference = "Continue"
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $buildScript `
    -IsoPath $IsoPath -GameDirectory $extracted 2>&1 | ForEach-Object {
    $line = "$_"
    Write-Host $line
    foreach ($milestone in $milestones) {
        if ($milestone.Fraction -gt $reached -and $line.Trim() -match $milestone.Pattern) {
            $reached = $milestone.Fraction
            Write-Progress-Line $milestone.Fraction $milestone.Text
        }
    }
}
$buildExit = $LASTEXITCODE
$ErrorActionPreference = "Stop"
if ($buildExit -ne 0) {
    Stop-Setup "The build failed (exit code $buildExit). Only the USA and EU-FR (France) retail discs are supported."
}
$binDir = Join-Path $sourceDir "build\mercenaries\bin\Release"
foreach ($required in @("mercenaries_recomp.exe", "Mercenaries Recompiled.exe")) {
    if (-not (Test-Path -LiteralPath (Join-Path $binDir $required))) { Stop-Setup "The build did not produce $required." }
}

# --- Install ---------------------------------------------------------------
Write-Progress-Line 0.92 "Installing"
New-Item -ItemType Directory -Force -Path $gameDir | Out-Null
# Settings files the player may have changed are only created, never replaced.
$keptSettings = @("mercenaries_recomp.ini", "developer.ini", "modcompatibility.ini")
robocopy $binDir $gameDir /E /NFL /NDL /NJH /NJS /NP /XF @keptSettings | Out-Null
if ($LASTEXITCODE -ge 8) { Stop-Setup "Copying the build failed (robocopy exit code $LASTEXITCODE)." }
foreach ($name in $keptSettings) {
    $source = Join-Path $binDir $name
    $target = Join-Path $gameDir $name
    if ((Test-Path -LiteralPath $source) -and -not (Test-Path -LiteralPath $target)) {
        Copy-Item -LiteralPath $source -Destination $target
    }
}

$installedData = Join-Path $gameDir "game_files\mercenaries-retail"
if (Test-Path -LiteralPath $installedData) { Remove-Item -LiteralPath $installedData -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $installedData) | Out-Null
Move-Item -LiteralPath $extracted -Destination $installedData

# The game's own launcher treats this marker as a completed, validated install
# (Build-From-Iso already verified the XBE). Same format the launcher writes.
$xbeHash = (Get-FileHash -LiteralPath (Join-Path $installedData "default.xbe") -Algorithm SHA256).Hash
if (-not $SupportedXbe.ContainsKey($xbeHash)) { Stop-Setup "Unsupported default.xbe: $xbeHash" }
$marker = "Mercenaries Recompiled asset install v1`r`n" +
    "retail_revision=$($SupportedXbe[$xbeHash])`r`n" +
    "retail_xbe_sha256=$xbeHash`r`n"
$markerPath = Join-Path $installedData ".mercenaries-recompiled-install-v1"
[IO.File]::WriteAllText($markerPath, $marker, [Text.Encoding]::ASCII)
(Get-Item -LiteralPath $markerPath).Attributes = "Hidden"

$provenance = Join-Path $sourceDir "build\mercenaries\bin\Release\mercenaries-build-provenance.json"
if (Test-Path -LiteralPath $provenance) { Copy-Item -LiteralPath $provenance -Destination $gameDir -Force }

Write-Progress-Line 0.97 "Cleaning up"
Remove-Item -LiteralPath $workDir -Recurse -Force

Write-Host "Installed $($SupportedXbe[$xbeHash]) build to $gameDir"
Write-Progress-Line 1.00 "Done"
Stop-Transcript | Out-Null
exit 0
