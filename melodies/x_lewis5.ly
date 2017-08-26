\version "2.14.0"
%{\header {
  composer = "L.R. Lewis" % 4-6
  enteredby = "B. Crowell"
  source = "Melodia: A Comprehensive Course in Sight-Singing, Samuel W. Cole and Leo R. Lewis, Oliver Ditson Co., Bryn Mawr, Pennsylvania, 1904"
}%}
\new GrandStaff << \new Staff {
    \key c \major
    \time 4/4
    \clef violin
       \relative c'' { c1 | c2 b | a b | c1\fermata | c2 b | a g | f1 | f2 e\fermata | e f | g a | b1 | c\fermata
                      \bar "||"}
  } % end staff
  \new Staff {
     \key c \major
     \clef bass
       \relative c' { c2 b | a g | f1 | e_\fermata | e1 | e1 | d2 c | b c_\fermata | c d | e f | g f | e1_\fermata
                    }
  } % end staff
>>
