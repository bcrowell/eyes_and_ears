\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\new GrandStaff << \new Staff {
                \key g \major
                \time 4/4
                \clef violin
                   \relative g' { \partial 4 r4 | r1 | r2. g4 \bar "|:" a4 b c d | d1 | e1 | d2. d4 | c4 d c c | b a g2 | fis1 | g2. g4 \bar ":|"}
              } % end staff
              \new Staff {
                 \key g \major
                 \clef bass
                   \relative g { \partial 4 g4 | a4 b c d | d1 | e1 | d2. d4 | c4 d c c | b a g2 | fis1 | g2. g4 | a4 b c d | d1 }
              } % end staff
            >>
