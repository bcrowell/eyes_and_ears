\version "2.14.0"
%{\header {
  composer = "L.R. Lewis" % 85
  enteredby = "B. Crowell"
  source = "Melodia: A Comprehensive Course in Sight-Singing, Samuel W. Cole and Leo R. Lewis, Oliver Ditson Co., Bryn Mawr, Pennsylvania, 1904"
}%}
\new GrandStaff << \new Staff {
    \key bes \major
    \time 4/4
    \clef violin
       \relative bes' { \partial 4 bes8 a | bes4 c8 d c4 bes8 a | bes4 a g f | r1 | r2 r4 bes8 a | bes4 r4 r4 bes8 a |bes4 r4 r4 bes8 a |
                        bes4 r r a8 g | f g f es d4 r | r c8 d c4 r | r d8 es d4 r | r es8 f g4 a | bes c d es | 
                        es8 d c bes a g f es | d4 es f g8 a | bes2. c4 | d4 c8 d es4 d | c bes a2 | bes2.
                      \bar "||"}
  } % end staff
  \new Staff {
     \key bes \major
     \clef bass
       \relative f { \partial 4 
                    r4 | r1 | r2 r4 f8 es | d4 es8 f  es4 d8 c | d4 c bes r | r c8 d c4 r | r d8 es d4 r |
                         r4 es8 f g4 a | bes2. bes8 a | bes4 r r bes8 a | bes4 r r bes8 a | bes4 r r a8 g | f8 g f es d es d c |
                         bes2 r | bes4 c d es | d8 es f g a4 g8 a | bes4 a g f | es4 f8 g f es d c | bes2.
                    }
  } % end staff
>>
