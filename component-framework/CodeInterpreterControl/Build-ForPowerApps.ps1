# ============================================================================
# Build and Package Code Interpreter Control for Power Apps
# ============================================================================
# This script automates the build and packaging process for deploying
# the PCF control to Power Apps
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$PublisherName = "ContosoSoft",
    
    [Parameter(Mandatory=$false)]
    [string]$PublisherPrefix = "contoso",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$CleanFirst = $false
)

$ErrorActionPreference = "Stop"

Write-Host @"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🔨 BUILD CODE INTERPRETER CONTROL FOR POWER APPS             ║
║                                                                           ║
║                    Automated Build & Package Script                      ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = $ScriptDir

Write-Host "📁 Project Directory: $ProjectDir" -ForegroundColor Green
Write-Host ""

# ============================================================================
# Step 1: Verify Prerequisites
# ============================================================================

Write-Host "🔍 Step 1: Verifying Prerequisites..." -ForegroundColor Yellow
Write-Host "═" * 75 -ForegroundColor DarkGray

# Check Node.js
try {
    $nodeVersion = & node --version 2>&1
    Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Node.js not found! Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check npm
try {
    $npmVersion = & npm --version 2>&1
    Write-Host "   ✅ npm: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ npm not found!" -ForegroundColor Red
    exit 1
}

# Check PAC CLI
try {
    $pacVersion = & pac --version 2>&1
    Write-Host "   ✅ Power Platform CLI: Installed" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  PAC CLI not found - solution packaging may fail" -ForegroundColor Yellow
    Write-Host "      Install: winget install Microsoft.PowerPlatformCLI" -ForegroundColor Yellow
}

# Check msbuild
$msbuildPath = $null
$msbuildPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
)

foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuildPath = $path
        Write-Host "   ✅ MSBuild: Found" -ForegroundColor Green
        break
    }
}

