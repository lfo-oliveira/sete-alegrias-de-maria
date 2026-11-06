# Script para localizar e excluir todas as pastas 'ephemeral' do projeto

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "Procurando pastas 'ephemeral' no projeto..." -ForegroundColor Cyan

$pastas = Get-ChildItem -Path $PSScriptRoot -Recurse -Directory -Filter "ephemeral"

if ($pastas.Count -eq 0) {
    Write-Host "Nenhuma pasta 'ephemeral' encontrada." -ForegroundColor Green
    exit 0
}

foreach ($pasta in $pastas) {
    Write-Host "Excluindo: $($pasta.FullName)..." -ForegroundColor Yellow
    Remove-Item -Path $pasta.FullName -Recurse -Force
    if (Test-Path $pasta.FullName) {
        Write-Warning "Nao foi possivel excluir totalmente: $($pasta.FullName) (pode estar em uso)."
    } else {
        Write-Host "Excluida com sucesso!" -ForegroundColor Green
    }
}

Write-Host "`nLimpeza de pastas 'ephemeral' concluida!" -ForegroundColor Green

