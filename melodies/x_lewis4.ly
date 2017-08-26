\version "2.14.0"
%{\header {
  composer = "L.R. Lewis" % 4
  enteredby = "B. Crowell"
  source = "Melodia: A Comprehensive Course in Sight-Singing, Samuel W. Cole and Leo R. Lewis, Oliver Ditson Co., Bryn Mawr, Pennsylvania, 1904"
}%}
\new GrandStaff << \new Staff {
    \key c \major
    \time 4/4
    \clef violin
       \relative g' { g2 a | b1 | c2 b | c1
                      \bar "||"}
  } % end staff
  \new Staff {
     \key c \major
     \clef bass
       \relative g { g1 | g2 f | e d | c1
                    }
  } % end staff
>>
