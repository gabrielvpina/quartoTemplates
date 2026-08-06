--[[===========================================================================
  BIOVIR LAB — shortcode {{< equipe >}}
  ----------------------------------------------------------------------------
  Monta o mosaico de fotos da equipe lendo `assets/members/` na hora de
  renderizar. A hierarquia vem dos SUBDIRETÓRIOS:

      assets/members/professor/eric.png
      assets/members/phd/pina.png
      assets/members/master/taty.png
      ...

  MANUTENÇÃO: para adicionar alguém, largue a foto na subpasta certa.
  Para remover, apague o arquivo. Não há lista para atualizar, nem no .qmd
  nem aqui — subpasta vazia simplesmente não aparece.

  Os títulos e a ORDEM dos grupos vêm de `_quarto.yml`, chave `equipe:`.
  Subpasta que exista no disco mas não esteja listada lá entra no fim, com
  o próprio nome da pasta como título.

  USO no .qmd:
      {{< equipe >}}                 mosaico completo, com rótulo de grupo
      {{< equipe titulos=false >}}   só as fotos, sem rótulo de grupo
      {{< equipe pasta=outra/pasta >}}

  Sem R e sem Python: roda no Lua que já vem embutido no Quarto.
===========================================================================]]--

local stringify = pandoc.utils.stringify

local PASTA_PADRAO = "assets/members"

local EXTENSOES_IMAGEM = {
  png = true, jpg = true, jpeg = true, webp = true, gif = true, svg = true,
}

-- Lista um diretório; devolve nil se ele não existir.
local function listar(caminho)
  local ok, itens = pcall(pandoc.system.list_directory, caminho)
  if not ok or type(itens) ~= "table" then return nil end
  return itens
end

local function eh_imagem(nome)
  local ext = nome:match("%.([%w]+)$")
  return ext ~= nil and EXTENSOES_IMAGEM[ext:lower()] == true
end

-- Fotos de um grupo, em ordem alfabética.
local function fotos_de(caminho)
  local itens = listar(caminho)
  if itens == nil then return nil end

  local fotos = {}
  for _, nome in ipairs(itens) do
    if eh_imagem(nome) then table.insert(fotos, nome) end
  end
  table.sort(fotos)
  return fotos
end

local function escapar(texto)
  return (texto:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
               :gsub('"', "&quot;"))
end

-- "undergraduate" -> "Undergraduate" (usado só como último recurso)
local function titulo_padrao(dir)
  return (dir:gsub("^%l", string.upper):gsub("[-_]", " "))
end

-- Lê `equipe:` do _quarto.yml e devolve { pasta = ..., grupos = {...} }
local function ler_config(meta)
  local cfg = { pasta = PASTA_PADRAO, grupos = {} }
  local eq = meta and meta.equipe
  if eq == nil then return cfg end

  if eq.pasta ~= nil then cfg.pasta = stringify(eq.pasta) end

  if eq.grupos ~= nil then
    for _, g in ipairs(eq.grupos) do
      local dir = g.dir and stringify(g.dir) or nil
      if dir ~= nil and dir ~= "" then
        table.insert(cfg.grupos, {
          dir = dir,
          titulo = g.titulo and stringify(g.titulo) or titulo_padrao(dir),
        })
      end
    end
  end

  return cfg
end

-- Junta os grupos configurados com os que só existem no disco.
local function montar_grupos(cfg)
  local grupos = {}
  local ja_visto = {}

  for _, g in ipairs(cfg.grupos) do
    ja_visto[g.dir] = true
    table.insert(grupos, g)
  end

  -- Subpastas não declaradas no _quarto.yml entram no fim, em ordem.
  local no_disco = listar(cfg.pasta) or {}
  table.sort(no_disco)
  for _, nome in ipairs(no_disco) do
    if not ja_visto[nome] and not nome:match("^%.")
       and listar(cfg.pasta .. "/" .. nome) ~= nil then
      table.insert(grupos, { dir = nome, titulo = titulo_padrao(nome) })
    end
  end

  return grupos
end

local function aviso(mensagem)
  quarto.log.warning("[equipe] " .. mensagem)
  return pandoc.RawBlock("html",
    '<div class="equipe-erro">⚠ ' .. escapar(mensagem) .. "</div>")
end

return {
  ["equipe"] = function(args, kwargs, meta)
    local cfg = ler_config(meta)

    -- kwargs sobrescrevem o _quarto.yml, por documento
    if kwargs["pasta"] ~= nil and stringify(kwargs["pasta"]) ~= "" then
      cfg.pasta = stringify(kwargs["pasta"])
    end
    local mostrar_titulos =
      kwargs["titulos"] == nil or stringify(kwargs["titulos"]) ~= "false"

    if listar(cfg.pasta) == nil then
      return aviso("pasta não encontrada: " .. cfg.pasta)
    end

    local html = { '<div class="mosaico">' }
    local total = 0

    for _, grupo in ipairs(montar_grupos(cfg)) do
      local caminho = cfg.pasta .. "/" .. grupo.dir
      local fotos = fotos_de(caminho)

      -- Pasta ausente ou vazia: o grupo simplesmente não aparece.
      if fotos ~= nil and #fotos > 0 then
        table.insert(html, '<div class="mosaico-grupo">')

        if mostrar_titulos then
          table.insert(html,
            '<p class="mosaico-titulo">' .. escapar(grupo.titulo)
            .. ' <span class="mosaico-contagem">' .. #fotos .. "</span></p>")
        end

        table.insert(html, '<div class="mosaico-fotos">')
        for _, foto in ipairs(fotos) do
          local src = escapar(caminho .. "/" .. foto)
          table.insert(html,
            '<img class="mosaico-foto" src="' .. src .. '" alt="Integrante do '
            .. escapar(grupo.titulo) .. '">')
          total = total + 1
        end
        table.insert(html, "</div></div>")
      end
    end

    table.insert(html, "</div>")

    if total == 0 then
      return aviso("nenhuma foto encontrada em " .. cfg.pasta)
    end

    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end,
}
