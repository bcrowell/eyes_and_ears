\version "2.14.0"
%{\header {
  composer = "B. Crowell"
  enteredby = "B. Crowell"
}%}
\score{{\set Score.timing = ##f
\key d \major
 <<
\relative c' {
   d1 e fis g a b cis d
  \bar "|"
}
\new Lyrics  \lyricmode { do re mi fa so la ti do }
>>

}}