if (-not $msbuildPath) {
    Write-Host "   ⚠️  MSBuild not found - will try using pac solution pack" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# Step 2: Clean Previous Build (Optional)
# ============================================================================

if ($CleanFirst) {
    Write-Host "🧹 Step 2: Cleaning Previous Build..." -ForegroundColor Yellow
    Write-Host "═" * 75 -ForegroundColor DarkGray
    
    # Remove node_modules
    if (Test-Path "$ProjectDir\node_modules") {
        Write-Host "   Removing node_modules..." -ForegroundColor Cyan
        Remove-Item "$ProjectDir\node_modules" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Remove out folder
    if (Test-Path "$ProjectDir\out") {
        Write-Host "   Removing out folder..." -ForegroundColor Cyan
        Remove-Item "$ProjectDir\out" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Remove solutions folder
    if (Test-Path "$ProjectDir\solutions") {
        Write-Host "   Removing solutions folder..." -ForegroundColor Cyan
        Remove-Item "$ProjectDir\solutions" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "   ✅ Clean completed" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# Step 3: Install Dependencies
# ============================================================================

Write-Host "📦 Step 3: Installing Dependencies..." -ForegroundColor Yellow
Write-Host "═" * 75 -ForegroundColor DarkGray

Set-Location $ProjectDir

if (-not (Test-Path "$ProjectDir\node_modules")) {
    Write-Host "   Running npm install..." -ForegroundColor Cyan
    try {
        & npm install
        Write-Host "   ✅ Dependencies installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ npm install failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✅ Dependencies already installed (node_modules exists)" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# Step 4: Build the PCF Control
# ============================================================================

if (-not $SkipBuild) {
    Write-Host "🔨 Step 4: Building PCF Control..." -ForegroundColor Yellow
    Write-Host "═" * 75 -ForegroundColor DarkGray
    
    Write-Host "   Running npm run build..." -ForegroundColor Cyan
    try {
        & npm run build
        Write-Host "   ✅ PCF Control built successfully" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Build failed: $_" -ForegroundColor Red
        exit 1
    }
    
    # Verify output
    if (Test-Path "$ProjectDir\out\controls") {
        $files = Get-ChildItem "$ProjectDir\out\controls" -Recurse
        Write-Host "   📄 Build outputs:" -ForegroundColor Cyan
        foreach ($file in $files) {
            Write-Host "      - $($file.Name)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
} else {
    Write-Host "⏭️  Step 4: Skipping build (--SkipBuild specified)" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# Step 5: Create Solution Package
# ============================================================================

Write-Host "📦 Step 5: Creating Solution Package..." -ForegroundColor Yellow
Write-Host "═" * 75 -ForegroundColor DarkGray

$solutionDir = "$ProjectDir\solutions"

# Create solutions directory if it doesn't exist
if (-not (Test-Path $solutionDir)) {
    Write-Host "   Creating solutions directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $solutionDir -Force | Out-Null
}

Set-Location $solutionDir

# Initialize solution if not already done
if (-not (Test-Path "$solutionDir\src")) {
    Write-Host "   Initializing solution..." -ForegroundColor Cyan
    try {
        & pac solution init --publisher-name $PublisherName --publisher-prefix $PublisherPrefix
        Write-Host "   ✅ Solution initialized" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Solution init failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Add reference if not already added
$cdsprojPath = Get-ChildItem -Path $solutionDir -Filter "*.cdsproj" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($cdsprojPath) {
    # Check if reference already exists
    $cdsprojContent = Get-Content $cdsprojPath.FullName -Raw
    
    if ($cdsprojContent -notmatch "CodeInterpreterControl") {
        Write-Host "   Adding PCF control reference..." -ForegroundColor Cyan
        try {
            & pac solution add-reference --path ".."
            Write-Host "   ✅ Reference added" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Reference may already exist or failed to add" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✅ PCF control reference already exists" -ForegroundColor Green
    }
}

# Build solution package
Write-Host "   Building solution package..." -ForegroundColor Cyan

$zipFileName = "CodeInterpreterControl.zip"
$zipPath = "$solutionDir\$zipFileName"

# Remove old zip if exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Try using msbuild first, fallback to pac solution pack
$packageSuccess = $false

if ($msbuildPath) {
    try {
        Write-Host "   Using MSBuild to package..." -ForegroundColor Cyan
        & $msbuildPath /t:build /restore /p:configuration=Release
        
        # Check for output in bin\Release
        $releasePath = Get-ChildItem -Path $solutionDir -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue | 
                       Where-Object { $_.DirectoryName -like "*Release*" } | 
                       Select-Object -First 1
        
        if ($releasePath) {
            Copy-Item $releasePath.FullName -Destination $zipPath -Force
            $packageSuccess = $true
            Write-Host "   ✅ Solution packaged using MSBuild" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ⚠️  MSBuild packaging failed, trying PAC CLI..." -ForegroundColor Yellow
    }
}

# Fallback to pac solution pack
if (-not $packageSuccess) {
    try {
        Write-Host "   Using PAC CLI to package..." -ForegroundColor Cyan
        & pac solution pack --zipfile $zipFileName --folder .\src --processCanvasApps
        
        if (Test-Path $zipPath) {
            $packageSuccess = $true
            Write-Host "   ✅ Solution packaged using PAC CLI" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ PAC CLI packaging failed: $_" -ForegroundColor Red
    }
}

if (-not $packageSuccess) {
    Write-Host "   ❌ Failed to create solution package!" -ForegroundColor Red
    Write-Host "   Please ensure PAC CLI or MSBuild is properly installed" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ============================================================================
# Step 6: Summary & Next Steps
# ============================================================================

Write-Host "🎉 Build Complete!" -ForegroundColor Green
Write-Host "═" * 75 -ForegroundColor DarkGray
Write-Host ""

if (Test-Path $zipPath) {
    $zipInfo = Get-Item $zipPath
    Write-Host "📦 Solution Package Created:" -ForegroundColor Cyan
    Write-Host "   📍 Location: $($zipInfo.FullName)" -ForegroundColor White
    Write-Host "   📊 Size: $([math]::Round($zipInfo.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "   📅 Created: $($zipInfo.LastWriteTime)" -ForegroundColor White
    Write-Host ""
}

Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1️⃣  Import to Power Apps:" -ForegroundColor Cyan
Write-Host "      • Go to https://make.powerapps.com" -ForegroundColor Gray
Write-Host "      • Navigate to Solutions → Import" -ForegroundColor Gray
Write-Host "      • Select: $zipFileName" -ForegroundColor Gray
Write-Host ""
Write-Host "   2️⃣  Configure AI Prompts:" -ForegroundColor Cyan
Write-Host "      • Go to AI Hub → Prompts" -ForegroundColor Gray
Write-Host "      • Create Code Interpreter-enabled prompts" -ForegroundColor Gray
Write-Host "      • Note the Model IDs (GUIDs)" -ForegroundColor Gray
Write-Host ""
Write-Host "   3️⃣  Add to Model-Driven App:" -ForegroundColor Cyan
Write-Host "      • Edit your app form" -ForegroundColor Gray
Write-Host "      • Add Code Interpreter Control" -ForegroundColor Gray
Write-Host "      • Configure Model ID and Entity ID" -ForegroundColor Gray
Write-Host "      • Save and Publish" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   • See DEPLOY-TO-POWERAPPS.md for detailed instructions" -ForegroundColor Gray
Write-Host "   • See TEST-HARNESS-README.md for testing guide" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 Quick Import Command:" -ForegroundColor Yellow
Write-Host "   pac solution import --path ""$zipPath""" -ForegroundColor Cyan
Write-Host "   (Requires authentication: pac auth create)" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ All Done! Ready to deploy to Power Apps! 🎊" -ForegroundColor Green
Write-Host ""

# Return to original directory
Set-Location $ProjectDir
