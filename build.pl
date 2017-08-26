#!/usr/bin/perl

use strict;
#use lib "/home/bcrowell/Documents/programming/clamor";
use Lily;

if (!@ARGV) {
  print "Usage:\n  build.pl book\n  build.pl catalog\n  build.pl dist\n";
  exit;
}

my $what = $ARGV[0];

my @files;

#my $unit_slash = ''; 
my $unit_slash = '\\'; # backslash needed for lily 2.2 and later, or it gives warnings
my $point_unit = "${unit_slash}pt";
my $mm_unit = "${unit_slash}mm";

my $staff_size = "16";
my $music_size;
if ($what eq 'catalog') {
  @files = <melodies/*.ly>;
  $music_size = "13$point_unit";
}
else { # book or dist
  @files = split /\n/,read_file('list');
  $music_size = "20$point_unit";
}

my %problems; # hash of files that won't compile

my $brief_toc = "brieftoc.tex";
my $doing_brief_toc = 0;
if ($what eq 'book') {
  open(BRIEF_TOC,">$brief_toc") or die "Error opening $brief_toc for output, $!";
  $doing_brief_toc = 1;
  print BRIEF_TOC <<'FOO';
\onecolumn\pagebreak[4]
\noindent\huge\bfseries\sffamily{}\hspace{2.5mm}\noindent{}Brief Contents

\vspace{10mm}\hbox{}
\begin{tabular}{rl}
FOO
}

if ($what eq 'dist') {
  my $dist = "eyes_and_ears/melodies";
  die "directory $dist doesn't exist" if ! -d $dist;
  foreach my $file(@files) {
    chomp $file;
    $file =~ s/\.ly$//;
    $file =~ s/^melodies\///;
    $file =~ s/^\s+//; # indentation
    $file =~ s/\#.*//; # comments
    $file =~ s/\,.*//; # flags
    next if exists $problems{$file};
    next if $file =~ m/^$/ or $file =~ m/^\=(.*)/ or $file =~ m/^\*(.*)/;
  }
  exit;
}

my %standardize_name = (
  "Johann Sebastian Bach"=>"J.S. Bach",
  "Brahms"=>"Johannes Brahms",
  "Holst"=>"Gustav Holst",
  "Haydn"=>"Franz Joseph Haydn",
  "Pergolesi"=>"Giovanni Battista Pergolesi",
  "Tallis"=>"Thomas Tallis",
);



#--------------------------------------------------------------------

print read_file('top.tex');

#--------------------------------------------------------------------

