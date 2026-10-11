#let source = json(__RESUME_DATA_PATH__)

#let accent = rgb("#8b5e35")

#let with-default(value, fallback) = if value == none { fallback } else { value }
#let text-of(value) = with-default(value, "")
#let list-of(value) = with-default(value, ())
#let item-of(item, key) = text-of(item.at(key, default: ""))
#let markup-text(val) = if type(val) == str { eval(val, mode: "markup") } else { val }

#let link-or-text(label, url) = if url == "" { [#label] } else { link(url)[#label] }
#let entry-title(entry) = link-or-text(item-of(entry, "title"), item-of(entry, "url"))

#let bullets-of(entry) = list-of(entry.at("bullets", default: ())).map(item => text-of(item)).filter(item => item != "")

#let contact-items = list-of(source.at("contactItems", default: ()))
#let profile-items = list-of(source.at("profileItems", default: ()))
#let custom-field-items = list-of(source.at("customFieldItems", default: ()))
#let section-titles = with-default(source.at("sectionTitles", default: (:)), (:))
#let title-of(key, fallback) = text-of(section-titles.at(key, default: fallback))

#set page(paper: "a4", margin: (x: 0.7in, y: 0.6in))
#set text(font: "Libertinus Serif", size: 10pt, lang: "en")
#set par(leading: 0.58em, justify: true)
#show link: set text(fill: accent)

#let section(title) = [
  #v(10pt)
  #text(size: 10.5pt, weight: "bold", fill: accent, tracking: 0.14em)[#upper(title)]
  #v(-2pt)
  #line(length: 100%, stroke: 0.6pt + accent)
  #v(5pt)
]

#let entry(entry, show-bullets: true) = [
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    text(weight: "bold")[#entry-title(entry)],
    text(size: 9pt)[#item-of(entry, "date")],
  )
  #let subtitle = item-of(entry, "subtitle")
  #let secondary = item-of(entry, "secondarySubtitle")
  #if subtitle != "" or secondary != "" [
    #emph[#subtitle]#if secondary != "" [ #h(1fr) #text(size: 9pt)[#secondary]]
  ]
  #if show-bullets [
    #let bullets = bullets-of(entry)
    #if bullets.len() > 0 [
      #set text(size: 9.5pt)
      #list(..bullets.map(b => markup-text(b)))
    ]
  ]
  #v(0.5em)
]

#let entries-section(key, fallback, data) = if data.len() > 0 {
  section(title-of(key, fallback))
  for e in data { entry(e) }
}

#let line-entry(label, value) = [
  #text(weight: "bold")[#label]#h(5pt)#value \
]

#let picture = with-default(source.at("picture", default: (:)), (:))
#let picture-path = text-of(picture.at("renderPath", default: ""))
#if picture-path != "" and with-default(picture.at("hidden", default: true), true) == false {
  align(center)[#image(picture-path, width: with-default(picture.at("size", default: 80), 80) * 1pt)]
  v(6pt)
}

#align(center)[
  #text(size: 22pt, weight: "bold", fill: accent)[#text-of(source.at("name", default: ""))] \
  #let headline = text-of(source.at("headline", default: ""))
  #if headline != "" [#text(size: 10pt)[#headline] \ ]
  #let location = text-of(source.at("location", default: ""))
  #if location != "" [#text(size: 8.8pt)[#location] \ ]
  #let contacts = contact-items.map(c => link-or-text(item-of(c, "text"), item-of(c, "url")))
  #if contacts.len() > 0 [#text(size: 8.8pt)[#for (i, c) in contacts.enumerate() [#if i > 0 [ #sym.dot.c ]#c]]]
]

#v(4pt)

#let summary = text-of(source.at("summary", default: ""))
#if summary != "" {
  section(title-of("summary", "Summary"))
  markup-text(summary)
}

#entries-section("experience", "Experience", list-of(source.at("experience", default: ())))
#entries-section("education", "Education", list-of(source.at("education", default: ())))
#entries-section("projects", "Projects", list-of(source.at("projects", default: ())))

#let skill-groups = list-of(source.at("skillGroups", default: ()))
#if skill-groups.len() > 0 {
  section(title-of("skills", "Skills"))
  for g in skill-groups {
    line-entry(
      [#item-of(g, "name"):],
      list-of(g.at("keywords", default: ())).join(", "),
    )
  }
}

#let languages = list-of(source.at("languages", default: ()))
#if languages.len() > 0 {
  section(title-of("languages", "Languages"))
  for l in languages {
    let fluency = item-of(l, "fluency")
    line-entry([#item-of(l, "language")], if fluency != "" { fluency } else { [] })
  }
}

#let interests = list-of(source.at("interests", default: ()))
#if interests.len() > 0 {
  section(title-of("interests", "Interests"))
  for i in interests {
    line-entry([#item-of(i, "name")], list-of(i.at("keywords", default: ())).join(", "))
  }
}

#let profiles = profile-items
#if profiles.len() > 0 {
  section(title-of("profiles", "Profiles"))
  for p in profiles {
    let username = item-of(p, "username")
    let url = item-of(p, "url")
    line-entry([#item-of(p, "network")], link-or-text(if username != "" { username } else { url }, url))
  }
}

#if custom-field-items.len() > 0 {
  section(title-of("customFields", "Highlights"))
  for c in custom-field-items {
    let title = item-of(c, "title")
    let value = link-or-text(item-of(c, "text"), item-of(c, "url"))
    if title != "" and title != item-of(c, "text") {
      line-entry([#title], value)
    } else {
      [#value \ ]
    }
  }
}

#entries-section("awards", "Awards", list-of(source.at("awards", default: ())))
#entries-section("certifications", "Certifications", list-of(source.at("certifications", default: ())))
#entries-section("publications", "Publications", list-of(source.at("publications", default: ())))
#entries-section("volunteer", "Volunteer", list-of(source.at("volunteer", default: ())))
#entries-section("references", "References", list-of(source.at("references", default: ())))
