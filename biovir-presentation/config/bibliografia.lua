--[[===========================================================================
  BIOVIR LAB — filtro: bibliografia automática
  ----------------------------------------------------------------------------
  COMO FUNCIONA

  Se existir um arquivo `refs.bib` ao lado do .qmd, este filtro:

    1. liga a bibliografia (equivale a escrever `bibliography: refs.bib`);
    2. aplica o estilo ABNT (config/abnt.csl);
    3. acrescenta, no fim da apresentação, um slide "Bibliografia" com as
       referências citadas.

  Se `refs.bib` NÃO existir, nada acontece — nem slide, nem erro. Ou seja:
  apresentação sem citação continua funcionando sem nenhuma configuração.

  COMO PERSONALIZAR (no YAML do seu .qmd)

    bibliography: minhas-referencias.bib   outro arquivo .bib
    csl: config/outro-estilo.csl           outro estilo de citação
    titulo-bibliografia: "Referências"     outro título para o slide
    bibliografia-automatica: false         não criar o slide automaticamente

  Para escolher ONDE o slide entra (por exemplo, antes do slide da equipe),
  escreva você mesmo no .qmd — o filtro detecta e não duplica:

      ## Bibliografia

      ::: {#refs}
      :::

  Citar no texto: [@silva2024] ou @silva2024.
===========================================================================]]--

local stringify = pandoc.utils.stringify

local BIB_PADRAO    = "refs.bib"
local CSL_PADRAO    = "config/abnt.csl"
local TITULO_PADRAO = "Bibliografia"

-- Estado partilhado entre a função Meta e a função Pandoc.
local ativo = false
local titulo = TITULO_PADRAO
local automatico = true

local function arquivo_existe(caminho)
  local f = io.open(caminho, "r")
  if f == nil then return false end
  f:close()
  return true
end

function Meta(meta)
  if meta["bibliografia-automatica"] ~= nil then
    automatico = stringify(meta["bibliografia-automatica"]) ~= "false"
  end

  if meta["titulo-bibliografia"] ~= nil then
    titulo = stringify(meta["titulo-bibliografia"])
  end

  -- 1. Bibliografia: respeita o que o autor declarou; senão procura refs.bib.
  if meta.bibliography ~= nil then
    ativo = true
  elseif arquivo_existe(BIB_PADRAO) then
    meta.bibliography = pandoc.MetaString(BIB_PADRAO)
    ativo = true
  end

  -- 2. Estilo ABNT por padrão, só quando há bibliografia.
  if ativo and meta.csl == nil and arquivo_existe(CSL_PADRAO) then
    meta.csl = pandoc.MetaString(CSL_PADRAO)
  end

  return meta
end

-- O autor já colocou ::: {#refs} em algum lugar?
local function ja_tem_slide(blocos)
  local encontrou = false

  pandoc.walk_block(pandoc.Div(blocos), {
    Div = function(el)
      if el.identifier == "refs" then encontrou = true end
    end,
  })

  return encontrou
end

function Pandoc(doc)
  if not ativo or not automatico then return nil end
  if ja_tem_slide(doc.blocks) then return nil end

  local blocos = doc.blocks

  -- "## Bibliografia" (nível 2 = um slide) seguido do contêiner das
  -- referências, que o citeproc preenche.
  blocos:insert(pandoc.Header(2, pandoc.Str(titulo),
    pandoc.Attr("bibliografia", { "bibliografia", "scrollable", "smaller" })))
  blocos:insert(pandoc.Div({}, pandoc.Attr("refs")))

  return pandoc.Pandoc(blocos, doc.meta)
end

-- Meta precisa rodar antes de Pandoc.
return {
  { Meta = Meta },
  { Pandoc = Pandoc },
}
