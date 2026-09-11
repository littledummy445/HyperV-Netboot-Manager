Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Hyper-V Netboot.xyz VM Creator"
$form.Size = New-Object System.Drawing.Size(520, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# VM Name Label & TextBox
$labelVM = New-Object System.Windows.Forms.Label
$labelVM.Text = "VM Name:"
$labelVM.Location = New-Object System.Drawing.Point(20, 20)
$labelVM.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelVM)

$textVM = New-Object System.Windows.Forms.TextBox
$textVM.Text = "NetbootXYZ-VM"
$textVM.Location = New-Object System.Drawing.Point(130, 20)
$textVM.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($textVM)

# Storage Path Label & TextBox
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Text = "VM Storage Path:"
$labelPath.Location = New-Object System.Drawing.Point(20, 60)
$labelPath.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelPath)

$textPath = New-Object System.Windows.Forms.TextBox
$textPath.Text = "C:\VMs"
$textPath.Location = New-Object System.Drawing.Point(130, 60)
$textPath.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($textPath)

# ISO Path Label & TextBox
$labelIso = New-Object System.Windows.Forms.Label
$labelIso.Text = "ISO File Path:"
$labelIso.Location = New-Object System.Drawing.Point(20, 100)
$labelIso.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelIso)

$textIso = New-Object System.Windows.Forms.TextBox
$textIso.Text = "C:\Hyper-V\netboot.xyz.iso"
$textIso.Location = New-Object System.Drawing.Point(130, 100)
$textIso.Size = New-Object System.Drawing.Size(230, 20)
$form.Controls.Add($textIso)

# Browse ISO Button
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Text = "Browse..."
$buttonBrowse.Location = New-Object System.Drawing.Point(370, 98)
$buttonBrowse.Size = New-Object System.Drawing.Size(100, 23)
$buttonBrowse.Add_Click({
    $openDlg = New-Object System.Windows.Forms.OpenFileDialog
    $openDlg.Filter = "ISO Files (*.iso)|*.iso|All Files (*.*)|*.*"
    if ($openDlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textIso.Text = $openDlg.FileName
    }
})
$form.Controls.Add($buttonBrowse)

# Download ISO Button
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "Download netboot.xyz"
$buttonDownload.Location = New-Object System.Drawing.Point(130, 140)
$buttonDownload.Size = New-Object System.Drawing.Size(160, 30)
$buttonDownload.Add_Click({
    $isoPath = $textIso.Text
    $isoDir = Split-Path $isoPath -Parent
    if (-not (Test-Path $isoDir)) {
        New-Item -ItemType Directory -Path $isoDir -Force | Out-Null
    }
    [System.Windows.Forms.MessageBox]::Show("Downloading netboot.xyz.iso... Click OK to start download.", "Download", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    try {
        Invoke-WebRequest -Uri "https://boot.netboot.xyz/ipxe/netboot.xyz.iso" -OutFile $isoPath
        [System.Windows.Forms.MessageBox]::Show("Download completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Download failed: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($buttonDownload)

# Create & Start Button
$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Text = "Create & Start VM"
$buttonCreate.Location = New-Object System.Drawing.Point(130, 210)
$buttonCreate.Size = New-Object System.Drawing.Size(340, 40)
$buttonCreate.BackColor = [System.Drawing.Color]::LightGreen
$buttonCreate.Add_Click({
    $VMName = $textVM.Text
    $Path = $textPath.Text
    $IsoPath = $textIso.Text

    if (-not (Test-Path $IsoPath)) {
        [System.Windows.Forms.MessageBox]::Show("ISO file not found! Please browse or download it first.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        
        New-VM -Name $VMName -Generation 2 -MemoryStartupBytes 4GB -NewVHDPath "$Path\$VMName\$VMName.vhdx" -NewVHDSizeBytes 40GB -Path $Path -ErrorAction Stop
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off -ErrorAction Stop
        $SwitchName = (Get-VMSwitch | Select-Object -First 1).Name
        Connect-VMNetworkAdapter -VMName $VMName -SwitchName $SwitchName -ErrorAction Stop
        Add-VMScsiController -VMName $VMName -ErrorAction Stop
        Add-VMDvdDrive -VMName $VMName -Path $IsoPath -ErrorAction Stop
        Start-VM -Name $VMName -ErrorAction Stop

        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        [System.Windows.Forms.MessageBox]::Show("Virtual Machine '$VMName' created and started successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Close()
    } catch {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        [System.Windows.Forms.MessageBox]::Show("Failed to create VM: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($buttonCreate)

[void]$form.ShowDialog()