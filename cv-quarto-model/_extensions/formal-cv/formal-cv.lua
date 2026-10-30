-- formal-cv.lua
-- Turns simple Markdown blocks into the template's Typst components:
--
--   ::: {.entry title="..." org="..." date="..." location="..." link="..." tags="A, B, C"}
--   Free Markdown text and bullet lists.
--   :::
--
--   ::: {.pub title="..." authors="..." venue="..." date="..." doi="..."}
--   :::
--
-- Attribute values may contain inline Markdown (**bold**, *italic*, `code`).

local function typst_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- inline Markdown -> Typst content block "[...]"
local function typst_content(s)
  local doc = pandoc.read(s, 'markdown')
  local inlines = pandoc.utils.blocks_to_inlines(doc.blocks)
  local out = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), 'typst')
  return '[' .. out:gsub('%s+$', '') .. ']'
end

local function call(fn, attrs, content_fields, string_fields)
  local args = {}
  for _, key in ipairs(content_fields) do
    local v = attrs[key]
    if v and v ~= '' then table.insert(args, key .. ': ' .. typst_content(v)) end
  end
  for key, param in pairs(string_fields) do
    local v = attrs[key]
    if v and v ~= '' then table.insert(args, param .. ': ' .. typst_string(v)) end
  end
  if fn == 'cv-entry' and attrs.tags and attrs.tags ~= '' then
    local items = {}
    for tag in attrs.tags:gmatch('[^,]+') do
      tag = tag:gsub('^%s+', ''):gsub('%s+$', '')
      if tag ~= '' then table.insert(items, typst_content(tag)) end
    end
    table.insert(args, 'tags: (' .. table.concat(items, ', ') .. ',)')
  end
  return '#' .. fn .. '(' .. table.concat(args, ', ') .. ')'
end

-- YAML fields that must reach Typst as plain strings (paths, colours, icons, URLs)
local raw_keys = {
  photo = true, icon = true, url = true, level = true, theme = true, typeface = true,
  accent = true, ['sidebar-color'] = true, ['heading-font'] = true, ['body-font'] = true,
  ['photo-shape'] = true, ['sidebar-width'] = true, fontsize = true, ['page-footer'] = true,
}

local function rawify(meta)
  local t = pandoc.utils.type(meta)
  if t == 'table' or t == 'Meta' then
    for k, v in pairs(meta) do
      if raw_keys[k] and pandoc.utils.type(v) ~= 'table' then
        meta[k] = pandoc.RawInline('typst', pandoc.utils.stringify(v))
      else
        meta[k] = rawify(v)
      end
    end
  elseif t == 'List' then
    for i, v in ipairs(meta) do meta[i] = rawify(v) end
  end
  return meta
end

return {
  {
    Meta = function(meta)
      if meta.sidebar then meta.sidebar = rawify(meta.sidebar) end
      if meta.cv then meta.cv = rawify(meta.cv) end
      return meta
    end,

    Div = function(el)
      if not quarto.doc.is_format('typst') then return nil end
      local a = el.attributes

      if el.classes:includes('entry') then
        local head = call('cv-entry', a, { 'title', 'org', 'date', 'location' }, { link = 'link-url' })
        local blocks = { pandoc.RawBlock('typst', head .. '[') }
        for _, b in ipairs(el.content) do table.insert(blocks, b) end
        table.insert(blocks, pandoc.RawBlock('typst', ']'))
        return blocks
      end

      if el.classes:includes('pub') then
        return pandoc.RawBlock('typst',
          call('cv-pub', a, { 'title', 'authors', 'venue', 'date' }, { doi = 'doi', link = 'link-url' }))
      end
    end,
  },
}
