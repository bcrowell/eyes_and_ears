#----------------------------------------------------------------
# Copyright (c) 2004 Benjamin Crowell, all rights reserved.
#
# This software is available under version 2 of the GPL license.
# The software is copyrighted, and you must agree to the
# license in order to have permission to copy it. The full
# text of the license is given in the file titled Copying.
#
#----------------------------------------------------------------


use strict;

use File::Temp;

package Lily;

=head2

This is just a little wrapper for clamor_lily.

=cut

sub parse_melody {

  my $ly_file = shift;
  my @notes = ();
  my @rhythm = ();
  my @bar = ();
  my @properties = ();
  my @letters_int = (); # 0=c, 1=d, ...
  my @accidentals = ();
  my @scale_degrees = (); # 0=do, 1=re, ...
  my %meta = ();

  my $debug = 0;
  # $debug = ($ly_file=~m/eroica/i);

  # I used block comments %{ %} for things I want Clamor to see, but that I don't want to be seen by
  # lilypond when I compile the Eyes and Ears sight-singing book. Same issue with \markup{}.

  my $curly = "(?:(?:{[^{}]*}|[^{}]*)*)"; # match anything, as long as any curly braces in it are paired properly, and not nested
  my $cooked = '';
  open(LY,"<$ly_file");
  while (my $line=<LY>) {
    $line=~s/(\%\{|\%\}|\^\\markup\{$curly\})//g;
    $cooked = $cooked . $line;
  }
  close LY;

  my ($fh,$f) = File::Temp::tempfile; # has side-effect of opening file
  print $fh $cooked;

  my $shell_command = "clamor_lily <$f";
  #print STDERR $shell_command; # debugging
  my $parsed = `$shell_command`;

  close($fh); # causes file to be deleted

  #my $exp = 'perl -e "while (\$line=<STDIN>) {\$line=~s/(\%\{|\%\}|\^\\markup\{[^}]*\})//g; print \$line}"' . " <$ly_file | clamor_lily";
  #my $parsed = `$exp`;

  #print "--> $parsed\n";
  # For reasons I don't entirely understand, putting \score and \notes around the music causes clamor_lily to
  # output a newline toward the beginning of the file, and *not* output the second between the headers and the notes.
  # Kludge to fix that:
  $parsed =~ s/^\n//; # extra newline may be at beginning...
  $parsed =~ s/\n\n([a-z])/\n$1/g; # ...or in middle of headers
  $parsed =~ s/\n([a-z]([^\n])*)\n([0-9\-])/\n$1\n\n$3/; # make sure the good newline is there


  if ($parsed =~ m/^error/) {
    if (0) { # debugging
      print STDERR $cooked;
      print STDERR $parsed;
    }
    return undef;
  }

  my $mode = 'headers';
  my $last_header;
  my ($tonic,$tonic_acc);
  while ($parsed =~ m/([^\n]*)\n/g) {
    my $line = $1;
    if ($mode eq 'headers') {
      if ($line=~m/(\w+)\s*\=\s*(.*)/) {
        $meta{$1} = $2;
        $last_header = $1;
      }
      else {
        if (defined $last_header) {
          $meta{$last_header} = $meta{$last_header} . $line;
        }
      }
    }
    if ($line=~m/^\s*$/) {
      $mode = 'notes';
      $tonic = $meta{tonic};
      $meta{key} =~ m/^\s*(\w+)\s*\\(major|minor)/;
      my ($tonic_name,$mode) = ($1,$2);
      $meta{mode} = $2;
      $tonic_acc = 0;
      $tonic_acc = -1 if $tonic_name=~m/(as|es)/;
      $tonic_acc = 1 if $tonic_name=~m/is/;
    }
    if ($mode eq 'notes') {
      foreach my $note(split /\s+/,$line) {
        my ($pitch,$time,$time_since_barline,$properties,$name) = split /,/,$note;
        my ($scale_degree,$letter_int);
        if ($pitch == -1) { # rest
          $pitch = undef;
          $name = undef;
          $scale_degree = undef;
        }
        else {
          $letter_int = {c=>0,d=>1,e=>2,f=>3,g=>4,a=>5,b=>6}->{$name};
          $scale_degree = find_scale_degree($letter_int,$tonic,$tonic_acc,$debug);
          if ($debug) {print STDERR "scale_de=$scale_degree, $letter_int,$tonic,$tonic_acc\n"}
        }
        push @notes,$pitch;
        push @rhythm,$time;
        push @bar,$time_since_barline;
        push @properties,$properties;
        push @letters_int,$letter_int;
        push @scale_degrees,$scale_degree;
      }
    }
  }
  return {'notes'=>\@notes,'rhythm'=>\@rhythm,'bar'=>\@bar,'properties'=>\@properties,'meta'=>\%meta,
          'letters_int'=>\@letters_int,'scale_degrees'=>\@scale_degrees};
}

# returns 0=do, 1=re, ...
sub find_scale_degree {
  my $letter = shift; # 
  my $tonic = shift; # midi
  my $tonic_acc = shift;
  my $debug = 0;
  if (@_) {$debug=shift}
  my $tonic_let = pitch_and_acc_to_letter_int($tonic,$tonic_acc);
  if ($debug) {print STDERR "tonic_let=$tonic_let,   tonic=$tonic,tonic_acc=$tonic_acc\n"}
  return ($letter-$tonic_let)%7;
}

# 'letter int' means 0 for c, 1 for d, ... 6 for b
sub pitch_and_acc_to_letter_int {
  my $pitch = shift; # midi
  my $acc = shift;
  if ($acc<0) {return pitch_and_acc_to_letter_int($pitch+1,$acc+1)}
  if ($acc>0) {return pitch_and_acc_to_letter_int($pitch-1,$acc-1)}
  return {0=>0,2=>1,4=>2,5=>3,7=>4,9=>5,11=>6}->{$pitch-60};
}

1;
