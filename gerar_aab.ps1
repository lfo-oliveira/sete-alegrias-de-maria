# Gera o arquivo da Play Store (.aab) aumentando sozinho o número da versão.
#
# Uso (na pasta do projeto):
#   powershell -ExecutionPolicy Bypass -File .\gerar_aab.ps1
#   powershell -ExecutionPolicy Bypass -File .\gerar_aab.ps1 -Nome 1.0.1
#
# O número depois do "+" no pubspec.yaml (código da versão) sobe de 1 em 1 a cada
# execução, como a Play Store exige. O "-Nome" é opcional: muda o nome da versão
# que o fiel vê (a parte antes do "+").
param([string]$Nome)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$arquivo = Join-Path $PSScriptRoot 'pubspec.yaml'
$texto = [System.IO.File]::ReadAllText($arquivo)

$padrao = '(?m)^version:[ \t]*(\d+\.\d+\.\d+)\+(\d+)[ \t]*(\r?)$'
$achado = [regex]::Match($texto, $padrao)
if (-not $achado.Success) {
    throw 'Não encontrei a linha "version: x.y.z+n" no pubspec.yaml.'
}

$nomeDaVersao = $achado.Groups[1].Value
if ($Nome) {
    if ($Nome -notmatch '^\d+\.\d+\.\d+$') { throw 'Use o formato 1.0.1 em -Nome.' }
    $nomeDaVersao = $Nome
}
$codigo = [int]$achado.Groups[2].Value + 1

$linhaNova = "version: $nomeDaVersao+$codigo" + $achado.Groups[3].Value
$texto = $texto.Remove($achado.Index, $achado.Length).Insert($achado.Index, $linhaNova)
[System.IO.File]::WriteAllText($arquivo, $texto, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Versão: $nomeDaVersao (código $codigo)" -ForegroundColor Green

# Solta arquivos que o Gradle costuma deixar presos no Windows.
if (Test-Path .\android\gradlew.bat) { & .\android\gradlew.bat --stop | Out-Null }

flutter build appbundle --release
if ($LASTEXITCODE -ne 0) {
    throw 'O build falhou. O código da versão já foi aumentado; isso não é problema.'
}

Write-Host ''
Write-Host 'Pronto: build\app\outputs\bundle\release\app-release.aab' -ForegroundColor Green
