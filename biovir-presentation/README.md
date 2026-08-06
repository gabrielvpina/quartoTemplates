# Modelo de apresentações — Biovir Lab

Modelo Quarto + reveal.js para os seminários e defesas do laboratório.
Fundo branco, acentos `#304ea1` / `#326db5`, fontes locais e saída
**self-contained** (um `.html` único, que abre offline em qualquer máquina).

## Começar

```bash
cd biovir-presentation
cp modelo-apresentacao.qmd minha-apresentacao.qmd
quarto preview minha-apresentacao.qmd
```

O tutorial completo é uma apresentação: `quarto render tutorial.qmd`, depois
abra `tutorial.html`.

## Estrutura

| Caminho | Para que serve |
|---|---|
| `_quarto.yml` | Configuração de todas as apresentações (tema, logo, rodapé, navegação, grupos da equipe) |
| `modelo-apresentacao.qmd` | Ponto de partida — copie este arquivo |
| `tutorial.qmd` | Guia de uso do Quarto, em português, em formato de slides |
| `styles/variaveis.scss` | **Cores e fontes** — comece por aqui para mudar o visual |
| `styles/fonts.scss` | Declaração `@font-face` das fontes locais |
| `styles/biovir.scss` | Tema base: tipografia, listas, tabelas, código, rodapé |
| `styles/componentes.scss` | Capa, divisores, caixas, cartões, números, slide da equipe |
| `config/titulos-em-blocos.lua` | Impede que títulos dentro de blocos virem slides |
| `config/equipe.lua` | Shortcode `{{< equipe >}}`: monta o mosaico de fotos |
| `config/bibliografia.lua` | Liga citações e cria o slide "Bibliografia" quando existe `refs.bib` |
| `config/abnt.csl` | Estilo de citação ABNT (padrão) |
| `refs-exemplo.bib` | Renomeie para `refs.bib` para ativar as referências |
| `tools/otimizar-fotos.sh` | Reduz o peso das fotos da equipe |
| `fonts/` | `.woff2` + licenças OFL |
| `assets/` | Logos, foto coletiva e `members/` (fotos individuais) |

## Tipografia

| Papel | Fonte | Licença |
|---|---|---|
| Títulos | Space Grotesk | SIL OFL |
| Texto | Inter | SIL OFL |
| Código | JetBrains Mono | SIL OFL |

Fontes variáveis: um `.woff2` por estilo cobre toda a faixa de pesos
(~590 kB no total). Licenças em `fonts/OFL-*.txt`.

## Slide da equipe

O slide final combina duas seções **independentes**:

```markdown
## A equipe {.equipe-completa}

{{< equipe >}}          ← fotos, montadas automaticamente

::: {.nomes}            ← lista de nomes, editada à mão
- Fulano de Tal
:::
```

As fotos vêm dos subdiretórios de `assets/members/`, e a hierarquia é a
própria estrutura de pastas:

```
assets/members/
├── professor/      → Coordenação
├── researcher/     → Pesquisadores
├── phd/            → Doutorado
├── master/         → Mestrado
└── undergraduate/  → Graduação   (vazia: não aparece)
```

**Manutenção:** entrou alguém, largue a foto na subpasta certa; saiu, apague
o arquivo. Não existe lista de fotos para atualizar. Títulos e ordem dos
grupos ficam em `_quarto.yml`, chave `equipe:`; subpasta que exista no disco
mas não esteja lá aparece no fim, com o nome da própria pasta.

Grupos com até 4 fotos ganham a classe `compacto` e dividem uma linha com o
vizinho — é assim que Coordenação e Pesquisadores ficam lado a lado, o que
libera altura para as demais fotos serem maiores.

Variações: `{{< equipe titulos=false >}}` (só fotos) e
`{{< equipe pasta=assets/outra >}}`.

## Bibliografia

```bash
mv refs-exemplo.bib refs.bib
```

Só isso. A partir daí, todas as apresentações da pasta passam a ter citações
no padrão **ABNT** e um slide **Bibliografia** no fim, montado só com o que
foi citado. Sem `refs.bib`, nada aparece — nem slide, nem erro.

| No `.qmd` | Resultado |
|---|---|
| `[@silva2024]` | (Silva, 2024) |
| `@silva2024` | Silva (2024) |
| `[@silva2024, p. 42]` | (Silva, 2024, p. 42) |

Opcional, no YAML do documento: `bibliography:` (outro `.bib`),
`titulo-bibliografia:` (outro título), `csl:` (outro estilo),
`bibliografia-automatica: false` (não criar o slide). Para escolher onde o
slide entra, escreva `## Bibliografia` seguido de `::: {#refs}` `:::` — o
filtro detecta e não duplica.

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
```

## Armadilhas já resolvidas (não reintroduza)

**1. Título como primeira linha de um `:::`** — o pandoc promove o div a
`<section>`, ou seja, a um *slide*. O reveal.js passa a tratá-lo como pilha
vertical, perde a contagem de índices e a apresentação volta sozinha ao
início. `config/titulos-em-blocos.lua` resolve isso nos componentes do
modelo; em divs próprios, use `**Título**` em vez de `### Título`.

**2. Conteúdo antes do primeiro `##`** — vira um slide em branco, inclusive
comentários `<!-- -->`. Coloque anotações dentro do bloco YAML, onde `#` é
comentário.

**3. `padding` em `.column`** — o Quarto renderiza colunas como
`inline-block` e o reveal.js não define `box-sizing: border-box`. Em
content-box, `50% + padding` passa de 100% e a segunda coluna quebra para a
linha de baixo, deixando meia tela vazia. `componentes.scss` força
`border-box` em `.column`; não remova.

**4. `font-size` em elemento e filho** — regras que casam tanto no `<p>`
quanto no `<span>` dentro dele multiplicam o tamanho (2,2em × 2,2em ≈ 160px)
e os textos se sobrepõem. Ver o comentário em `.numero`.

**5. Altura dos slides** — o slide útil tem 924 × 616 px e o reveal.js corta
o excesso sem avisar. O `.equipe-completa` tem o orçamento de altura anotado
no SCSS; refaça a conta se mexer nos tamanhos.

`_quarto.yml` também define `navigation-mode: linear`, para que ←/→ percorram
todos os slides na ordem do arquivo — sem isso, um `#` cria pilha vertical e
a seta direita pula a seção inteira.

## Rodapé

Vem desligado. Para religá-lo, descomente `footer:` em `_quarto.yml`.

## Exportar

- **PDF**: abra o `.html`, acrescente `?print-pdf` na URL, `Cmd/Ctrl+P` →
  margens *Nenhuma*, marque *Gráficos de segundo plano*.
- **Arquivo único**: já é o padrão (`embed-resources: true`). Fontes, logos e
  fotos vão todos dentro do `.html`.

### Peso do arquivo

Com as fotos originais (450 px, ~250 kB cada), o `.html` fica em ~14 MB.
Como elas aparecem com ~68 px de lado, dá para reduzir muito sem perda
visível:

```bash
bash tools/otimizar-fotos.sh   # originais ficam em assets/members-originais/
quarto render
```

### Quadro-branco

O plugin `chalkboard` (teclas B/C, desenhar sobre o slide) **não é
compatível** com `embed-resources: true`. Se preferir o quadro ao arquivo
único, troque `embed-resources` para `false` e descomente o bloco
`chalkboard:` em `_quarto.yml`.

## Código executável

Os dois `.qmd` do modelo são só texto — renderizam sem R nem Python.
Para executar chunks (` ```{r} ` ou ` ```{python} `), instale o `knitr` ou o
`jupyter` e confirme com `quarto check`.
