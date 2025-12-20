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

##########################################################
sub init {
    ($rows, $cols) = @_;
    @array = ();

    for my $i (0 .. $rows - 1) {
        for my $j (0 .. $cols - 1) {
            $array[$i][$j] = 0;
        }
    }
}

##########################################################
sub addReadXLS {
    my ($filename) = @_;
    
    die "Array error" unless defined $rows;

    # parsing
    my $parser = Spreadsheet::ParseXLSX->new();
    my $workbook = $parser->parse($filename);

    die "Parsing $filename error" unless defined $workbook;

    # dodawanie wartosci
    for my $worksheet ( $workbook->worksheets() ) {
        for my $r ( 0 .. $rows - 1 ) {
            for my $c ( 0 .. $cols - 1 ) {
                my $cell = $worksheet->get_cell( $r, $c );  
                if ($cell) {
                    my $value = $cell->value();
                    $array[$r][$c] += $value; 
                }
            }
        }
    }
}

##########################################################
sub saveCSV {
    my ($filename) = @_;
    open(my $fh, '>', $filename) or die "File '$filename' error $!";
    
    for my $r (@array) {
        print $fh join(';', @$r) . "\n";
    }

    close $fh;
}

1;
