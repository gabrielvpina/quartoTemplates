// Maps the YAML header of the .qmd onto the template above.

#let theme = cv-theme("$if(cv.theme)$$cv.theme$$else$navy$endif$"$if(cv.accent)$, accent: "$cv.accent$"$endif$$if(cv.sidebar-color)$, sidebar: "$cv.sidebar-color$"$endif$)
#let fonts = cv-fonts("$if(cv.typeface)$$cv.typeface$$else$classic$endif$"$if(cv.heading-font)$, heading: "$cv.heading-font$"$endif$$if(cv.body-font)$, body: "$cv.body-font$"$endif$)
#let cv-entry = _cv-entry.with(theme: theme, fonts: fonts)
#let cv-pub = _cv-pub.with(theme: theme, fonts: fonts)

#show: doc => cv-layout(
  name: [$name$],
  theme: theme,
  fonts: fonts,
$if(cv.sidebar-width)$
  sidebar-width: $cv.sidebar-width$,
$endif$
$if(cv.fontsize)$
  fontsize: $cv.fontsize$,
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(cv.page-footer)$
  footer: $cv.page-footer$,
$endif$
  sidebar: {
$if(sidebar.photo)$
    cv-photo("$sidebar.photo$", theme$if(cv.photo-shape)$, shape: "$cv.photo-shape$"$endif$)
$endif$
    cv-name([$name$], [$jobtitle$], theme, fonts)
$for(sidebar.info)$
    cv-info("$sidebar.info.icon$", [$sidebar.info.text$], theme)
$endfor$
$for(sidebar.sections)$
    cv-side-heading([$sidebar.sections.title$], theme, fonts)
$if(sidebar.sections.text)$
    cv-side-text([$sidebar.sections.text$])
$endif$
$for(sidebar.sections.skills)$
    cv-skill([$sidebar.sections.skills.name$], [$sidebar.sections.skills.label$], $if(sidebar.sections.skills.level)$$sidebar.sections.skills.level$$else$none$endif$, theme)
$endfor$
$if(sidebar.sections.tags)$
    cv-tags(($for(sidebar.sections.tags)$[$sidebar.sections.tags$], $endfor$), theme)
$endif$
$for(sidebar.sections.items)$
    cv-side-item([$sidebar.sections.items$], theme)
$endfor$
$for(sidebar.sections.education)$
    cv-side-edu([$sidebar.sections.education.degree$], [$sidebar.sections.education.school$], [$sidebar.sections.education.date$], [$sidebar.sections.education.note$], theme)
$endfor$
$for(sidebar.sections.contact)$
    cv-contact("$sidebar.sections.contact.icon$", [$sidebar.sections.contact.text$], "$sidebar.sections.contact.url$", theme)
$endfor$
$endfor$
  },
  doc,
)
