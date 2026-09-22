# Hyper-V Netboot.xyz GUI Manager

A lightweight, native PowerShell GUI tool designed to rapidly provision and launch Generation 2 Hyper-V virtual machines configured for network booting using `netboot.xyz`.

## Features

* **Graphical User Interface:** Simple Windows Forms interface to input VM names, paths, and ISO locations without touching complex CLI parameters.
* **Built-in Downloader:** Instantly fetch the latest official `netboot.xyz.iso` directly from the app interface.
* **Automated Provisioning:** Automatically creates Generation 2 virtual machines, allocates virtual memory/storage, disables Secure Boot for iPXE compatibility, binds the virtual switch, attaches media, and boots the VM.

## Prerequisites

* Windows 10 or Windows 11 with the **Hyper-V** feature enabled.
* PowerShell 5.1 or higher.
* Administrator privileges (required to interact with Hyper-V cmdlets and network switches).

## How to Use

1. Head over to the **Releases** section of this repository.
2. Download the latest `deploy-netboot-vm.ps1` script file.
3. Open **PowerShell as Administrator** and run the script:
   ```powershell
   .\deploy-netboot-vm.ps1

## Launch netboot.xyz in GitHub Codespaces
1. You can use netboot.xyz without installing anything locally, just go to this GitHub Repository https://github.com/littledummy445/githubcodespaces-netbootxyz
2. Then copy the docker command in the README file and then launch a new codespace.
3. And paste the command into the codespaces terminal and then netboot xyz will load up in noVNC

```plaintext


```
