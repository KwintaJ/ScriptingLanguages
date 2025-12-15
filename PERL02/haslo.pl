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
# normalizacja tekstu (zostawiamy A-Z i spacje)
$content =~ s/[^A-Z ]//g;

##########################################################
# konfiguracja statystyczna
my @POLISH_RANK = qw(
    _ A I E O Z N R S W T C D K L M P J U Y B G H F Q V X
);

my @COMMON_WORDS = qw(
    I ZE NIE NA DO W ZA CO JAK TO
    JEST BYL BYLA BYC KTORY KTORA KTORE
);

##########################################################
# zliczanie czestosci znakow
my %freq;
my $total = 0;

for my $c (split //, $content) {
    $freq{$c}++;
    $total++;
}

