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

function Set-BlueWallpaper {
    # cria um arquivo azul puro na pasta temp
    $wall = "$env:TEMP\blue_wallpaper.bmp"

    # gera um bmp azul 1920x1080 (bem simples)
    $bmp = New-Object System.Drawing.Bitmap 1920,1080
    for ($x=0; $x -lt 1920; $x++) {
        for ($y=0; $y -lt 1080; $y++) {
            $bmp.SetPixel($x,$y,[System.Drawing.Color]::Blue)
        }
    }
    $bmp.Save($wall)

    # ajusta no registro
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name wallpaper -Value $wall

    # pede para o Windows aplicar a mudança
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
}

Get-ChildItem -Path $TargetRoot -Recurse -Filter "*.ENCRYPTED" -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            Decrypt-FileXOR $_.FullName $Key
        } catch {}
    }

Set-BlueWallpaper

Write-Host "Desencriptação concluída e papel de parede trocado!"
