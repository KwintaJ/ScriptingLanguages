#!/usr/bin/perl
# Jan Kwinta
#
# 20.12.2025
#
# Problem PERL03
# main
use strict;
use warnings;

use lib '.'; 
use Modul;

##########################################################
# wartosci
my $n;
my $m;
my $file_IN;
my $file_OUT;

##########################################################
# przetworzenie argumentow wywolana
if (@ARGV < 4) {
    die "Arg error";
}
else {
    $n = $ARGV[2];
    $m = $ARGV[3];
    $file_IN = $ARGV[0];
    $file_OUT = $ARGV[1];
}

##########################################################
# wykonanie funkcji z Modul
Modul::init($n, $m);
Modul::addReadXLS($file_IN);
Modul::saveCSV($file_OUT);