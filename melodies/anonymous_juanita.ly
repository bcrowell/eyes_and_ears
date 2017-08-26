\version "2.14.0"
%{\header {
  title = "Juanita"
  composer = "anonymous"
  enteredby = "B. Crowell"
  source = "Heart Songs, Chapple Publishing, Boston, 1909"
}%}
\score{{\key d \major
\time 3/4
%{\tempo 4=90
%}\clef bass
\relative c' {
  a4.^\markup{\column { "Andante" " " }}
  r8 g fis | fis4 e r | e8. fis16 g4. g8 | fis8. b16 a4 r |
  a4. r8 g fis | fis4 e r | e8. fis16 g4 cis, | d2 r4 |
  fis8 a d4. cis8 | cis4 b r | e,8. e16 a4. g8 | fis8. b16 a4 r |
  fis8 a d4. cis8 | cis4 b r | a8. a16 a4 cis, | d2 r4 |
  fis4 fis \times 2/3 {fis8 e fis} | g4 g r | e8. e16 a4. g8 | fis8 b a4 r |
  fis4 fis \times 2/3 {fis8 e fis} | g4 g r | a,8 a fis'4 e | d2 r4
  \bar "||"
}

}}