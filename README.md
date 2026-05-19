# Install-Apps.ps1

A PowerShell bootstrap script for Windows that installs [Chocolatey](https://chocolatey.org/) (if not already present) and then uses it to install a curated set of commonly used applications in a single run. Useful for setting up a fresh Windows machine or standardising tooling across devices.

## What it does

1. Verifies the script is running with Administrator privileges (exits if not).
2. Checks whether Chocolatey is installed. If not, it bootstraps Chocolatey from the official `community.chocolatey.org` install script.
3. Reloads the `PATH` so `choco` is available in the current session.
4. Iterates through a predefined list of applications and installs each via `choco install --yes --no-progress`.
5. Tracks the result of each install and prints a summary table at the end.

## Applications installed

| Application        | Chocolatey package    |
|--------------------|-----------------------|
| Notepad++          | `notepadplusplus`     |
| 7-Zip              | `7zip`                |
| Claude             | `claude`              |
| Visual Studio Code | `vscode`              |
| Terraform          | `terraform`           |
| TFLint             | `tflint`              |
| KeePass            | `keepass`             |
| OpenCode           | `opencode`            |
| Git                | `git`                 |
| Azure CLI          | `azure-cli`           |
| ShareX             | `sharex`              |
| Firefox            | `firefox`             |
| Draw.IO            | `drawio`              |
| Steam              | `steam`               |
| NordVPN            | `nordvpn`             |
| Discord            | `discord`             |
| Blender            | `blender`             |
| TreeSize Free      | `treesizefree`        |
| Spotify            | `spotify`             |
| VLC                | `vlc`                 |
| GIMP               | `gimp`                |
| Audacity           | `audacity`            |
| OBS Studio         | `obs-studio.install`  |
| qBittorrent        | `qbittorrent`         |
| File Converter     | `file-converter`      |

## Requirements

- Windows with PowerShell 5.1 or later (PowerShell 7+ also works).
- Administrator privileges — the script will refuse to run otherwise (`#Requires -RunAsAdministrator`).
- An internet connection (needed to download Chocolatey and the packages).
- An execution policy that allows running local scripts. If yours is restrictive, bypass it for the current process only:
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process -Force
  ```

## Usage

1. Open PowerShell **as Administrator** (right-click → *Run as Administrator*).
2. Navigate to the folder containing the script:
   ```powershell
   cd C:\path\to\script
   ```
3. (Optional) Allow script execution for this session:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   ```
4. Run the script:
   ```powershell
   .\Install-Apps.ps1
   ```

The script will print coloured status messages as it works and finish with a summary table showing which applications installed successfully and which need to be checked manually.

## Customising the app list

To add, remove, or change applications, edit the `$apps` array in the script. Each entry is a hashtable with a friendly `Name` and the corresponding Chocolatey `Package` ID:

```powershell
@{ Name = 'My App'; Package = 'my-chocolatey-package-id' }
```

You can find package IDs on the [Chocolatey Community Repository](https://community.chocolatey.org/packages).

## Output

For every package, the script will report one of:

- **Success** — Chocolatey reported a successful install (exit code `0`).
- **Failed / Check Manually** — A non-zero exit code was returned. The package may have failed, may already be installed at a different version, or may need manual intervention.

A final summary is printed via `Format-Table`.

## Notes

- Some applications (e.g. Git, Azure CLI) may require you to restart your shell or sign out/in for `PATH` updates to take effect.
- A few packages may prompt or require a reboot — review the output if any items report as failed.
- The commented-out lines at the bottom of the script show an optional pattern for trusting the PSGallery and installing the Azure PowerShell `Az` module if you want to extend the script.
