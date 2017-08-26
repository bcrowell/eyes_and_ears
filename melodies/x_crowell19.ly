\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\new GrandStaff << \new Staff {
                \key c \major
                \time 3/4
                \clef violin
                   \relative c'' { c4 r d8 e | f2 e4 | r4 e8 d r4 | d2 c4 | c8 d e4 e | e8 d d4 d | d8 c r2 | c2.  \bar "||"}
              } % end staff
              \new Staff {
                 \key c \major
                 \clef bass
                   \relative c' { r4 c8 b r4 | a2 g4 | g4 r g | g2 a4 | a4 a a8 g | f4 f g8 a | b2 c4 | c2.}
              } % end staff
            >>
