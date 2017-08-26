\version "2.14.0"
%{\header {
  composer = "L.R. Lewis" % II-4-2, p. 61
  enteredby = "B. Crowell"
  source = "Melodia: A Comprehensive Course in Sight-Singing, Samuel W. Cole and Leo R. Lewis, Oliver Ditson Co., Bryn Mawr, Pennsylvania, 1904"
}%}
\new GrandStaff << \new Staff {
    \key a \minor
    \time 4/4
    \clef violin
       \relative e' { \partial 4 
                      e8 f | g4 a8 b c4 d | e1~ | e4 d c b8 a | gis4 a r2 | r2 r4 b8 c | d4 c8 b c4 b | a b8 a gis2~ | gis2 a4 r
                      a4 b8 c d e d c | b4 a8 b c4 b8 a | g8 f e f e4 d | c2.
                      \bar "||"}
  } % end staff
  \new Staff {
     \key a \minor
     \clef bass
       \relative c { \partial 4 
                     c8 d | e4 f e8 d c b | c8 d e f g4 a8 b | c1 | d4 c r b | a b8 a gis2~ | gis2 a4 r | r2 r4 b8 c | d4 c8 b c8 b a g! |
                     fis2. e8 fis | g4 f! e f | g2. g8 f | e f e d c4
                    }
  } % end staff
>>
