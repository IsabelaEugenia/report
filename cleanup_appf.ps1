
# cleanup_appf.ps1
# Execute este script como Administrador dentro da pasta do projeto appf.
# Abra PowerShell, vá para:
# Set-Location "C:\Users\isabe\OneDrive\Área de Trabalho\appf"
# Em seguida, execute uma destas opções:
# 1) .\cleanup_appf.ps1
# 2) powershell -ExecutionPolicy Bypass -File .\cleanup_appf.ps1
# 3) Set-ExecutionPolicy Bypass -Scope Process -Force; .\cleanup_appf.ps1

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$pathsToRemove = @( \
    ".dart_tool",
    "build",
    "linux\\flutter\\ephemeral",
    "macos\\Flutter\\ephemeral",
    "windows\\flutter\\ephemeral",
    "ios\\Flutter\\ephemeral"
)

Write-Host "[1/5] Tentando liberar permissões e deletar artefatos gerados..." -ForegroundColor Cyan
foreach ($path in $pathsToRemove) {
    if (Test-Path $path) {
        Write-Host "- Verificando $path"
        try {
            takeown /F "$path" /R /D Y | Out-Null
            icacls "$path" /grant "${env:USERNAME}:(F)" /T /C | Out-Null
        } catch {
            Write-Warning "Falha ao ajustar permissões em $path. Pode ser normal se já estiver liberado."
        }
        try {
            Remove-Item -Recurse -Force -ErrorAction Stop $path
            Write-Host "  Excluído: $path" -ForegroundColor Green
        } catch {
            Write-Warning "Não foi possível excluir $path. Se ainda houver bloqueio, feche o OneDrive/Explorer e tente novamente."
        }
    } else {
        Write-Host "- Não existe: $path" -ForegroundColor DarkGray
    }
}

Write-Host "[2/5] Limpando o projeto Flutter..." -ForegroundColor Cyan
try {
    flutter clean
} catch {
    Write-Warning "flutter clean falhou. Verifique se o Flutter está instalado e no PATH."
}

Write-Host "[3/5] Obtendo dependências..." -ForegroundColor Cyan
try {
    flutter pub get
} catch {
    Write-Warning "flutter pub get falhou. Verifique a conexão e o ambiente Flutter."
}

Write-Host "[4/5] Executando análise do Dart..." -ForegroundColor Cyan
try {
    flutter analyze
} catch {
    Write-Warning "flutter analyze falhou. Revise os erros exibidos no console."
}

Write-Host "Script finalizado. Se houver erros de arquivo travado, pare o OneDrive e reinicie o PowerShell como Administrador." -ForegroundColor Green
