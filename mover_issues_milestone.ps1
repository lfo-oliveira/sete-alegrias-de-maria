# Script para mover todas as issues abertas para a milestone "v1.1.1 - Internacionalização"
# Certifique-se de estar autenticado com: gh auth login

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repo = "lfo-oliveira/sete-alegrias-de-maria"
$milestoneAlvo = "v1.1.1 - Internacionalização"

Write-Host "Verificando autenticacao com GitHub CLI..." -ForegroundColor Cyan
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Voce precisa estar autenticado no GitHub CLI."
    Write-Host "Execute no terminal: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nBuscando milestone '$milestoneAlvo' no repositorio $repo..." -ForegroundColor Cyan
$milestonesJson = gh api "repos/$repo/milestones?state=all" | ConvertFrom-Json

$milestoneEncontrada = $milestonesJson | Where-Object { $_.title -like "*$milestoneAlvo*" -or $_.title -like "*Internacionaliza*" } | Select-Object -First 1

if (-not $milestoneEncontrada) {
    Write-Warning "Milestone nao encontrada com o nome exato. Listando milestones existentes no repositorio:"
    $milestonesJson | ForEach-Object { Write-Host " - [$($_.number)] $($_.title)" -ForegroundColor Yellow }
    Write-Host "`nTentando usar o nome '$milestoneAlvo' diretamente..." -ForegroundColor Cyan
    $nomeMilestone = $milestoneAlvo
} else {
    $nomeMilestone = $milestoneEncontrada.title
    Write-Host "Milestone encontrada: [$($milestoneEncontrada.number)] $nomeMilestone" -ForegroundColor Green
}

Write-Host "`nBuscando todas as issues abertas..." -ForegroundColor Cyan
$issues = gh issue list --repo $repo --state open --limit 100 --json number,title,milestone | ConvertFrom-Json

if ($issues.Count -eq 0) {
    Write-Host "Nenhuma issue aberta encontrada no repositorio." -ForegroundColor Yellow
    exit 0
}

Write-Host "Foram encontradas $($issues.Count) issues abertas." -ForegroundColor Cyan
Write-Host "Iniciando transferencia para a milestone '$nomeMilestone'..." -ForegroundColor Cyan

foreach ($issue in $issues) {
    $milestoneAtual = if ($issue.milestone) { $issue.milestone.title } else { "Sem milestone" }
    Write-Host "`nProcessando Issue #$($issue.number): '$($issue.title)'" -ForegroundColor White
    Write-Host "  Milestone anterior: $milestoneAtual" -ForegroundColor DarkGray
    
    gh issue edit $issue.number --repo $repo --milestone $nomeMilestone

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  -> Transferida com sucesso para '$nomeMilestone'!" -ForegroundColor Green
    } else {
        Write-Warning "  -> Falha ao atualizar a Issue #$($issue.number)"
    }
}

Write-Host "`nConcluido! Todas as issues abertas foram transferidas com sucesso." -ForegroundColor Green
