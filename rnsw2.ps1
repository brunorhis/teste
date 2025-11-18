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

Get-ChildItem -Path $TargetRoot -Recurse -Filter "*.ENCRYPTED" -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            Decrypt-FileXOR $_.FullName $Key
        } catch {}
    }

Write-Host "Desencriptação concluída!"
