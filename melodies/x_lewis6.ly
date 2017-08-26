\version "2.14.0"
%{\header {
  composer = "L.R. Lewis" % 27
  enteredby = "B. Crowell"
  source = "Melodia: A Comprehensive Course in Sight-Singing, Samuel W. Cole and Leo R. Lewis, Oliver Ditson Co., Bryn Mawr, Pennsylvania, 1904"
}%}
\new GrandStaff << \new Staff {
    \key c \major
    \time 6/8
    \clef violin
       \relative c'' { c8 b c d c b | c b a g4. | a8 g f e4. | f8 e d c4. 
                      \bar "||"}
  } % end staff
  \new Staff {
     \key c \major
     \clef bass
       \relative c { c8 d e f e d | e4 f8 g a b | c4. c8 b a | g4 f8 e d c
                    }
  } % end staff
>>
