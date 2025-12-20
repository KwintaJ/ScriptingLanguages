# Jan Kwinta
#
# 20.12.2025
#
# Problem PERL03
# Modul.pm
package Modul;

use strict;
use warnings;

use Spreadsheet::ParseXLSX;

my @array;
my ($rows, $cols);

sub init {
    ($rows, $cols) = @_;
    @array = ();

    for my $i (0 .. $rows - 1) {
        for my $j (0 .. $cols - 1) {
            $array[$i][$j] = 0;
        }
    }
}

sub addReadXLS {
    my ($filename) = @_;
    # TODO
}

sub saveCSV {
    my ($filename) = @_;
    open(my $fh, '>', $filename) or die "File '$filename' error $!";
    
    for my $row_ref (@array) {
        print $fh join(';', @$row_ref) . "\n";
    }

    close $fh;
}

1;
