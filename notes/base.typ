#import "@preview/fletcher:0.5.0" as fletcher: *

#let note(doc) = [
  #set par(leading: 0.55em, justify: true)
  #set text(font: "New Computer Modern")

  #show heading: set block(above: 1.8em, below: 1.8em, inset: (x: -0.5em, y: 0em))

  #doc
]

#let def(doc) = block(
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  [
    *Definition:* \
    #doc
  ]
)