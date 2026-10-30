// =============================================================================
//  formal-cv — a sober, two-column CV template for Quarto + Typst
//  https://github.com/gabrielvpina/quartoTemplates
//  License: MIT (template code) · fonts and icons keep their own licenses
// =============================================================================

$icons.typ()$

// -----------------------------------------------------------------------------
//  Colour palettes
//  accent  : headings, skill bars, links, organisations
//  sidebar : background of the left column
//  muted   : dates, labels and secondary text
//  ink     : main text colour
// -----------------------------------------------------------------------------
#let cv-palettes = (
  navy:     (accent: rgb("#1F3A5F"), sidebar: rgb("#F2F4F7"), muted: rgb("#667085"), ink: rgb("#1D2433")),
  charcoal: (accent: rgb("#2E3440"), sidebar: rgb("#F3F3F1"), muted: rgb("#6B6F76"), ink: rgb("#1F2328")),
  slate:    (accent: rgb("#3B5B78"), sidebar: rgb("#F0F3F6"), muted: rgb("#687684"), ink: rgb("#1E2A36")),
  forest:   (accent: rgb("#2F5D50"), sidebar: rgb("#F1F5F2"), muted: rgb("#66736D"), ink: rgb("#1C2622")),
  teal:     (accent: rgb("#1D5C63"), sidebar: rgb("#EFF5F5"), muted: rgb("#617577"), ink: rgb("#172628")),
  burgundy: (accent: rgb("#6B2737"), sidebar: rgb("#F7F2F2"), muted: rgb("#7A6A6D"), ink: rgb("#2A1D20")),
  espresso: (accent: rgb("#5B4636"), sidebar: rgb("#F6F3EE"), muted: rgb("#7D7268"), ink: rgb("#2B241F")),
  graphite: (accent: rgb("#222222"), sidebar: rgb("#F2F2F2"), muted: rgb("#6E6E6E"), ink: rgb("#1A1A1A")),
)

#let cv-theme(name, accent: none, sidebar: none) = {
  let base = cv-palettes.at(name, default: cv-palettes.navy)
  if accent != none and accent != "" { base.accent = rgb(accent) }
  if sidebar != none and sidebar != "" { base.sidebar = rgb(sidebar) }
  base
}

// -----------------------------------------------------------------------------
//  Typeface presets
//  Source Sans 3 / Source Serif 4 ship with the extension (fonts/).
//  Libertinus Serif is embedded in Typst itself.
// -----------------------------------------------------------------------------
#let cv-typefaces = (
  classic:  (heading: "Source Serif 4",   body: "Source Sans 3"),
  modern:   (heading: "Source Sans 3",    body: "Source Sans 3"),
  serif:    (heading: "Source Serif 4",   body: "Source Serif 4"),
  academic: (heading: "Libertinus Serif", body: "Libertinus Serif"),
)

#let cv-fonts(name, heading: none, body: none) = {
  let base = cv-typefaces.at(name, default: cv-typefaces.classic)
  if heading != none and heading != "" { base.heading = heading }
  if body != none and body != "" { base.body = body }
  base
}

// -----------------------------------------------------------------------------
//  Small helpers
// -----------------------------------------------------------------------------
#let cv-icon(name, fill: black, size: 0.85em) = {
  let entry = fa-map.at(name, default: none)
  if entry == none { return [] }
  let (glyph, family) = entry
  let font = if family == "brands" { "Font Awesome 7 Brands" } else { "Font Awesome 7 Free Solid" }
  box(width: 1.25em, align(center, text(font: font, size: size, fill: fill, glyph)))
}

#let cv-is-set(value) = value != none and value != [] and value != ""

// -----------------------------------------------------------------------------
//  Sidebar components
// -----------------------------------------------------------------------------
#let cv-photo(path, theme, shape: "circle", size: 3.7cm) = {
  let radius = if shape == "circle" { 50% } else if shape == "rounded" { 8pt } else { 0pt }
  align(center, box(
    radius: radius, clip: true, stroke: 0.6pt + theme.accent.transparentize(60%),
    image(path, width: size, height: size, fit: "cover"),
  ))
  v(10pt)
}