my $count = 1;
my ($chapter,$section) = (0,0);
my %thematic_index = ();
my @what_items_were = ();
foreach my $file(@files) {
  my $last_item = $what_items_were[-1];
  chomp $file;
  $file =~ s/\#.*//; # eliminate comments
  $file =~ s/^\s+//; # allow indentation
  next if $file =~ m/^\s*$/;
  if ($file =~ m/^\=([^=].*)/) { # chapter
    my $title = $1;
    push @what_items_were,'chapter';
    my $label;
    ($title,$label) = parse_section($title);
    ++$chapter;
    $section = 0;
    my $setsubsec = $count; # prevent subsection number (melody number) from being reset with each new chapter or section
    $setsubsec=0 if $count==1;
    if ($last_item eq 'text') {print "\\end{samepage}\n"}
    print "\\pagebreak[4]\\vspace{12mm}\\noindent{\\mychapter{$title}{$setsubsec}\\label{ch:$chapter}";
    print "\\label{ch:$label}" if defined $label;
    print "}\n";
    print BRIEF_TOC "\\end{tabular}\n\n\\begin{tabular}{rl}\n" if $chapter!=1;
    print BRIEF_TOC "\\briefch{$chapter}{$title}\n" if $doing_brief_toc;
    next;
  }
  if ($file =~ m/^\=\=([^=].*)/) { # section
    my $title = $1;
    ++$section;
    push @what_items_were,'section';
    my ($label,$flags);
    ($title,$label,$flags) = parse_section($title);
    my $pagebreak_required = ($section!=1 && !($flags=~m/p/));
    my $pagebreak_suggestion = $pagebreak_required ? 4 : 3;
    if ($last_item eq 'text') {print "\\end{samepage}\n"}
    print "\\pagebreak[$pagebreak_suggestion]";
    print "\\vspace{12mm}" if !$pagebreak_required;
    print "\\noindent{\\section{$title}\\label{sec:$chapter:$section}";
    print "\\label{sec:$label}" if defined $label;
    print "}\n";
    print BRIEF_TOC "\\briefsec{$chapter:$section}{$title}\n" if $doing_brief_toc;
    next;
  }
  if ($file =~ m/^\*(.*)/) { # explanatory text
    push @what_items_were,'text';
    if ($last_item eq 'text') {
      print "\\end{samepage}\n";
    }
    print "\n\n\\pagebreak[3]\\par\n\\vspace{5mm}\\begin{samepage}$1\\\\\n";
    next;
  }
  push @what_items_were,'music';
  my $flags = '';
  if ($file =~ m/(.*)\,([^,]*)/) {
    $file = $1;
    $flags = $2;
  }
  my $famous = ($flags=~m/f/);
  my $rhythm = ($flags=~m/r/);
  my $didactic = ($flags=~m/d/);
  my $no_header = ($flags=~m/h/) && $didactic;
  $file =~ s/\.ly$//;
  $file =~ s/^melodies\///;
  next if exists $problems{$file};
  my $full_file = "melodies/$file.ly";
  my $ly = read_file($full_file);
  $ly =~ m/\\header\s*\{(([^{}]+|\{[a-z]\}))\}\s*(.*)/s;
  my ($header,$notes) = ($1,$3);
  #print STDERR "--header--\n$header\n--notes--\n$notes\n-----\n";
  $notes =~ s/\n\n+/\n/g;
  my $title = '';
  my $composer = '';
  while ($header =~ m/(\w+)\s*\=\s*\"([^"]*)\"/g) {
    my ($key,$value) = ($1,$2);
    $value =~ s/\#/\\\#/g;
    $value =~ s/\&/\\\&/g;
    $value =~ s/n\~/\\\~{n}/g;
    $value =~ s/([aeiou]):/\\"{$1}/gi;
    $value =~ s/([aeiou])\-\//\\'{$1}/gi;
    $value =~ s/([aeiou])\-\`/\\`{$1}/gi;
    $value =~ s/([aeiou])\-\^/\\^{$1}/gi;
    $title = $value if $key eq 'title';
    $composer = $value if $key eq 'composer';
  }
  $notes =~ s/(\[|\]|\(|\))//g;

  # kludge: extract some info about the piece from the lilypond code:
  $notes =~ m/\\key\s+(\w+)\s*\\(major|minor)/;
  my ($key,$mode) = ($1,$2);
  $notes =~ m/\\time\s+(\d+)\/(\d+)/;
  my $timesig = "$1/$2";
  my $tempo_markup = '';
  $tempo_markup = $1 if $notes =~ m/\\markup\{\"([\w\s]*)\"\}/;

  $composer =~ s/\s*\(?\d\d\d\d\-+\d\d\d\d\)?\s*//g; # e.g., J.S. Bach (1685-1750)
  $composer =~ s/\s*\(.*\)//g; # e.g., G.B. Fasolo (17th century)
  $composer=$standardize_name{$composer} if exists $standardize_name{$composer};
  my ($first,$last);
  if ($composer ne 'anonymous' && $composer =~ m/(.*)\s+([^\s]+)/) {
    ($first,$last) = ($1,$2);
  }
  else {
    $last = $composer;
  }

  $key = uc($key);
  if ($mode eq 'minor') {
    $key = lc($key);
  }
  my ($flat,$sharp) = ('\ensuremath{\flat}','\ensuremath{\sharp}');
  $key="$1$flat" if $key=~m/^([bcdfg])es$/i;
  $key="$1$flat" if $key=~m/^([ae])s$/i;
  $key="$1$sharp" if $key=~m/^([abcdefg])is$/i;
  my $describe_key_and_time;
  if (!$rhythm) {
    $describe_key_and_time = "$key, $timesig";
  }
  else {
    $describe_key_and_time = "$timesig";
  }
  $describe_key_and_time = "$describe_key_and_time, $tempo_markup" if $tempo_markup ne '';

  my $label = "$composer, \\emph{$title}";
  my $short_label = "$last, \\emph{$title}";
  if ($title eq '') {
    $label = $composer;
    $short_label = $last;
  }
  if ($file=~m/crowell/) {
    if ($title eq '') {
      $label = '';
      $short_label = '';
    }
    else {
      $label = $title;
      $short_label = $title;
    }
  }
  if ($composer eq 'anonymous' && $title=~m/^folk.song$/) {
    $label = 'folk song';
    $short_label = 'folk song';
  }
  my $toc_label;
  if ($short_label ne '') {
    $toc_label = "$short_label, $describe_key_and_time";
  }
  else {
    $toc_label = "$describe_key_and_time";
  }
  $toc_label =~ s/^anonymous,\s+//;
  $toc_label =~ s/^\s+//;
  $toc_label =~ s/^,\s+//;
  my $show_label = $label;
  $show_label = 'famous tune (identified in the table of contents)' if $famous;
  $show_label = '' if $no_header;
  my $parsed;
  my $should_parse = !$rhythm && !$didactic;
  my $solfeg = '';
  if ($should_parse) {
    $parsed = Lily::parse_melody($full_file);
  }
  if (defined $parsed && exists $parsed->{scale_degrees}) {
    my $scale_degrees = $parsed->{scale_degrees};
    my @s = @$scale_degrees;
    if (@s) {
      foreach my $s(@s) {
        $solfeg = $solfeg.({1=>'d',2=>'r',3=>'m',4=>'f',5=>'s',6=>'l',7=>'t'}->{$s+1}) if defined $s;
      }
    }
  }
  else {
    print STDERR "Unable to parse file $file using clamor_lily. No entry will be added to the thematic index.\n" if $should_parse;
  }
  print "%=========================================================================\n";
  print "%    $count\n" if !$didactic;
  print "%    $file\n";
  print "%    $solfeg\n" if $solfeg ne '';
  print "%    composer=$composer, last=$last, first=$first\n";
  print "\n\n\\pagebreak[3]\\par\n" unless $last_item eq 'section';
  print "\\vspace{5mm}\\begin{samepage}\n" unless $last_item eq 'text';
  print "\\par\n" if $last_item eq 'text' and $show_label ne ''; # otherwise \hfill doesn't have the desired effect
  print "\\hfill \\raisebox{0mm}[0mm][0mm]{\\raisebox{-2mm}{$show_label}}\\\\" if $show_label ne '' && $famous;
  print "\n\n\\vspace{5mm}\n\n" if $show_label ne '' && $rhythm;
  if ($what eq 'catalog') {
    my $show_file = $file;
    $show_file =~ s/_/\\_/g;
    print "\\hfill $show_file\\\\*\n";
  }
  print "\\makebox[0mm][r]{\\huge{\\ingray{$count}}\\hspace{0mm}}" if !$didactic;
  print "\\footnotetext[$count]{$show_label}\n"  if $show_label ne '' && !$famous && !$didactic;
  my $index_title = '';
  my $index_title_under_composer = '';
  my $got_titles = 0;

  # aria (Papageno) from ...
  if ($title =~ m/^(tune|aria|chorale)(\s+\(\w+\))?(\s+from|,)/i  ) {
    $index_title_under_composer = $title;
    $got_titles = 1;
  }

	if ($title ne '' && !$got_titles && !($title=~m/folk.song/)) {
    $index_title = $title;
    $index_title =~ s/\s*\(.*\)$//; # e.g., "... (Mexico)"
    $index_title =~ s/^(tune|aria|chorale)\s+//i; 
    if ($index_title=~m/^(A|The|La|El|Los|Las) (.*)$/i) {
      $index_title = "$2, $1";
    }
    if ($index_title=~m/^(\w+) from (string quartet (.*))$/i) {
      $index_title = "$2, $1";
    }
    $index_title =~ s/\`([^`]*)'/$1/; # handles, e.g., `Mach's mit mir'
  }
  else {
    $index_title = $describe_key_and_time;
  }
  $index_title =~ s/\!//g;
  if ($rhythm) {
    $index_title =~ s/^rhythm of\s+//;
    $index_title = "$index_title (rhythm only)";
	}
  my $index_composer;
  # ------ indexing under composer's name
  if ($index_title_under_composer eq '') {
    $index_title_under_composer = $index_title;
	}
  if ($last && !$didactic) {
    $index_composer = "$last, $first";
    $index_composer = $last if $first eq ''; # last name only, or 'anonymous'
    do_index_line("\\index{$index_composer!$index_title_under_composer}%\n") if $index_composer ne 'anonymous';
	}
  # ------ indexing under title
  if ($index_title ne '' && $index_title ne $describe_key_and_time && !$didactic) {
    if (defined $last && $last ne 'anonymous') {
      do_index_line("\\index{$index_title, $first $last}%\n");
    }
    else {
      do_index_line("\\index{$index_title}%\n");
	  }
	}
  # ------ thematic index
  if ($solfeg ne '' && !$didactic) {
    $solfeg =~ m/^(\w{1,8})/;
    my $s = $1;
    $s =~ tr/drmfslt/1234567/;
    my $ref = "p. \\pageref{tune:$count}, no. $count";
    if (!exists $thematic_index{$s}) {
      $thematic_index{$s} = $ref;
    }
    else {
      $thematic_index{$s} = $thematic_index{$s}."; $ref";
    }
  }
  # ------ label
  print "\\label{tune:$count}%\n" if !$didactic;
  # ------ music
  #my $temp_file = "temp-$file.tex";
  #only works with old lilypond-book:
  #print "\\begin[filename=$temp_file,staffsize=$staff_size,linewidth=$musiclinewidth,$music_size]{lilypond}\n";
  #print '\property Score.barNumberVisibility = #(every-nth-bar-number-visible 999)'."\n"; # eliminate bar numbers
	#											 print "\\begin{lilypond}\n";
	#											 print $notes;
	#											 print "\\input $temp_file\n";
	#											 print "\\end{lilypond}\n";
  # new lilypond-book:
  #print "\\lilypondfile[staffsize=$staff_size,linewidth=$musiclinewidth]{../melodies/$file.ly}\n";
  print "\\lilypondfile[noindent,linewidth=170\\mm]{../melodies/$file.ly}\n";
  print "\\addcontentsline{toc}{subsection}{\\textbf{$count} $toc_label}\n" if !$didactic;
  print "\\end{samepage}\n";
  ++$count if !$didactic;
}

