#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs Chocolatey and a set of commonly used applications.

.DESCRIPTION
    This script:
      1. Checks if Chocolatey is already installed; installs it if not.
      2. Installs the following applications via Chocolatey:
           - Notepad++
           - Arc Browser
           - Claude (Anthropic desktop app)
           - Visual Studio Code

.NOTES
    Must be run as Administrator.
    Execution policy must allow script execution.
    To temporarily bypass the policy, run:
        Set-ExecutionPolicy Bypass -Scope Process -Force
#>

# ---------------------------------------------------------------------------
# Helper: Write a coloured status message
# ---------------------------------------------------------------------------
function Write-Status {
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'Cyan'
    )
    Write-Host "`n$Message" -ForegroundColor $Color
}

# ---------------------------------------------------------------------------
# 1. Ensure the script is running as Administrator
# ---------------------------------------------------------------------------
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell and choose 'Run as Administrator', then try again." -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------------------------
# 2. Install Chocolatey (if not already present)
# ---------------------------------------------------------------------------
Write-Status "Checking for Chocolatey..."

if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
} else {
    Write-Status "Chocolatey not found. Installing Chocolatey..."

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    try {
        Invoke-Expression (
            (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        )
        Write-Host "Chocolatey installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to install Chocolatey. $_" -ForegroundColor Red
        exit 1
    }

    # Reload PATH so 'choco' is available in this session
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# ---------------------------------------------------------------------------
# 3. Define the apps to install
#    Format: @{ Name = 'Display Name'; Package = 'chocolatey-package-id' }
# ---------------------------------------------------------------------------
$apps = @(
    @{ Name = 'Notepad++';          Package = 'notepadplusplus' },
    @{ Name = '7-Zip';        Package = '7zip'             },
    @{ Name = 'Claude';             Package = 'claude'          },
    @{ Name = 'Visual Studio Code'; Package = 'vscode'          },
    @{ Name = 'Terraform';           Package = 'terraform'      },
    @{ Name = 'TFLint';           Package = 'tflint'      },
    @{ Name = 'KeePass';           Package = 'keepass'      },
    @{ Name = 'OpenCode';           Package = 'opencode'      },
    @{ Name = 'Git';           Package = 'git'      },
    @{ Name = 'Azure CLi';           Package = 'azure-cli'      },
    @{ Name = 'ShareX';           Package = 'sharex'      },
    @{ Name = 'FireFox';           Package = 'firefox'      },
    @{ Name = 'Draw.IO';           Package = 'drawio'      },
    @{ Name = 'Steam';           Package = 'steam'      },
    @{ Name = 'NordVPN';           Package = 'nordvpn'      },
    @{ Name = 'Discord';           Package = 'discord'      },
    @{ Name = 'Blender';           Package = 'blender'      },
    @{ Name = 'TreeSize';           Package = 'treesizefree' },
    @{ Name = 'Spotify';           Package = 'spotify'      },
    @{ Name = 'VLC Studio';           Package = 'vlc'      },
    @{ Name = 'Gimp';           Package = 'gimp'      },
    @{ Name = 'Audacity';           Package = 'audacity'      },
    @{ Name = 'OBS Studio';           Package = 'obs-studio.install'      },
    @{ Name = 'qBitTorrent';           Package = 'qbittorrent'      },
    @{ Name = 'File Converter';           Package = 'file-converter'      }

)

# ---------------------------------------------------------------------------
# 4. Install each application
# ---------------------------------------------------------------------------
$results = @()

foreach ($app in $apps) {
    Write-Status "Installing $($app.Name)..."

    choco install $($app.Package) --yes --no-progress 2>&1 | Out-String | Write-Host

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$($app.Name) installed successfully." -ForegroundColor Green
        $results += [PSCustomObject]@{ App = $app.Name; Status = 'Success' }
    } else {
        Write-Host "WARNING: $($app.Name) may not have installed correctly (exit code $LASTEXITCODE)." -ForegroundColor Yellow
        $results += [PSCustomObject]@{ App = $app.Name; Status = 'Failed / Check Manually' }
    }
}

#Set-PSRepository PSGaallery -InstallationPolicy Trusted
#Install-Module -scope currentuser -name az -confirm:$false -force

# ---------------------------------------------------------------------------
# 5. Print summary
# ---------------------------------------------------------------------------
Write-Status "Installation Summary" 'Magenta'
$results | Format-Table -AutoSize

Write-Host "`nDone! Some apps may require you to restart your session or machine." -ForegroundColor Cyan