#let cv-name(name, jobtitle, theme, fonts) = {
  set par(justify: false, leading: 0.45em)
  text(font: fonts.heading, size: 19pt, weight: "semibold", fill: theme.ink, name)
  if cv-is-set(jobtitle) {
    v(2pt)
    text(size: 10pt, fill: theme.accent, tracking: 0.02em, jobtitle)
  }
  v(8pt)
}

#let cv-info(icon, body, theme) = block(below: 4.5pt, grid(
  columns: (1.4em, 1fr), align: (center + horizon, left + horizon),
  cv-icon(icon, fill: theme.accent, size: 0.8em), text(size: 8.5pt, body),
))

#let cv-side-heading(title, theme, fonts) = {
  v(12pt)
  block(below: 7pt, {
    text(font: fonts.heading, size: 9.5pt, weight: "semibold", fill: theme.accent,
      tracking: 0.12em, upper(title))
    v(-5pt)
    line(length: 100%, stroke: 0.5pt + theme.accent.transparentize(65%))
  })
}

// level: 0–1, or 1–5 (values above 1 are read as "out of 5")
#let cv-skill(name, label, level, theme) = {
  block(below: 6.5pt, breakable: false, {
    grid(columns: (1fr, auto), text(size: 8.8pt, name), text(size: 7.8pt, fill: theme.muted, label))
    if level == none { return }
    let lvl = calc.clamp(if level > 1 { level / 5 } else { level }, 0, 1)
    v(-5pt)
    box(width: 100%, height: 2.2pt, radius: 1.1pt, fill: theme.muted.transparentize(80%),
      place(left, box(width: lvl * 100%, height: 2.2pt, radius: 1.1pt, fill: theme.accent.transparentize(15%))))
  })
}

#let cv-side-item(body, theme) = block(below: 4.5pt, grid(
  columns: (0.9em, 1fr),
  text(size: 8.5pt, fill: theme.accent, sym.dash.en), text(size: 8.5pt, body),
))

#let cv-tags(tags, theme) = block(below: 4pt, {
  set par(leading: 0.9em, justify: false)
  for t in tags {
    box(inset: (x: 4pt, y: 2pt), radius: 2pt, stroke: 0.5pt + theme.accent.transparentize(55%),
      text(size: 7.8pt, fill: theme.ink, t))
    h(3pt)
  }
})

#let cv-side-edu(degree, school, date, note, theme) = block(below: 8pt, breakable: false, {
  set par(justify: false, leading: 0.5em)
  if cv-is-set(date) { text(size: 7.8pt, fill: theme.muted, tracking: 0.04em, date); linebreak() }
  text(size: 8.8pt, weight: "semibold", degree)
  if cv-is-set(school) { linebreak(); text(size: 8.3pt, fill: theme.accent, school) }
  if cv-is-set(note) { linebreak(); text(size: 8pt, fill: theme.muted, style: "italic", note) }
})

#let cv-contact(icon, body, url, theme) = {
  let label = if cv-is-set(url) { link(url, body) } else { body }
  cv-info(icon, label, theme)
}

#let cv-side-text(body) = block(below: 4pt, text(size: 8.5pt, body))

// -----------------------------------------------------------------------------
//  Main-column components (used by the Lua filter for ::: {.entry} / {.pub})
// -----------------------------------------------------------------------------
// filled chips under an entry: ::: {.entry tags="Python, SQL, Dashboards"}
#let cv-entry-tags(tags, theme) = block(above: 5pt, {
  set par(leading: 0.85em, justify: false)
  for t in tags {
    box(inset: (x: 5pt, y: 2.4pt), radius: 2pt, fill: theme.accent.transparentize(8%),
      text(size: 7.6pt, weight: "semibold", fill: theme.sidebar.lighten(40%), tracking: 0.02em, t))
    h(3.5pt)
  }
})

