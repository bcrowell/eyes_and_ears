\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\score{{\set Score.timing = ##f
\key c \major
 <<
\relative c' {
  c1 cis d dis e f fis g gis a ais b c \bar "|"
  c b bes a as g ges f e es d des c  \bar "|"
}
\new Lyrics  \lyricmode {   do di re ri mi fa fi so si la li ti do     do ti te la le so se fa mi me re ra do }
>>

}}