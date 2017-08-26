\version "2.14.0"
%{\header {
  title = "Ubi Bene, Ibi Patria"
  composer = "anonymous"
  enteredby = "B. Crowell"
  source = "The Abridged Academy Song-Book, Charles H. Levermore, Ginn & Co., Boston, 1898"
}%}
\score{{\key c \major
\time 6/8
%{\tempo 8=160
%}\clef treble
\relative c'' {
  g4^\markup{\column { "Moderato" " " }} g8 c4 e,8 | e4 f8 g8 e r | c4 d8 e4 f8 | g4 a8 g4. \bar ":|"
  b4 c8 d4 c8 | b4 c8 d8 b r | b4 c8 d4 c8 | b4 a8 g4. \bar "|:"
  g4^\markup{\column { "Vivace" " " }} g8 a4 g8 | g4 g8 c4. \bar ":|"
  g4. c4. | a4. c4. | b4 b8 a4 g8 | e'4. r4 r8 | g,4. c4. f,4. d'4. | g,4 g8 a4 g8 | c,4. r4 r8
  \bar "||"
}

}}