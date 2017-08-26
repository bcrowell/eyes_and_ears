#!/usr/bin/perl

use strict;
use Lily;

my @files;

@files = <melodies/*.ly>;

foreach my $file(@files) {
  chomp $file;
  $file =~ s/\#.*//; # eliminate comments
  $file =~ s/^\s+//; # allow indentation
  my $full_file = $file;
  $file =~ s/melodies\///;
  next if $file =~ m/^\s*$/;
  if ($file =~ m/^\=([^=].*)/) { # chapter
    next;
  }
  if ($file =~ m/^\=\=([^=].*)/) { # section
    next;
  }
  if ($file =~ m/^\*(.*)/) { # explanatory text
    next;
  }
  my $rhythm = ($file=~m/x_rh/);
  my $parsed;
  my $should_parse = !$rhythm;
  if ($should_parse) {
    $parsed = Lily::parse_melody($full_file);
  }
  my $error = !(defined $parsed && exists $parsed->{scale_degrees});
  my $output = <<HEADER;
0, 0, Header, 1, 2, 480
1, 0, Start_track
1, 0, Title_t, "$file"
1, 0, End_track
2, 0, Start_track
2, 0, Program_c, 1, 19
HEADER
  if (!$error) {
    my $t = 0;
    my $pitches = $parsed->{notes};
    my @p = @$pitches;
    my $durations = $parsed->{rhythm};
    my @d = @$durations;
    for (my $i=0; $i<@p; $i++) {
      my $dd = $d[$i]*4; # kludge -- assume time sig is of the form .../4
      my $pp = $p[$i];
      if ($pp eq '') {$pp=-1} else {$pp = $pp - 25}
      if ($pp=~/[^\-0-9]/) {$error = 1}
      if ($pp>0) {
        $output = $output . "2, $t, Note_on_c, 1, $pp, 100\n"; # track,time,note on,channel,note,velocity
      }
      $t = $t + $dd*250; # fixed value is a kludge
      if ($pp>0) {
        $output = $output . "2, $t, Note_off_c, 1, $pp, 0\n";
      }
    }
    $output = $output . <<FOOTER;
2, $t, End_track
0, 0, End_of_file
FOOTER
  }
  if ($error) {
    #print STDERR "Unable to parse file $file using clamor_lily.\n" if $should_parse;
  }
  else {
    my $csv = $file;
    $csv =~ s/\.ly$/.csv/;
    open(F,">midi/$csv");
    print F $output;
    close F;
  }
}
