# Modelo de apresentações — Biovir Lab

Modelo Quarto + reveal.js para os seminários e defesas do laboratório.
Fundo branco, acentos `#304ea1` / `#326db5`, fontes locais (funciona sem internet).

## Começar

```bash
cd biovir-presentation
cp modelo-apresentacao.qmd minha-apresentacao.qmd
quarto preview minha-apresentacao.qmd
```

O tutorial completo é uma apresentação: `quarto render tutorial.qmd` e abra
`tutorial.html`.

## Estrutura

| Caminho | Para que serve |
|---|---|
| `_quarto.yml` | Configuração de todas as apresentações (tema, logo, rodapé, navegação) |
| `modelo-apresentacao.qmd` | Ponto de partida — copie este arquivo |
| `tutorial.qmd` | Guia de uso do Quarto, em português, em formato de slides |
| `styles/variaveis.scss` | **Cores e fontes** — comece por aqui para mudar o visual |
| `styles/fonts.scss` | Declaração `@font-face` das fontes locais |
| `styles/biovir.scss` | Tema base: tipografia, listas, tabelas, código, rodapé |
| `styles/componentes.scss` | Capa, divisores, caixas, cartões, números, slide da equipe |
| `config/titulos-em-blocos.lua` | Impede que títulos dentro de blocos virem slides (ver abaixo) |
| `fonts/` | `.woff2` + licenças OFL |
| `assets/` | Logos e foto da equipe |

## Tipografia

| Papel | Fonte | Licença |
|---|---|---|
| Títulos | Space Grotesk | SIL OFL |
| Texto | Inter | SIL OFL |
| Código | JetBrains Mono | SIL OFL |

São fontes variáveis: um `.woff2` por estilo cobre toda a faixa de pesos
(~590 kB no total). Licenças em `fonts/OFL-*.txt`.

## Assets

Os SVGs originais vinham com um perfil de cor ICC de 937 kB embutido, que foi
removido — os arquivos usados pelo modelo são vetores de verdade:

- `assets/logo-vertical-center.svg` (21 kB) — capa
- `assets/logo-virus.svg` (13 kB) — cápsula fixa no canto de cada slide
- `assets/logo-horizontal-small.png` — uso livre em slides de conteúdo
- `assets/team-complete.png` — slide final

Os originais foram mantidos e não são referenciados pelo modelo.

## Componentes

```markdown
::: {.destaque}        ideia central
::: {.caixa}           bloco neutro com contorno
::: {.destaque-forte}  afirmação de máximo peso (fundo azul)
::: {.cartoes} + ::: {.cartao}   grade de cartões
::: {.numero}          número grande + legenda
[texto]{.rotulo}       etiqueta em pílula
[texto]{.marca}        grifo azul

# Seção {.divisor background-color="#304ea1"}   divisor com faixa azul
# Seção {.divisor-claro}                        divisor em fundo branco
## Fim {.equipe background-image="assets/team-complete.png" ...}
```

## Cuidado: títulos dentro de `:::`

Um fenced div que **começa com um heading** é promovido pelo pandoc a
`<section>`, ou seja, a um slide. O reveal.js passa a tratá-lo como pilha
vertical, perde a contagem de índices e a apresentação **volta sozinha ao
início**.

`config/titulos-em-blocos.lua` já resolve isso nos componentes do modelo
(`.cartao`, `.caixa`, `.destaque`, `.destaque-forte`, `.numero`, `.equipe`),
convertendo o heading em `<span class="titulo-bloco">`. Em divs próprios,
use `**Título**` em vez de `### Título`.

`_quarto.yml` também define `navigation-mode: linear`, para que ←/→ percorram
todos os slides na ordem do arquivo — sem isso, a seta direita pula a seção
inteira.

## Exportar

- **PDF**: abra o `.html`, acrescente `?print-pdf` na URL, `Cmd/Ctrl+P` →
  margens *Nenhuma*, marque *Gráficos de segundo plano*.
- **Arquivo único** (pen drive, e-mail): acrescente `embed-resources: true`
  ao bloco `format: revealjs:` do seu `.qmd`.

## Código executável

Os dois `.qmd` deste modelo são só texto — renderizam sem R nem Python.
Para executar chunks (` ```{r} ` ou ` ```{python} `), instale o `knitr` ou o
`jupyter` e confirme com `quarto check`.
