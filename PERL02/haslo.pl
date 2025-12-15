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
$content = uc($content); 
$content =~ s/\r?\n//g;
$content =~ s/ /_/g;

our %freq_c = ("A" => 0, "B" => 0, "C" => 0, "D" => 0, "E" => 0, "F" => 0, "G" => 0, "H" => 0, "I" => 0, "J" => 0, "K" => 0, "L" => 0, "M" => 0, "N" => 0, "O" => 0, "P" => 0, "R" => 0, "S" => 0, "T" => 0, "U" => 0, "V" => 0, "W" => 0, "X" => 0, "Y" => 0, "Z" => 0, "_" => 0);
our $total = 0;

for my $c (split //, $content) {
    $freq_c{$c}++;
    $total++;
}

our @c_by_freq = sort { $freq_c{$b} <=> $freq_c{$a} } keys %freq_c;

# foreach my $c (@c_by_freq) {
#     print "$c $freq_c{$c}\n";
# }
# print "\n";

##########################################################
# przetworzenie spacji
our $space_c = $c_by_freq[0];

$content=~ s/$space_c/ /g;


my $filehandler2;
open $filehandler2, '>:raw', 'wc_in.txt';

print $filehandler2 $content;

close $filehandler2;

##########################################################
# zliczanie czestosci slow

system("perl ./wc.pl -p -x wc_in.txt > wc_out.txt");

my $filehandler3;
open $filehandler3, '<:raw', 'wc_out.txt';

local $/;
my $wc_result = <$filehandler3>;

close $filehandler3;
unlink "wc_in.txt";
unlink "wc_out.txt";


$wc_result=~ s/\?/_/g;

our %freq_w;

for my $line (split /\n/, $wc_result) {
    chomp $line;
    my ($word, $count) = split /\s+/, $line;
    $freq_w{$word} = $count;
}

our @w_by_freq = sort { $freq_w{$b} <=> $freq_w{$a} } keys %freq_w;

# foreach my $w (@w_by_freq) {
#     print "$w $freq_w{$w}\n";
# }
# print "\n";

##########################################################
# decrypt - analiza czestotliwosciowa

our @letter_rank = qw(_ A E I O Z S L N C W R Y T K M D P J U B G H F V X Q);
our @word_rank = qw(I SIE W NIE NA Z ZE TO A DO ALE PAN PO TAK BO JAK JA ZA O CO OD JUZ JEJ GO MU ZAGLOBA BYLO JESZCZE MI JEGO RZEKL BYL BASIA MNIE TU TYLKO ZAS DLA PRZEZ WIEC TYM BY ICH ON GDY PANA PRZY SOBIE WOLODYJOWSKI JEST LECZ TEGO NIM POD TAM JAKO CI NAD TERAZ PRZED BEDZIE SAM TEZ BYLA MOZE ZARAZ NIC TEJ KU RYCERZ OCZY POCZAL MALY JENO AZ PANI KTORY AZJA BOG KETLING CZYM CZY CHWILI IM BYC MA TEN JESLI BEZ TE MIAL ZEBY JEDNAK WRESZCIE NIA MIEDZY POTEM OW KTORA TYCH ABY NOWOWIEJSKI MICHAL NIEJ KRZYSIA KTO NICH NIEGO ODRZEKL WACPAN NAGLE NAWET JAKBY KTORE WSZYSTKO ONA CZAS CIE BARDZO LUDZI ZNOW IZ NIECH U PRZECIE WIECEJ RECE ALBO GDZIE MOGL CORAZ RAZ TY RZECZYPOSPOLITEJ WSZYSCY BASI HETMAN DOBRZE MOWIL TYMCZASEM SERCE TWARZ KTORZY BYLY CHOC NAS TUHAJ KTORYCH JE NI NIMI WSZYSTKIE TA GDYBY BOGA WSZYSTKICH OTO DOPIERO GLOWE TRZEBA CZASU TAKZE RZEKLA CALA NIZ POCZELA DZIEN WIEM KTOREJ WLASNIE SIEBIE BASKA NIKT SERCA WOWCZAS DALEJ GLOWY WE ONI MASZ LUB SOBA MOJA CHWILA NIECO ANI SAMA STRONY KONIE NAPRZOD MAM JEDEN CHOCBY WOLODYJOWSKIEGO JAKOBY BOZE PANU KTORYM NAM MOGLA KIEDY COS BEDE CHCIAL RYCERZA ZAWSZE POCZELI KRZYSI WIDOK TAKA SPYTAL PANIE CZASEM JEDNA NOC JAKIS BYLI DLATEGO STARY SILA MOJ WIELKI MIALA KTOREGO POCZELY BYM CHWILE NIGDY TEDY TYLE MALEGO LEPIEJ PRZECIW MOZNA AZJI ZOLNIERZE BARDZIEJ KONIEC DWOCH ZAWOLAL HA MICHALE GLOWA KILKA OT TWARZY GLOSEM KONIA MUSZALSKI LAT RAZEM);
our @all_mappings;

