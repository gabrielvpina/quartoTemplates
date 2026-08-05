--[[===========================================================================
  BIOVIR LAB — filtro: títulos dentro de blocos
  ----------------------------------------------------------------------------
  PROBLEMA QUE ESTE ARQUIVO RESOLVE

  Quando um fenced div COMEÇA com um heading, por exemplo:

      ::: {.cartao}
      #### Coleta
      Origem das amostras.
      :::

  o pandoc promove esse div a <section> — isto é, a um SLIDE. O reveal.js
  passa a enxergar o slide que contém os cartões como uma "pilha vertical"
  de slides, a contagem de índices deixa de bater e a apresentação pula de
  volta para o início.

  SOLUÇÃO

  Antes de o pandoc dividir os slides, trocamos esses headings por um
  parágrafo com <span class="titulo-bloco titulo-N">. Visualmente idêntico
  (ver styles/componentes.scss), mas sem virar slide.

  Só age nos componentes do laboratório listados em ALVOS — divs do próprio
  Quarto (.columns, .callout-*, .notes...) não são tocados.
===========================================================================]]--

local ALVOS = {
  cartao          = true,
  caixa           = true,
  destaque        = true,
  ["destaque-forte"] = true,
  numero          = true,
  equipe          = true,
}

local function eh_alvo(el)
  for _, classe in ipairs(el.classes) do
    if ALVOS[classe] then return true end
  end
  return false
end

-- Percorre os blocos trocando Header por Para{Span}, inclusive em divs aninhados.
local function converter(blocos)
  local saida = pandoc.List()

  for _, bloco in ipairs(blocos) do
    if bloco.t == "Header" then
      local attr = pandoc.Attr(
        bloco.identifier,
        { "titulo-bloco", "titulo-" .. tostring(bloco.level) }
      )
      saida:insert(pandoc.Para({ pandoc.Span(bloco.content, attr) }))
    else
      if bloco.t == "Div" then
        bloco.content = converter(bloco.content)
      end
      saida:insert(bloco)
    end
  end

  return saida
end

function Div(el)
  if eh_alvo(el) then
    el.content = converter(el.content)
    return el
  end
end
