\version "2.14.0"
%{\header {
  copyright = "MutopiaBSD"
  title = "Nachtwache 1"
  composer = "Johannes Brahms"
  poet = "Friedrich Ru:ckert"
  opus = "op. 104"
  meter = "Langsam"
}%}
%{\tempo 4=100
%}\score{{\key b \minor
\relative c''  {
%1
\time 4/4
d4.^\markup{\column { "Langsam" " " }}\pp b8 d4 cis8 b8 | ais4 r4 r4 r8 cis8 | fis4. \< fis8\! e \> d cis \! d | cis b b4 r2 |

}
}}
