#!/usr/bin/perl
use strict;
use warnings;

my %animalsIn;

while (my $animal = <STDIN>) {
	chomp $animal;
	$animalsIn{$animal}++; 
}

my @animals = keys %animalsIn;
my @animalsSorted = sort @animals;

foreach my $animal (@animalsSorted) {
	print "$animal $animalsIn{$animal}\n";
}