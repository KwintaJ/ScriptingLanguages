#!/usr/bin/perl
# Jan Kwinta
#
# 30.11.2025
#
# Problem PERL02
# Lamacz hasel
use strict;
use warnings;

##########################################################
# ustalenie wejscia danych
my $filename;

if (@ARGV > 0) {
    $filename = $ARGV[0];
}
else {
    die "File not named";
}

##########################################################
# otworzenie wejscia danych i odczyt
my $filehandler;
open $filehandler, '<:raw', $filename or die "Can't open $filename: $!";

local $/;
my $content = <$filehandler>;

close $filehandler;

##########################################################
# zliczanie czestosci znakow
my %freq_c;
my $total = 0;

for my $c (split //, $content) {
    $freq_c{$c}++;
    $total++;
}

my @c_by_freq = sort { $freq_c{$b} <=> $freq_c{$a} } keys %freq_c;

foreach my $c (@c_by_freq) {
    print "$c $freq_c{$c}\n";
}

print "\n";

##########################################################
# zliczanie czestosci slow

system("perl ./wc.pl -p $filename > wc_out.txt");

my $filehandler2;
open $filehandler2, '<:raw', 'wc_out.txt';

local $/;
my $wc_result = <$filehandler2>;

close $filehandler2;
unlink "wc_out.txt";

my %freq_w;

for my $line (split /\n/, $wc_result) {
    chomp $line;
    my ($word, $count) = split /\s+/, $line;
    $freq_w{$word} = $count;
}

my @w_by_freq = sort { $freq_w{$b} <=> $freq_w{$a} } keys %freq_w;

foreach my $w (@w_by_freq) {
    print "$w $freq_w{$w}\n";
}