#let _cv-entry(theme: none, fonts: none, title: none, org: none, date: none,
               location: none, link-url: none, tags: (), body) = {
  block(below: 11pt, breakable: true, {
    block(below: 4pt, breakable: false, sticky: true, {
      grid(columns: (1fr, auto), column-gutter: 8pt,
        text(size: 10.3pt, weight: "semibold", fill: theme.ink, title),
        if cv-is-set(date) { text(size: 8.5pt, fill: theme.muted, tracking: 0.03em, date) },
      )
      if cv-is-set(org) or cv-is-set(location) or cv-is-set(link-url) {
        v(-3pt)
        text(size: 9pt, {
          if cv-is-set(org) { text(fill: theme.accent, org) }
          if cv-is-set(location) {
            if cv-is-set(org) { text(fill: theme.muted, [ #sym.dot.c ]) }
            text(fill: theme.muted, location)
          }
          if cv-is-set(link-url) {
            h(4pt)
            link(link-url, text(fill: theme.muted, size: 8pt,
              [#cv-icon("arrow-up-right-from-square", fill: theme.muted, size: 0.75em)]))
          }
        })
      }
    })
    body
    if tags.len() > 0 { cv-entry-tags(tags, theme) }
  })
}

#let _cv-pub(theme: none, fonts: none, title: none, authors: none, venue: none,
             date: none, doi: none, link-url: none) = {
  let url = if cv-is-set(doi) { "https://doi.org/" + doi } else { link-url }
  block(below: 9pt, breakable: false, grid(
    columns: (3.4em, 1fr), column-gutter: 6pt,
    text(size: 8.5pt, fill: theme.muted, date),
    {
      set par(justify: false, leading: 0.5em)
      text(size: 9.5pt, weight: "semibold", fill: theme.ink, title)
      if cv-is-set(authors) { linebreak(); text(size: 8.6pt, authors) }
      if cv-is-set(venue) or cv-is-set(url) {
        linebreak()
        text(size: 8.6pt, {
          if cv-is-set(venue) { text(style: "italic", fill: theme.accent, venue) }
          if cv-is-set(doi) { text(fill: theme.muted, [ #sym.dot.c ]); link(url, text(fill: theme.muted, "doi:" + doi)) }
          else if cv-is-set(url) { text(fill: theme.muted, [ #sym.dot.c ]); link(url, text(fill: theme.muted, "link")) }
        })
      }
    },
  ))
}

// -----------------------------------------------------------------------------
//  Page layout
// -----------------------------------------------------------------------------
#let cv-layout(
  name: none,
  theme: none,
  fonts: none,
  sidebar: none,
  sidebar-width: 6.4cm,
  fontsize: 9.5pt,
  lang: "en",
  footer: true,
  doc,
) = {
  set document(title: name)
  set text(font: fonts.body, size: fontsize, fill: theme.ink, lang: lang)
  set par(justify: true, leading: 0.58em, spacing: 0.75em)
  set list(marker: text(fill: theme.accent, sym.dash.en), indent: 0pt, body-indent: 5pt, spacing: 0.5em)
  show list: set par(justify: false)
  show link: set text(fill: theme.accent)
  show strong: set text(weight: "semibold")

  // main-column section headings: "# Experience"
  show heading.where(level: 1): it => {
    v(6pt)
    block(below: 9pt, breakable: false, sticky: true, {
      text(font: fonts.heading, size: 12.5pt, weight: "semibold", fill: theme.accent, tracking: 0.04em, it.body)
      v(-6pt)
      line(length: 100%, stroke: 0.5pt + theme.accent.transparentize(65%))
    })
  }
  show heading.where(level: 2): it => block(above: 8pt, below: 6pt, sticky: true,
    text(font: fonts.heading, size: 10.5pt, weight: "semibold", fill: theme.ink, it.body))

  set page(
    paper: "a4",
    margin: (left: 0pt, right: 0pt, top: 1.25cm, bottom: 1.3cm),
    background: {
      place(top + left, rect(width: sidebar-width, height: 100%, fill: theme.sidebar))
      place(top + left, rect(width: 100%, height: 3pt, fill: theme.accent))
    },
    footer: if footer {
      context {
        let total = counter(page).final().first()
        if total > 1 {
          pad(left: sidebar-width + 0.8cm, right: 1.2cm, text(size: 7.5pt, fill: theme.muted,
            grid(columns: (1fr, auto), name, [#counter(page).display() / #total])))
        }
      }
    },
  )

  grid(
    columns: (sidebar-width, 1fr),
    inset: (col, row) => if col == 0 { (x: 0.75cm) } else { (left: 0.8cm, right: 1.2cm) },
    { set par(justify: false); sidebar },
    doc,
  )
}
