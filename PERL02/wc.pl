#!/usr/bin/perl
# Jan Kwinta
#
# 30.11.2025
#
# Problem PERL02
# Word count
use strict;
use warnings;

##########################################################
# parsowanie argumentow 
my %opts = (
    c => 0, m => 0, l => 0, w => 0, p => 0, i => 0
);

my $noopts = 0;

# regex
while (@ARGV and $ARGV[0] =~ /^-(.+)/) {
    my $flags = $1;
    shift @ARGV;

    foreach my $f (split //, $flags) {
        die "Unsupported option -$f\n" unless exists $opts{$f};
        $opts{$f} = 1;
    }
}

if (!$opts{c} && !$opts{m} && !$opts{l} && !$opts{w} && !$opts{p}) {
    $noopts = 1;
}

##########################################################
# ustalenie wejscia danych
my $filename = '-';

if (@ARGV > 0) {
    $filename = $ARGV[0];
}

##########################################################
# otworzenie wejscia danych i odczyt
my $filehandler;
if ($filename eq '-') {
    $filehandler = *STDIN;
} else {
    open $filehandler, '<:raw', $filename or die "Can't open $filename: $!";
}

local $/;
my $content = <$filehandler>;

close $filehandler;

##########################################################
# liczenie - poszczegolne opcje

my $bytes;
my $chars;
my $lines;
my $wordcount;

if ($opts{i}) {
    $content = lc $content;
}

if ($opts{c} || $noopts) {
    $bytes = length($content);
    if(!$noopts) {
        printf "%7d %s\n", $bytes, $filename;
    }
}

if ($opts{m}) {
    use Encode 'decode';
    my $decoded = decode('UTF-8', $content);
    $chars = length($decoded);
    if(!$noopts) {
        printf "%7d %s\n", $chars, $filename;
    }
}

if ($opts{l} || $noopts) {
    $lines = ($content =~ tr/\n/\n/);
    if(!$noopts) {
        printf "%7d %s\n", $lines, $filename;
    }
}

if ($opts{w} || $noopts) {
    my @words = split /\s+/, $content;
    $wordcount = @words;
    if(!$noopts) {
        printf "%7d %s\n", $wordcount, $filename;
    }
}

if ($noopts) {
    printf "%7d %7d %7d %s\n", $lines, $wordcount, $bytes, $filename;
}

# if ($opts{p}) {
#     my @raw_words = split /[ \t\r\n]+/, $content;
#     @raw_words = map { lc $_ } @raw_words;

#     # regex zmiana nieangielskich liter na ?
#     sub normalize {
#         my ($w) = @_;
#         $w =~ s/[^a-zA-Z]/?/g;
#         return $w;
#     }

#     my %count;
#     $count{$_}++ for @raw_words;

#     my @sorted = 
#         sort {
#             $count{$b} <=> $count{$a}   # liczba wystąpień malejąco
#             ||
#             normalize($a) cmp normalize($b)   # leksykograficznie
#         }
#         keys %count;

#     my $limit = 10;
#     for my $w (@sorted[0 .. $limit-1]) {
#         my $norm = normalize($w);
#         print "$norm $count{$w}\n";
#     }
# }
