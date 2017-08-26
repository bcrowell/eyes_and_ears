\version "2.14.0"
%{\header {
  title = "folk song"
  composer = "anonymous"
  enteredby = "B. Crowell"
  source = "Ear-Training and Sight-Singing, George A. Wedge, Schirmer, New York, 1921"
}%}
\score{{\key as \major
\time 3/4
%{\tempo 4=90
%}\relative as' {
  as8 bes c4 des | es2 c4 | des2 es4 | c4 as r | as8 bes8 c4 des | es2 c4 | des2 es4 | bes2 c4 |
  as2 bes4 | es,2 r4 \mark \markup { \musicglyph #"scripts.segno" }
  es'2 c4 | es4 des bes | as c es | bes2 r4 | es2 c4 | es4 des bes | as8 bes c4 bes | as2 r4^\markup{\column { "Fine" " " }} |
  \time 3/8
  c8 c as | bes4 as8 | c4 as8 | bes4 as8 |   c8 c as | bes4 as8 | c4 as8 | bes4.^\markup{"D.S. al fine"}  | es,4.
  \bar "||"
}


}}