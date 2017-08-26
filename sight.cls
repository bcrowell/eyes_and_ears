\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sight}

\LoadClass[11pt]{book}

\RequirePackage{mytocloft,titlesec,titletoc,makeidx,fancyhdr,multicol,color,fnpara}
% Notes:
%   tocloft -- Using this has the effect, which I want, of suppressing the mandatory clearpage before the table of contents.
%\usepackage[T1]{fontenc}% http://lists.gnu.org/archive/html/lilypond-user/2004-03/msg00594.html

\renewcommand{\footnoterule}{}

\newcommand{\mychapter}[2]{\thispagestyle{fancy}\chapter{#1}\setcounter{subsection}{#2}}
\newcommand{\mynormaltype}{\normalsize\normalfont}
\newcommand{\normallayout}{\parafmt}

%========================= design =========================
\definecolor{mygraycolor}{gray}{.35}
\newcommand{\ingray}[1]{\color{mygraycolor}#1}
\newcommand{\showsecnum}[1]{\ingray{#1}}
% titlesec stuff:
\titleformat{\chapter}[display]
    {\normalfont\huge\bfseries\sffamily}{Chapter \thechapter}{0mm}
    {\Huge}
\titleformat{\section}
    {\normalfont\large\sffamily}{\showsecnum{\thesection}}{0.6em}{}
\titleformat{\subsection}
    {\normalfont\large\sffamily}{\showsecnum{\thesubsection}}{0.6em}{}

\titlespacing*{\chapter}{0mm}{4mm}{6mm}
\titlespacing*{\section}{0mm}{4mm}{0mm}
\titlespacing{\subsection}{0mm}{1mm}{-0.5mm}


%-------------------- page layout dimensions -------------------
% standard stuff, see LaTeX companion, p. 85:
  \setlength{\hoffset}{0mm}
  \setlength{\textwidth}{170mm} % widening this doesn't widen the sheet music (see $musiclinewidth in build.pl); changing it may mess up toc ...??
  \setlength{\marginparsep}{0mm}
  \setlength{\columnsep}{6mm}
  \setlength{\voffset}{-4mm}
  \setlength{\textheight}{230mm}
  \setlength{\topmargin}{0mm}
  \setlength{\headheight}{4mm}
  \setlength{\headsep}{8mm}
  \setlength{\footskip}{15mm}
  \setlength{\oddsidemargin}{0mm}
  \setlength{\evensidemargin}{0mm}
%-------------------- paragraph formatting -------------------
%Have to do the \parafmt /after/ the toc:
\newcommand{\normalparafmt}{
        \setlength{\parindent}{\normalparindent}
        \setlength{\parskip}{0mm}
}
\newcommand{\parafmt}{
        \newlength{\normalparindent}% ...has to be after TOC to avoid extra spacing in TOC
        \setlength{\normalparindent}{0mm}
        \normalparafmt
}
%-------------------- fancyhdr -------------------
\newcommand{\yesiwantarabic}{\renewcommand{\thepage}{\arabic{page}}}
\renewcommand{\headrulewidth}{0mm}
\renewcommand{\footrulewidth}{0mm}
\newlength{\myfooterspace}
\setlength{\myfooterspace}{5mm}
\newlength{\myfooterspacep}
\setlength{\myfooterspacep}{19mm}
\pagestyle{fancy}
\newcommand{\myheadertext}{}
\lhead[\myheadertext]{}
\chead[]{}
\rhead[]{\myheadertext}
\lfoot[\textbf{\textsf{\thepage}} \hspace{\myfooterspacep} \nouppercase{\textsf{\leftmark}}]{}
\cfoot[]{}
\rfoot[]{\nouppercase{\textsf{\rightmark}} \hspace{\myfooterspacep} \textbf{\textsf{\thepage}}}
\fancypagestyle{plain}{%
  \fancyfoot{} %
  %\fancyfoot[R]{\textbf{\textsf{\thepage}}}%
}
%========================= graphicx package=========================
\usepackage[dvipdfmx]{graphicx}
  % https://tex.stackexchange.com/a/17737/6853
  % https://tex.stackexchange.com/a/156265/6853
\AtBeginDocument{
        \DeclareGraphicsExtensions{.pdf,.jpg}
}
%==============================toc==================================
\renewcommand{\thechapter}{\Roman{chapter}}
\renewcommand{\thesection}{\Roman{chapter}-\arabic{section}}
\renewcommand{\thesubsection}{\arabic{subsection}}
%For the following, see the documentation for tocloft.sty:
\renewcommand{\contentsname}{}
\setlength{\cftbeforetoctitleskip}{0mm}
\setlength{\cftaftertoctitleskip}{0mm}
%titletoc stuff:
\contentsmargin{6mm}
\titlecontents{chapter}[0mm]{\sffamily\bfseries\Huge}
        {\contentsmargin{0mm}\thecontentslabel\enspace}
        {}{\titlerule*[4mm]{.}\contentspage}
\titlecontents{section}[0mm]{\sffamily\bfseries\Large}
        {\contentsmargin{0mm}\thecontentslabel\enspace}
        {}{\titlerule*[4mm]{.}\contentspage}
\titlecontents{subsection}[0mm]{\sffamily}
        {\contentsmargin{0mm}\thecontentslabel\enspace}
        {}{\titlerule*[4mm]{.}\contentspage}
% Brief contents:
\titlecontents{briefchapter}[0mm]{\Large\sffamily{}}
        {}{}
        {}
