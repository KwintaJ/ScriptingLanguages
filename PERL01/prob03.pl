#!/usr/bin/perl
# Jan Kwinta
#
# 25.11.2025
#
# Problem PERL01-3
use strict;

my $fA = $ARGV[0];
my $fB = $ARGV[1];
my $fM = $ARGV[2];

my @mA;
my @mB;
my @mM;

my $rowNum = 0;
my $colNum = 0;

open my $file, '<', $fA or die "error file open $!\n";
while(my $row = <$file>) {
	chomp $row;
	my @numbers = split /\s+/, $row;
	$colNum = 0;
	foreach my $num (@numbers) {
		$mA[$rowNum][$colNum] = $num;	
		$colNum++;
	}
	$rowNum++;
}
close $file;

my $rowsA = $rowNum;
my $colsA = $colNum;

$rowNum = 0;

open $file, '<', $fB or die "error file open $!\n";
while(my $row = <$file>) {
	chomp $row;
	my @numbers = split /\s+/, $row;
	$colNum = 0;	
	foreach my $num (@numbers) {
		$mB[$rowNum][$colNum] = $num;	
		$colNum++;
	}
	$rowNum++;
}
close $file;

my $rowsB = $rowNum;
my $colsB = $colNum;

for my $i (0..$rowsA-1) {
    for my $j (0..$colsB-1) {
        my $sum = 0;
        for my $k (0 .. $colsA-1) {
            $sum += $mA[$i][$k] * $mB[$k][$j];
        }
        $mM[$i][$j] = $sum;
    }
}

open $file, '>', $fM or die "error file open $!\n";
for my $i (0..$rowsA-1) {
    for my $j (0..$colsB-1) {
		printf $file "%8.3f", $mM[$i][$j];
		if ($j < $colsB-1) {
			printf $file " ";
		}
	}	
	print $file "\n";
}
close $file;