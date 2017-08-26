\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\score{{\set Score.timing = ##f
\key c \minor
 <<
\relative c' {
  c1 d es f g a b c  \bar "|"
  c bes as g f es d c  \bar "|"
}
\new Lyrics  \lyricmode { la ti do re mi fi si la   la so fa mi re do ti la }
>>

}}
