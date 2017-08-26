\version "2.14.0"
%{\header {
  title = "Duet from The Magic Flute"
  composer = "W.A. Mozart"
  enteredby = "B. Crowell"
  source = "Mutopia project"
}%}
\new GrandStaff << \new Staff {
    \key es \major
    \time 6/8
    \clef violin
       \relative f' {
                       r4^\markup{\column { "Andantino" " " }} bes8 bes8 g g | g es es d f as | as g bes bes es d | d c bes bes as g | f r r r4 r8 |
                       r2. | r2. | r2. | r4 bes8 f' d bes | es4 es8 f8 d bes | es8 r r es es es | f r f bes,8. c16 d8 | es8 r r es d16 es d es |
                       f4 as16 f es4 f16 d | es4  \bar "||"}
  } % end staff
  \new Staff {
     \key es \major
     \clef bass
       \relative d' {
                        r2. | r2. | r2. | r2. | r4 bes8 bes g g | g es es d f as | as g bes es r d | c8. d16 bes8 bes8. c16 a8 | bes8 r bes as4 bes8 | g4 bes8 as4 bes8 | g r r c8 c c |
                        as8 r as bes r bes | c r r g g g | as4 as8 bes4 bes8 es,4 
                       
                    }
  } % end staff
>>
