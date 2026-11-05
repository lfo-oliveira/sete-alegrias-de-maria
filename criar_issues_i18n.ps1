# Script para criacao automatica das issues de internacionalizacao (i18n) no GitHub via GitHub CLI (gh)
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
        Title = "feat(i18n): configurar infraestrutura de internacionalizacao com flutter_localizations e ARB"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
Preparar o aplicativo para suportar multiplos idiomas na interface (botoes, dialogos, titulos e avisos) utilizando o padrao oficial do Flutter (`generate: true` + `.arb`).

### O que fazer
1. Adicionar `generate: true` na secao `flutter:` do `pubspec.yaml`.
2. Criar `l10n.yaml` na raiz do projeto apontando para `lib/l10n` e `app_pt.arb`.
3. Criar `lib/l10n/app_pt.arb` contendo todas as strings atuais da interface em portugues.
4. Substituir os textos literais nos widgets (`home_page.dart`, `terco_page.dart`, `backup_page.dart`, etc.) por chamadas a `AppLocalizations.of(context)!`.
5. Atualizar `app.dart` para registrar `AppLocalizations.delegate`.

### Criterios de Aceitacao
- [ ] O app compila e exibe todas as strings da interface atraves do `AppLocalizations`.
- [ ] Nenhuma string de interface permanece hardcoded em widgets.
"@
    },
    @{
        Title = "feat(i18n): adaptar ConteudoRepository para carregar oracoes e alegrias por idioma"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
Atualmente, as oracoes e reflexoes biblicas estao fixas em `assets/content/oracoes.json` e `assets/content/alegrias.json`. Para permitir outros idiomas, a leitura de conteudo deve respeitar a lingua ativa.

### O que fazer
1. Reorganizar a estrutura de arquivos para pastas por codigo de idioma:
   - `assets/content/pt/oracoes.json`
   - `assets/content/pt/alegrias.json`
2. Atualizar o `pubspec.yaml` com os novos caminhos de assets.
3. Modificar `ConteudoRepository.carregar(String idioma)` para ler do diretorio correspondente ao idioma ativo, com fallback para `pt` se o arquivo nao existir.
4. Conectar o `conteudoProvider` ao idioma selecionado no app.

### Criterios de Aceitacao
- [ ] `ConteudoRepository` carrega o arquivo da lingua solicitada.
- [ ] Se o idioma selecionado nao tiver JSON traduzido, o app exibe a versao em portugues sem quebrar.
"@
    },
    @{
        Title = "feat(config): adicionar seletor manual de idioma e deteccao automatica do sistema"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
O fiel deve poder escolher se deseja utilizar o aplicativo no idioma padrao do seu celular ou selecionar manualmente outro idioma de preferencia (ex: rezar o terco em Espanhol ou Latim mesmo com o celular em Portugues).

### O que fazer
1. Criar `IdiomaController` com Riverpod para gerenciar o `Locale?` ativo (nulo = padrao do sistema).
2. Salvar a preferencia do usuario no `SharedPreferences` (e incluir no backup).
3. Adicionar botao/menu de selecao de idioma no AppBar ou tela de configuracoes.
4. Passar o `locale` dinamico para o `MaterialApp` em `app.dart`.

### Criterios de Aceitacao
- [ ] Por padrao, o app detecta o idioma do aparelho.
- [ ] O usuario pode forcar um idioma especifico.
- [ ] A escolha persiste ao fechar e reabrir o app.
"@
    },
    @{
        Title = "feat(i18n): adicionar traducao completa para Espanhol (es)"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
A devocao a Coroa Franciscana (*Corona de las Siete Alegrias de la Santisima Virgen Maria*) e muito forte em paises hispanicos e na America Latina.

### O que fazer
1. Criar `lib/l10n/app_es.arb` com a traducao de todos os textos da interface.
2. Criar `assets/content/es/oracoes.json` com as oracoes tradicionais em espanhol:
   - Senal de la Cruz, Credo, Padre Nuestro, Ave Maria, Gloria al Padre, Salve Regina, etc.
3. Criar `assets/content/es/alegrias.json` com os titulos, referencias biblicas e meditacoes das 7 alegrias em espanhol.
4. Registrar o `Locale('es', '')` no `MaterialApp`.

### Criterios de Aceitacao
- [ ] Ao selecionar Espanhol, interface e oracoes sao exibidas corretamente em espanhol catolico tradicional.
"@
    },
    @{
        Title = "feat(i18n): adicionar traducao completa para Ingles (en)"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
Disponibilizar o aplicativo globalmente para paises de lingua inglesa (*The Franciscan Crown / The Rosary of the Seven Joys*).

### O que fazer
1. Criar `lib/l10n/app_en.arb` com as traducoes da interface.
2. Criar `assets/content/en/oracoes.json` com as oracoes tradicionais em ingles (*Sign of the Cross, Apostles' Creed, Our Father, Hail Mary, Glory Be, Hail Holy Queen*, etc.).
3. Criar `assets/content/en/alegrias.json` com os 7 misterios/alegrias franciscanas e reflexoes em ingles.
4. Registrar o `Locale('en', '')` no `MaterialApp`.

### Criterios de Aceitacao
- [ ] App totalmente funcional e legivel em ingles.
"@
    },
    @{
        Title = "feat(i18n): adicionar oracoes tradicionais em Latim (la)"
        Labels = @("enhancement", "i18n")
        Body = @"
### Motivacao
O Latim e a lingua universal da Igreja Catolica e muitos fieis tem grande devocao por rezar o Terco e a Coroa Franciscana no seu idioma liturgico tradicional (*Pater Noster, Ave Maria, Gloria Patri, Salve Regina*).

### O que fazer
1. Criar `assets/content/la/oracoes.json` e `assets/content/la/alegrias.json` com os textos liturgicos da *Corona Septem Gaudiorum*.
2. Disponibilizar a opcao 'Latim' no seletor de oracao (mantendo a interface no idioma do celular ou em latim simplificado).

### Criterios de Aceitacao
- [ ] O fiel pode rezar o terco completo com as oracoes em latim classico da Igreja.
"@
    }
)

Write-Host "Criando $($issues.Count) issues de internacionalizacao no repositorio $repo..." -ForegroundColor Cyan

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
        Write-Warning "Falha com labels. Tentando criar sem labels..."
        gh issue create `
            --repo $repo `
            --title $item.Title `
            --body $item.Body
    }
}

Write-Host "`nConcluido! Todas as issues de traducao foram criadas." -ForegroundColor Green

