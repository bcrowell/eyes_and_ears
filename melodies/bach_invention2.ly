\version "2.14.0"
%{\header {
  title = 	"Invention 2"
  composer =	"Johann Sebastian Bach (1685-1750)"
 source = "Bach-Gesellschaft"
 maintainer = 	"Allen Garvin"
}%}
%{\tempo 4 = 50
  %}\score{{\key c \minor
\relative c''  {
  \partial 8*7
  c16[ b]  c d ees g,   aes bes aes f   f' es d c  |		% bar 1
   b aes' g f   ees d c b   c d c d   d8.\downprall c32 d  |	% bar 2
   ees16 d c d   ees f g8   g\prall f  r f |			% bar 3
   f\prall ees  r d  ees aes,~ aes16 f bes f  |		% bar 4
   g8 ees'~ ees16 d ees bes   c ees aes g   f ees d c  |	% bar 5
   bes d g f   ees d c bes   aes c f c   d8.\prall  d16  |	% bar 6
   ees 
}
}}