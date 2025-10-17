# ============================================================================
# Code Interpreter Control - Test Harness Launcher
# ============================================================================
# This script launches a local web server to test the PCF Code Interpreter
# Control in an interactive environment
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 8082,
    
    [Parameter(Mandatory=$false)]
    [switch]$OpenBrowser = $true
)

Write-Host @"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🤖 CODE INTERPRETER CONTROL TEST HARNESS 🤖                  ║
║                                                                           ║
║                    Interactive PCF Control Demo                          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HtmlFile = Join-Path $ScriptDir "test-harness.html"

# Check if HTML file exists
if (-not (Test-Path $HtmlFile)) {
    Write-Host "❌ Error: test-harness.html not found!" -ForegroundColor Red
    Write-Host "   Expected location: $HtmlFile" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 Working Directory: $ScriptDir" -ForegroundColor Green
Write-Host "📄 Test Harness File: test-harness.html" -ForegroundColor Green
Write-Host ""

# Check if Python is available
$PythonCmd = $null
$PythonCommands = @('python', 'python3', 'py')

foreach ($cmd in $PythonCommands) {
    try {
        $version = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $PythonCmd = $cmd
            Write-Host "✅ Found Python: $version" -ForegroundColor Green
            break
        }
    } catch {
        continue
    }
}

if (-not $PythonCmd) {
    Write-Host "⚠️  Python not found. Attempting alternative method..." -ForegroundColor Yellow
    
    # Try using Node.js http-server if available
    try {
        $nodeVersion = & node --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Found Node.js: $nodeVersion" -ForegroundColor Green
            
            # Check if http-server is installed globally
            try {
                & http-server --version 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Using http-server (Node.js package)" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "🌐 Starting server on port $Port..." -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "═" * 75 -ForegroundColor DarkGray
                    Write-Host "  📍 Local URL: http://localhost:$Port" -ForegroundColor White -BackgroundColor DarkBlue
                    Write-Host "  📍 Test Page: http://localhost:$Port/test-harness.html" -ForegroundColor White -BackgroundColor DarkBlue
                    Write-Host "═" * 75 -ForegroundColor DarkGray
                    Write-Host ""
                    Write-Host "💡 TIP: Press Ctrl+C to stop the server" -ForegroundColor Yellow
                    Write-Host ""
                    
                    if ($OpenBrowser) {
                        Start-Sleep -Seconds 2
                        Start-Process "http://localhost:$Port/test-harness.html"
                    }
                    
                    Set-Location $ScriptDir
                    & http-server -p $Port
                    exit 0
                }
            } catch {
                Write-Host "⚠️  http-server not installed. Installing..." -ForegroundColor Yellow
                Write-Host "   Run: npm install -g http-server" -ForegroundColor Cyan
            }
        }
    } catch {
        # Node.js not available
    }
    
    # Fallback to simple .NET HttpListener
    Write-Host "⚠️  No suitable HTTP server found." -ForegroundColor Yellow
    Write-Host "   Opening file directly in browser..." -ForegroundColor Yellow
    Start-Process $HtmlFile
    exit 0
}

# Start Python HTTP server
Write-Host ""
Write-Host "🚀 Starting Python HTTP Server..." -ForegroundColor Cyan
Write-Host ""
Write-Host "═" * 75 -ForegroundColor DarkGray
Write-Host "  📍 Local URL: http://localhost:$Port" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "  📍 Test Page: http://localhost:$Port/test-harness.html" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "═" * 75 -ForegroundColor DarkGray
Write-Host ""
Write-Host "🎯 DEMO FEATURES:" -ForegroundColor Yellow
Write-Host "   • Interactive Chart Generation (Bar, Line, Pie, Comparison)" -ForegroundColor White
Write-Host "   • Document Preview (PDF, Word, Excel, PowerPoint)" -ForegroundColor White
Write-Host "   • AI Code Interpreter Integration Simulation" -ForegroundColor White
Write-Host "   • Real-time Configuration & Testing" -ForegroundColor White
Write-Host ""
Write-Host "💡 TIP: Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Open browser after short delay
if ($OpenBrowser) {
    Start-Sleep -Seconds 2
    Write-Host "🌐 Opening browser..." -ForegroundColor Cyan
    Start-Process "http://localhost:$Port/test-harness.html"
}

# Change to script directory and start server
Set-Location $ScriptDir

# Start Python server based on version
try {
    # Try Python 3 syntax first
    & $PythonCmd -m http.server $Port
} catch {
    # Fallback to Python 2 syntax
    & $PythonCmd -m SimpleHTTPServer $Port
}

Write-Host ""
Write-Host "✅ Server stopped." -ForegroundColor Green
