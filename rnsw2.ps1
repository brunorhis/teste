$Key = [System.Text.Encoding]::UTF8.GetBytes("mO2MeuEd")
$TargetRoot = "C:\Users"

function Decrypt-FileXOR {
    param($FilePath, $Key)
    $data = [System.IO.File]::ReadAllBytes($FilePath)
    for ($i=0; $i -lt $data.Length; $i++) {
        $data[$i] = $data[$i] -bxor $Key[$i % $Key.Length]
    }
    $original = $FilePath -replace "\.ENCRYPTED$",""
    [System.IO.File]::WriteAllBytes($original, $data)
    Remove-Item $FilePath
}

# Desencripta todos os arquivos .ENCRYPTED sob o diretório alvo
Get-ChildItem -Path $TargetRoot -Recurse -Filter "*.ENCRYPTED" -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            Decrypt-FileXOR $_.FullName $Key
        } catch {}
    }

# Função para criar um wallpaper azul sólido e definir como background
function Set-BlueWallpaper {
    $bmpPath = "$env:TEMP\blue_wallpaper.bmp"
    Add-Type -AssemblyName System.Drawing
    $bmp = New-Object System.Drawing.Bitmap 1024,768
    $Graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $blue = [System.Drawing.Color]::FromArgb(0,120,215)  # Azul padrão Windows
    $Brush = New-Object System.Drawing.SolidBrush $blue
    $Graphics.FillRectangle($Brush, 0,0,1024,768)
    $bmp.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $Brush.Dispose()
    $Graphics.Dispose()
    $bmp.Dispose()

    Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $bmpPath, 3)
    Write-Host "Plano de fundo azul definido!"
}

# Troca o plano de fundo após a desencriptação
Set-BlueWallpaper

Write-Host "Desencriptação concluída e plano de fundo revertido para azul."
