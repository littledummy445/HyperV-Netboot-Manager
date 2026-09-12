# Complete PowerShell Script for Hyper-V VM Creation with VMConnect Prompt

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Configuration variables
$VMName = "DebianLinuxVM"
$MemoryBytes = 4GB
$VHDPath = "C:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
$SwitchName = "Default Switch"

try {
    Write-Host "Creating Virtual Machine: $VMName..." -ForegroundColor Cyan
    New-VM -Name $VMName -MemoryStartupBytes $MemoryBytes -NewVHDPath $VHDPath -NewVHDSizeByBytes 20GB -SwitchName $SwitchName | Out-Null
    Write-Host "Virtual Machine created successfully!" -ForegroundColor Green

    # Prompt the user via a Windows Forms message box
    $result = [System.Windows.MessageBox]::Show("Virtual Machine '$VMName' has been created successfully. Do you want to connect to the VM now?", "Connect to VM", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)

    if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
        Write-Host "Launching VMConnect..." -ForegroundColor Cyan
        Start-Process "vmconnect.exe" -ArgumentList "localhost", "$VMName"
    } else {
        Write-Host "Connection skipped. You can open VMConnect manually whenever you are ready." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An error occurred during VM creation: $_"
}
