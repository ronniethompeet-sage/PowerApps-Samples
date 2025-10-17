# AI Rating Control - Quick Deployment Script
# This script automates the solution creation and packaging process

param(
    [Parameter(Mandatory=$false)]
    [string]$PublisherName = "Contoso",
    
    [Parameter(Mandatory=$false)]
    [string]$PublisherPrefix = "con",
    
    [Parameter(Mandatory=$false)]
    [string]$SolutionName = "AIRatingSolution"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AI Rating Control - Deployment Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Ensure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath
Write-Host "✓ Working directory: $scriptPath" -ForegroundColor Green

# Step 2: Build the PCF control
Write-Host ""
Write-Host "Building PCF control..." -ForegroundColor Yellow
Set-Location "AIRatingControl"
npm run build
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PCF control built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to build PCF control" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

# Step 3: Check if solution already exists
$solutionPath = Join-Path $scriptPath $SolutionName

if (Test-Path $solutionPath) {
    Write-Host ""
    Write-Host "⚠ Solution directory already exists: $SolutionName" -ForegroundColor Yellow
    $response = Read-Host "Do you want to delete it and recreate? (y/n)"
    
    if ($response -eq 'y') {
        Remove-Item -Path $solutionPath -Recurse -Force
        Write-Host "✓ Removed existing solution directory" -ForegroundColor Green
    } else {
        Write-Host "Using existing solution directory..." -ForegroundColor Yellow
        Set-Location $solutionPath
        
        # Add reference if needed
        Write-Host "Adding control reference to solution..." -ForegroundColor Yellow
        pac solution add-reference --path "..\AIRatingControl"
        
        # Build solution
        Write-Host ""
        Write-Host "Building solution..." -ForegroundColor Yellow
        msbuild /t:build /restore
        
        Set-Location ".."
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "✓ Solution built successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Solution package location:" -ForegroundColor Yellow
        Write-Host "$solutionPath\bin\Debug\$SolutionName.zip" -ForegroundColor White
        Write-Host ""
        exit 0
    }
}

# Step 4: Create solution
Write-Host ""
Write-Host "Creating Power Platform solution..." -ForegroundColor Yellow
pac solution init --publisher-name $PublisherName --publisher-prefix $PublisherPrefix --outputDirectory $SolutionName
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Solution created successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to create solution" -ForegroundColor Red
    exit 1
}

# Step 5: Add control reference to solution
Write-Host ""
Write-Host "Adding PCF control reference to solution..." -ForegroundColor Yellow
Set-Location $SolutionName
pac solution add-reference --path "..\AIRatingControl"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Control reference added" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to add control reference" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

# Step 6: Build solution
Write-Host ""
Write-Host "Building solution package..." -ForegroundColor Yellow
msbuild /t:build /restore
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Solution built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to build solution" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

# Step 7: Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Deployment package ready!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Solution Details:" -ForegroundColor Yellow
Write-Host "  Name:      $SolutionName" -ForegroundColor White
Write-Host "  Publisher: $PublisherName ($PublisherPrefix)" -ForegroundColor White
Write-Host "  Location:  $scriptPath\$SolutionName\bin\Debug\$SolutionName.zip" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Authenticate to your environment:" -ForegroundColor White
Write-Host "     pac auth create --environment {your-env-id}" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Import the solution:" -ForegroundColor White
Write-Host "     pac solution import --path '$SolutionName\bin\Debug\$SolutionName.zip'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Or import via Power Apps maker portal:" -ForegroundColor White
Write-Host "     https://make.powerapps.com → Solutions → Import" -ForegroundColor Cyan
Write-Host ""