#--------------------------------------------------------------------
print <<'FOO';
\par\pagebreak[4]{\Huge Thematic Index}\label{thematic-index}\\*
FOO
foreach my $num(sort keys %thematic_index) {
  	my $solfeg = $num;
    $solfeg =~ tr/1234567/drmfslt/;
    print "$solfeg --- $thematic_index{$num}\\\\\n";
}
#--------------------------------------------------------------------

print read_file('bottom.tex');

#--------------------------------------------------------------------

if ($doing_brief_toc) {
  print BRIEF_TOC '\end{tabular}'."\n";
  close BRIEF_TOC;
}

#--------------------------------------------------------------------

sub read_file {
  my $file = shift;
  open(FILE,"<$file") or die "error opening input file $file";
  local $/;
  my $stuff = <FILE>;
  close(FILE);
  return $stuff;
}

sub parse_section {
  my $x = shift;
  my ($title,$label,$flags);
  if ($x =~ m@(.*)\!\!(.*)//(.*)@) {return parse_section("$1//$3!!$2")} # put in the right order
  if ($x =~ m@(.*)\!\!(.*)@) {
    $flags = $2;
    ($title,$label) = parse_section($1);
    return ($title,$label,$flags);
  }
  if ($x =~ m@(.*)//(.*)@) {
    return ($1,$2);
  }
  else {
    return ($x,undef);
  }
}

sub do_index_line {
  my $line = shift;
  print $line;
}
