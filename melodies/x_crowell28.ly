\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\score{{\key g \minor
\time 4/4
%{\tempo 4=70
%}\clef bass
\relative d {
  d8^\markup{\column { "Largo" " " }} r g, r g' f es d | es c c16 d8.~ d8 e fis g |
  a8 r bes r a16 g8.~ g4 | a8 r d, r r2 |
  es4 g8 f es d c4 | d8 bes bes16 g'8.~ g8 fis g d | es8 r g r bes, r d r | g,1
  \bar "||"
}

}}