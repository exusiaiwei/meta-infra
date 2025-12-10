# -*- coding: utf-8 -*-
# ================================================================================================
# meta-infra - Bootstrap Loader (BIOS Layer)
# ================================================================================================
# Purpose: Lightweight bootstrap program, only responsible for:
#   1. Check and install Git
#   2. Clone repository
#   3. Start Mise task system
#
# Design: Minimize PowerShell code, delegate complex logic to Mise + Nushell
#
# Usage:
#   irm https://raw.githubusercontent.com/exusiaiwei/meta-infra/master/bootstrap/init.ps1 | iex
# ================================================================================================

#Requires -Version 5.1
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# Configuration
# ========================================
$REPO_URL = "https://github.com/exusiaiwei/meta-infra.git"
$INSTALL_DIR = Join-Path $env:USERPROFILE "meta-infra"

# ========================================
# Minimal Helper Functions
# ========================================
function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host ">> $Message" -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ========================================
# BIOS Bootstrap Process
# ========================================
function Start-Bootstrap {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  meta-infra Bootstrap Loader" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Step 1: Check/Install Git
    Write-Step "Checking Git..."
    if (-not (Test-CommandExists "git")) {
        Write-Step "Git not installed, installing..." "Yellow"

        if (-not (Test-CommandExists "winget")) {
            Write-Host ""
            Write-Host "[ERROR] Winget is required to install Git" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please install App Installer first:" -ForegroundColor Yellow
            Write-Host "  1. Visit: https://aka.ms/getwinget"
            Write-Host "  2. Or run: winget install Git.Git"
            Write-Host ""
            exit 1
        }

        winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    Write-Step "[OK] Git ready" "Green"

    # Step 2: Clone/Update repository
    if (Test-Path $INSTALL_DIR) {
        Write-Step "Repository exists, updating..."
        Push-Location $INSTALL_DIR
        git pull
        Pop-Location
    } else {
        Write-Step "Cloning repository: $REPO_URL"
        git clone $REPO_URL $INSTALL_DIR
    }

    Write-Step "[OK] Repository ready" "Green"

    # Step 3: Hand over to Mise
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Starting Mise Task System" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    Push-Location $INSTALL_DIR

    # Check Mise
    if (Test-CommandExists "mise") {
        Write-Step "Mise installed, starting wizard..."
        mise run bootstrap
    } else {
        Write-Step "Mise not installed, please run:" "Yellow"
        Write-Host ""
        Write-Host "  winget configure manifests/core/base.yaml" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Then run:" -ForegroundColor Yellow
        Write-Host "  mise run bootstrap" -ForegroundColor Cyan
        Write-Host ""
    }

    Pop-Location
}

# Run bootstrap
Start-Bootstrap
