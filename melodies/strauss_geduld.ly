\version "2.14.0"
%{\header {
  title = "Not Yet"
  composer = "Richard Strauss"
  enteredby = "B. Crowell"
  source = "Forty Songs by Richard Strauss, ed. James Huneker, Oliver Ditson Co., 1910"
}%}
\score{{\key as \major
\time 6/8
%{\tempo 4=90
%}\relative f' {
  \partial 8
  es8^\markup{\column { "Molto mesto" " " }} |
  es4. r4 as8 | es4. r4 es8 | c'4 c8 bes4 as8 | as4. g4. |
  r4 g8 g4 g8 | g4. es4. | bes'4 bes8 as4 g8 | as4.~as4
  \bar "||"
}

}}