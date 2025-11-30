#!/usr/bin/perl
# Jan Kwinta
#
# 25.11.2025
#
# Problem PERL01-1
use strict;
use warnings;

my @zwierzeta = ("kot", "pies", "papuga", "kanarek", "ryba");

print "$zwierzeta[0]\n";

my $liczbaZwierzat = scalar @zwierzeta;
print "$liczbaZwierzat\n";

$zwierzeta[1] = "kanarek";

push(@zwierzeta, "żaba");

$liczbaZwierzat = scalar @zwierzeta;
print "$liczbaZwierzat\n";

pop(@zwierzeta);

$liczbaZwierzat = scalar @zwierzeta;
print "$liczbaZwierzat\n";

foreach my $zwierze (@zwierzeta) {
    print "$zwierze\n";
}

for my $i (0..@zwierzeta-1) {
    print "$i $zwierzeta[$i]\n";
}

for my $i (1..3) {
    print "$zwierzeta[$i]\n";
}