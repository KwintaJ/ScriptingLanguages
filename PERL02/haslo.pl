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
$content= uc($content); 
$content =~ s/\r?\n//g;
$content=~ s/ /_/g;

my %freq_c = ("A" => 0, "B" => 0, "C" => 0, "D" => 0, "E" => 0, "F" => 0, "G" => 0, "H" => 0, "I" => 0, "J" => 0, "K" => 0, "L" => 0, "M" => 0, "N" => 0, "O" => 0, "P" => 0, "R" => 0, "S" => 0, "T" => 0, "U" => 0, "V" => 0, "W" => 0, "X" => 0, "Y" => 0, "Z" => 0, "_" => 0);
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
# przetworzenie spacji
my $space_c = $c_by_freq[0];

$content=~ s/$space_c/ /g;


my $filehandler2;
open $filehandler2, '>:raw', 'wc_in.txt';

print $filehandler2 $content;

close $filehandler2;

##########################################################
# zliczanie czestosci slow

system("perl ./wc.pl -p wc_in.txt > wc_out.txt");

my $filehandler3;
open $filehandler3, '<:raw', 'wc_out.txt';

local $/;
my $wc_result = <$filehandler3>;

close $filehandler3;
unlink "wc_in.txt";
unlink "wc_out.txt";


$wc_result=~ s/\?/_/g;

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
print "\n";

##########################################################
# decrypt - analiza czestotliwosciowa

my %mapping;
my %used_plain;
$mapping{$space_c} = "_";
$used_plain{$space_c} = 1;

my @one_letter = grep { length($_) == 1 } @w_by_freq;
$mapping{$one_letter[0]} = "I";
$used_plain{$one_letter[0]} = 1;

my @letter_rank = qw(A E I O Z S L N C W R Y T K M D P J U B G H F V X Q);

for my $c (@c_by_freq) {
    next if exists $mapping{$c};
    for my $p (@letter_rank) {
        next if $used_plain{$p};
        $mapping{$c} = $p;
        $used_plain{$p} = 1;
        last;
    }
}

##########################################################
# wypisanie wyniku

foreach my $k (sort keys %mapping) {
    print "$k";
}
print "\n";

foreach my $l (sort keys %mapping) {
    print "$mapping{$l}";
}
print "\n";