my $empty_mapping = "???????????????????????????";

# zamiana litery na jej miejsce w alfabecie: 
sub alphnum {
    my ($c) = @_;
    return 26 if $c eq "_"; # _=26
    return ord($c) - ord('A');  # A=0, B=1, ..., Z=25
}

# rekurencyjne generowanie mapowan
# rekurencja rozdziela sie w przypadku sytuacji watpliwej
sub generate_mappings {
    my @args = @_;
    my $mapping = shift @args;
    my @letters;

    for my $arg (@args) {
        push @letters, $arg;
    }

    for my $i (0..26) {
        next if substr($mapping, alphnum($c_by_freq[$i]), 1) ne "?";
        
        if(@letters == 1) {
            substr($mapping, alphnum($c_by_freq[$i]), 1) = $letters[0];
            last;
            }
        else {
            for my $j (0..@letters-1) {
                my @almost_all_letters = @letters;
                my $new_mapping = $mapping;
                substr($new_mapping, alphnum($c_by_freq[$i]), 1) = $letters[$j];
                splice(@almost_all_letters, $j, 1);
                generate_mappings($new_mapping, @almost_all_letters);
            }
            return;
        }
    }

    my $q_marks = () = $mapping =~ /\Q?\E/g;
    if ($q_marks == 0) {
        push @all_mappings, $mapping;
        return;
    }

    my @to_put;
    for my $i (0..26) {
        next if substr($mapping, alphnum($c_by_freq[$i]), 1) ne "?";
        my $current_c = $c_by_freq[$i];
        push @to_put, $letter_rank[$i];

        if($i == 26) {
            generate_mappings($mapping, @to_put);
            return;
        }

        my $next_c = $c_by_freq[$i + 1];
        if($freq_c{$current_c} - $freq_c{$next_c} > $total * 0.0015) {
            generate_mappings($mapping, @to_put);
            return;
        }
    }
}

# root generacji
generate_mappings($empty_mapping, "_");


##########################################################
# decrypt - ranking mapowan

my $best_map = $all_mappings[0];
my $best_score = score_mapping($all_mappings[0]);

sub decrypt {
    my $mapping = shift @_;
    my $word = shift @_;
    my $d_word = "";

    for my $i (0..length($word)-1) {
        my $l = substr($word, $i, 1);
        my $dl = substr($mapping, alphnum($l), 1) // '?';
        $d_word .= $dl;
    }
    return $d_word;
}

sub score_mapping {
    my $mapping = shift @_;
    my $s = 0;

    foreach my $w (@w_by_freq) {
        my $dw = decrypt($mapping, $w);

        if (grep { $_ eq $dw } @word_rank) {
            $s++;
        }
    }

    return $s;
}

foreach my $m (@all_mappings) {
    my $n_score = score_mapping($m);
    if ($n_score > $best_score) {
        $best_map = $m;
        $best_score = $n_score;
    }
}

##########################################################
# wypisanie wyniku

my $print_map = "???????????????????????????";

sub numalph {
    my ($n) = @_;
    return '_' if $n == 26;
    return chr(ord('A') + $n);
}

for my $i (0..26) {
    my $l = substr($best_map, $i, 1);
    substr($print_map, alphnum($l), 1) = numalph($i);
}

print "$print_map\n";
