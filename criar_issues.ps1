# Script para criacao automatica de issues no GitHub via GitHub CLI (gh)
# Certifique-se de estar autenticado com: gh auth login

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repo = "lfo-oliveira/sete-alegrias-de-maria"

Write-Host "Verificando autenticacao com o GitHub CLI..." -ForegroundColor Cyan
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Voce precisa se autenticar no GitHub CLI primeiro."
    Write-Host "Execute no terminal: gh auth login" -ForegroundColor Yellow
    exit 1
}

$issues = @(
    @{
        Title = "fix(terco): corrigir salto duplo no swipe e inverter direcao para padrao de virar pagina"
        Labels = @("bug")
        Body = @"
### Descricao do Problema
No arquivo `lib/features/terco/presentation/terco_page.dart`, o listener `onHorizontalDragEnd` possui chamadas duplicadas para `controle.avancar()` e `controle.voltar()`, fazendo com que cada gesto pule 2 passos de uma vez.
Alem disso, a direcao atual do gesto esta invertida em relacao ao padrao mobile (arrastar para a direita avanca, em vez de voltar).

### O que fazer
1. Em `onHorizontalDragEnd`, remover o segundo bloco `if (paraDireita)` / `if (paraEsquerda)`, mantendo apenas a chamada via `_avancarComFeedback` e `_voltarComFeedback`.
2. Adequar a direcao do swipe ao padrao universal de leitura:
   - **Deslizar para a esquerda (<-):** Avancar para a proxima oracao (`arrastoX < -40 || velocidade < -120`).
   - **Deslizar para a direita (->):** Voltar para a oracao anterior (`arrastoX > 40 || velocidade > 120`).

### Criterios de Aceitacao
- [ ] Deslizar para a esquerda avanca exatamente 1 passo.
- [ ] Deslizar para a direita volta exatamente 1 passo.
- [ ] O feedback tatil continua sendo acionado no avanco e no retorno.
"@
    },
    @{
        Title = "feat(terco): acionar feedback tatil ao tocar nos botoes Voltar e Proxima"
        Labels = @("enhancement")
        Body = @"
### Descricao do Problema
O feedback tatil inteligente implementado recentemente so e disparado ao usar o gesto de arrastar (swipe). Quando o fiel toca nos botoes inferiores "Voltar" ou "Proxima", o app chama diretamente `controle.voltar` e `controle.avancar`, sem vibrar.

### O que fazer
1. Atualizar o `onPressed` do botao **Voltar** para chamar `_voltarComFeedback(estado, controle)`.
2. Atualizar o `onPressed` do botao **Proxima** para chamar `_avancarComFeedback(estado, controle)`.
3. Garantir vibracao dupla/conclusiva caso o terco seja finalizado no botao "Concluir".

### Criterios de Aceitacao
- [ ] Tocar em "Proxima" produz a vibracao suave (ou firme ao fim da dezena).
- [ ] Tocar em "Voltar" produz a vibracao de clique.
- [ ] Botoes desabilitados ou na primeira/ultima tela nao disparam vibracao indevida.
"@
    },
    @{
        Title = "refactor(terco): modularizar IndicadorContas e remover docstring duplicada"
        Labels = @("enhancement")
        Body = @"
### Motivacao
O arquivo `terco_page.dart` ultrapassou 300 linhas, contendo logica de exibicao, animacao de contas do terco e widgets auxiliares. Alem disso, a documentacao da classe `TercoPage` esta duplicada.

### O que fazer
1. Criar `lib/features/terco/presentation/indicador_contas.dart` e mover `_IndicadorContas` e `_Conta`.
2. Importar o novo componente em `terco_page.dart`.
3. Remover a linha de docstring duplicada no topo de `TercoPage`:
   ````dart
   /// Tela de oracao: mostra o passo atual e os botoes Voltar / Proxima.
   /// Tela de oracao: mostra o passo atual e os botoes Voltar / Proxima.
   ````

### Criterios de Aceitacao
- [ ] `terco_page.dart` mais enxuto e manutenivel.
- [ ] `IndicadorContas` reutilizavel e com testes de widget se aplicavel.
"@
    },
    @{
        Title = "feat(ui): implementar transicao suave (fade/slide) na troca de oracoes"
        Labels = @("enhancement")
        Body = @"
### Motivacao
Atualmente, ao avancar ou voltar um passo do terco, o texto e substituido de forma instantanea (seca), o que pode causar fadiga visual durante uma oracao prolongada.

### O que fazer
- Envolver o `_ConteudoDoPasso` em um `AnimatedSwitcher` com uma animacao suave de fade ou transicao horizontal discreta (200ms a 300ms).
- Preservar o reset de rolagem para o topo (`SingleChildScrollView` com `ValueKey(estado.indice)`).

### Criterios de Aceitacao
- [ ] A troca entre oracoes e meditacoes ocorre de forma suave e contemplativa.
- [ ] A rolagem do texto continua sendo resetada para o topo a cada novo passo.
"@
    },
    @{
        Title = "feat(config): permitir desativar feedback tatil de vibracao"
        Labels = @("enhancement")
        Body = @"
### Motivacao
Embora o feedback tatil seja muito util, ao rezar em ambientes de silencio absoluto (capela, quarto a noite) ou com o celular apoiado sobre superficies rigidas, a vibracao pode causar ruido incomodo.

### O que fazer
1. Criar configuracao no repositorio de preferencias para salvar se a vibracao esta ativa (padrao: `true`).
2. Adicionar opcao no menu de configuracoes/AppBar (ou dialog de preferencias) para alternar o feedback tatil.
3. Condicionar as chamadas de `HapticFeedback` ao estado dessa configuracao.

### Criterios de Aceitacao
- [ ] Fiel pode desativar a vibracao a qualquer momento.
- [ ] Ao desativar, avancar passos ou tocar botoes nao emite vibracao.
- [ ] Preferencia persiste entre aberturas do app e e incluida no backup.
"@
    },
    @{
        Title = "feat(audio): adicionar seletor de velocidade de reproducao (0.8x, 1.0x, 1.2x)"
        Labels = @("enhancement")
        Body = @"
### Motivacao
O ritmo de oracao varia entre os fieis. Alguns preferem um ritmo mais pausado e meditativo (especialmente idosos), enquanto outros preferem um ritmo ligeiramente mais agil.

### O que fazer
1. Expor controle de velocidade no `PlayerAudio` / `AudioController` utilizando o metodo nativo `setSpeed()` do `just_audio`.
2. Adicionar botao compacto ou menu popup nos `ControlesAudio` com opcoes: `0.8x`, `1.0x`, `1.2x`.
3. Salvar a velocidade escolhida nas preferencias para os proximos audios.

### Criterios de Aceitacao
- [ ] O audio respeita a velocidade selecionada.
- [ ] O seletor fica integrado harmoniosamente aos controles de audio existentes.
"@
    },
    @{
        Title = "feat(terco): permitir compartilhar meditacao da alegria com share_plus"
        Labels = @("enhancement")
        Body = @"
### Motivacao
O app ja possui a dependencia `share_plus`. Permitir o compartilhamento do trecho biblico e reflexao da alegria do dia incentiva a evangelizacao e o envio de intencoes para amigos e grupos de oracao.

### O que fazer
1. Nos passos do tipo `TipoPasso.meditacao`, exibir um botao discreto de compartilhamento (icone `Icons.share_outlined`).
2. Ao tocar, formatar o texto com o titulo da alegria, referencia biblica, texto e uma mensagem convidando a rezar.
3. Disparar o compartilhamento nativo via `SharePlus` com tratamento para `sharePositionOrigin` (iPad/iOS).

### Criterios de Aceitacao
- [ ] Texto formatado adequadamente no WhatsApp, Telegram e outros apps.
- [ ] Funciona em Android e iOS/iPadOS sem travar.
"@
    },
    @{
        Title = "feat(ui): exibir contador do progresso geral no terco (ex: Passo X de Y)"
        Labels = @("enhancement")
        Body = @"
### Motivacao
A barra de progresso no topo indica visualmente o andamento, mas o fiel nao sabe com precisao em qual etapa do terco se encontra (ex: inicio, meio ou fim das 7 alegrias) a menos que esteja em uma Ave-Maria.

### O que fazer
- Adicionar uma indicacao sutil e discreta (ex: proxima a barra de progresso ou no rodape) mostrando o passo atual em relacao ao total: `Passo ${estado.indice + 1} de ${estado.passos.length}`.
- Alternativamente, indicar a dezena atual (ex: `Alegria 3 de 7`).

### Criterios de Aceitacao
- [ ] O fiel consegue estimar quanto falta para o termino do terco.
- [ ] O layout permanece limpo e sem poluição visual.
"@
    }
)

Write-Host "Criando $($issues.Count) issues no repositorio $repo..." -ForegroundColor Cyan

foreach ($item in $issues) {
    Write-Host "`nCriando: $($item.Title)..." -ForegroundColor Yellow
    
    $labelsArgs = @()
    foreach ($lbl in $item.Labels) {
        $labelsArgs += @("--label", $lbl)
    }

    gh issue create `
        --repo $repo `
        --title $item.Title `
        --body $item.Body `
        @labelsArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK!" -ForegroundColor Green
    } else {
        Write-Warning "Falha ao criar esta issue. Tentando sem labels..."
        gh issue create `
            --repo $repo `
            --title $item.Title `
            --body $item.Body
    }
}

Write-Host "`nConcluido! Todas as issues foram processadas." -ForegroundColor Green

