\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\score{{\key as \major
\time 4/4
%{\tempo 4=100
%}\relative es' {
  \partial 4*3
  es4 f g | as2 bes4 c | \times 2/3 {bes4 c bes} as4. g8 | f1 |
  r4 f4 g as | bes2 c4 des | \times 2/3 {c4 des c} bes4. as8 | as1
  \bar "||"
}

}}