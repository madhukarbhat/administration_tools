#!/usr/bin/perl

# About this tool:
#
# This is a pre-processor to convert bank statements in CSV format
# into the 3-column format as expected by /home/mb/go/bin/into-ledger
# tool, writen in Go programming language.

use strict;
use warnings;

# --------------------------------------------------------------------
# Parse in CSV Headers and prompt for columns to be transcribed

sub parse_csv_headers {
  my $csv_file = shift;

  open (my $fin, '<', $csv_file)
    or die "[Fatal] Cannot read file: $csv_file$!";
  my @content = <$fin>;
  chomp @content;
  close($fin);

  # Display column headers in an ordered list so that the user is able
  # to enter a list of comma separated indexes for the desired
  # columns.
  my $head_line = shift @content;
  my $i = 0;
  my @head = split (/,/, $head_line);
  foreach my $h (@head) {
    print $i, '. ', $h, "\n";
    ++$i;
  }
  print "\n";
  print 'Select columns for Date, Description, Debit and Credit.', "\n";
  print 'Columns needed (Enter column numbers separated by a comma): ';

  my $input = <STDIN>;
  chomp $input;
  $input =~ s/\s*?//g;
  if ($input !~ m/,/g) {
    print '[Fatal] Cannot find comma field separator!', "\n";
    exit (1);
  }

  my @cols = split (/,/, $input);
  chomp @cols;
  my $colcount = scalar @cols;
  if ( $colcount > 4) {
    print '[Fatal] Expected 4 columns, found $colcount.', "\n";
    exit (1);
  }

  my %parsed_data =
    (
     data => \@content,
     cols => \@cols
    );

  return \%parsed_data;
}

# --------------------------------------------------------------------
# Write out CSV file for into-ledger program

sub write_output_file {
  my $ds = shift;
  my $outf = shift;

  my $cols = $ds->{cols};
  my $data = $ds->{data};
  my $outd = '';
  foreach my $rec (@$data) {
    my @fields = split (/,/, $rec);

    # Get the credit value
    my $amt = $fields[$cols->[3]];

    # If the credit is zero, the debit would be populated. It should
    # have a negetive value to have appropriate sign.
    if ($amt == 0) {
      $amt = ($fields[$cols->[2]])*(-1);
    }

    # Convert to a number with 2 decimal digits
    my $amtf = sprintf("%.2f", $amt);

    # Create  line to be written to the output file.
    $outd .= $fields[$cols->[0]].','.$fields[$cols->[1]].','.$amtf."\n";
  }

  open (my $output, '>', $outf)
    or die "[Fatal] Cannot open $outf $!";
  print $output $outd;
  close ($output);

  return;
}

# --------------------------------------------------------------------
# Entry Point

sub main {
  my $csv = shift;

  my $out = $csv;
  $out =~ s/.csv/.out.csv/;

  print 'Inp: ', $csv, "\n";
  print 'Out: ', $out, "\n";

  my $parsed_data = parse_csv_headers($csv);
  write_output_file($parsed_data, $out);

  return;
}

# --------------------------------------------------------------------
# Main

my $ac = scalar @ARGV;
if ($ac != 1) {
  print 'Usage:', "\n";
  print '    ', $0, " <input-csv>\n";
  exit(1);
}

main(@ARGV);

# --------------------------------------------------------------------
# End
