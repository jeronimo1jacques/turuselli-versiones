# Instala Turuselli en una PC nueva bajando la ultima version publicada.
# Se publica en el repo publico jeronimo1jacques/turuselli-versiones como "instalar.ps1".
#
# Uso: abrir PowerShell COMO ADMINISTRADOR y pegar:
#   irm https://raw.githubusercontent.com/jeronimo1jacques/turuselli-versiones/main/instalar.ps1 | iex
#
# Hace: busca el ultimo Release, baja el .zip y su .sha256, verifica la huella, descomprime
# y corre el instalar.ps1 del paquete (el mismo que INSTALAR.bat).
# Solo ASCII a proposito: al ejecutarse con "irm | iex" no hay problemas de codificacion.
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $repo = 'jeronimo1jacques/turuselli-versiones'

    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $admin) {
        Write-Host ''
        Write-Host 'Hace falta abrir PowerShell como administrador:' -ForegroundColor Yellow
        Write-Host '  Inicio -> escribir "PowerShell" -> clic derecho -> "Ejecutar como administrador"' -ForegroundColor Yellow
        Write-Host '  y volver a pegar la misma linea.' -ForegroundColor Yellow
        return
    }

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $cabeceras = @{ 'User-Agent' = 'Turuselli-Instalador'; 'Accept' = 'application/vnd.github+json' }

        Write-Host "`n> Buscando la ultima version de Turuselli..." -ForegroundColor Cyan
        $rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers $cabeceras -TimeoutSec 30
        $aZip = $rel.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
        $aSha = $rel.assets | Where-Object { $_.name -like '*.sha256' } | Select-Object -First 1
        if (-not $aZip -or -not $aSha) { throw "La version $($rel.tag_name) esta publicada sin sus archivos." }

        $carpeta = Join-Path $env:TEMP 'TuruselliInstalacion'
        Remove-Item $carpeta -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Force -Path $carpeta | Out-Null
        $zip = Join-Path $carpeta $aZip.name
        $sha = Join-Path $carpeta $aSha.name

        Write-Host ("> Descargando {0} ({1:N0} MB, puede tardar unos minutos)..." -f $rel.tag_name, ($aZip.size / 1MB)) -ForegroundColor Cyan
        Invoke-WebRequest $aZip.browser_download_url -OutFile $zip -UseBasicParsing -Headers @{ 'User-Agent' = 'Turuselli-Instalador' }
        Invoke-WebRequest $aSha.browser_download_url -OutFile $sha -UseBasicParsing -Headers @{ 'User-Agent' = 'Turuselli-Instalador' }

        Write-Host '> Verificando que la descarga este completa...' -ForegroundColor Cyan
        $esperado = ((Get-Content $sha -Raw).Trim() -split '\s+')[0]
        $real = (Get-FileHash $zip -Algorithm SHA256).Hash
        if ($real -ne $esperado) { throw 'La descarga esta incompleta o danada (la huella no coincide). Volve a pegar la linea.' }

        Write-Host '> Descomprimiendo...' -ForegroundColor Cyan
        $paquete = Join-Path $carpeta 'paquete'
        Expand-Archive -Path $zip -DestinationPath $paquete -Force
        $instalador = Join-Path $paquete 'instalar.ps1'
        if (-not (Test-Path $instalador)) { throw 'El paquete descargado no trae instalar.ps1.' }

        Write-Host '> Instalando...' -ForegroundColor Cyan
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $instalador
    }
    catch {
        Write-Host ''
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host 'Sacale una foto a esta pantalla y mandasela al tecnico.' -ForegroundColor Red
    }
}
