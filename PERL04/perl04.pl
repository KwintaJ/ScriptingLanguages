#!/usr/bin/perl
# Jan Kwinta
#
# 20.12.2025
#
# Problem PERL04
use strict;
use warnings;
use DBI;

##########################################################
# polaczenie z baza danych
my $db_file = "database.db";
if (-e $db_file) {
    unlink($db_file);
}

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "", { 
    RaiseError => 1, 
    AutoCommit => 1 
});

##########################################################
# odczyt z plikow, stworzenie tablic i zapis do nich
foreach my $filename (@ARGV) {
    my $tablename = $filename;
    $tablename =~ s/\.csv$//;

    open(my $fh, '<', $filename) or die "File error $!";

    # naglowek - nazwy kolumn
    my $header_line = <$fh>;
    chomp($header_line);
    my @columns = split(',', $header_line);

    # budowanie CREATE TABLE
    my @col_defs;
    foreach my $col (@columns) {
        $col =~ s/^\s+|\s+$//g; # trim
        my $type = "TEXT";

        # jesli zaczyna się na 'i' = INTEGER
        if ($col =~ /^i/) {
            $type = "INTEGER";
        }
        
        # jesli zawiera 'date' = DATE
        if ($col =~ /date/i) {
            $type = "DATE";
        }

        # jesli id = UNIQUE, polaczenie z INTEGER
        if ($col eq "id") {
            $type .= " UNIQUE"; 
        }

        push @col_defs, "$col $type";
    }

    my $sql_create = "CREATE TABLE $tablename (" . join(", ", @col_defs) . ")";
    $dbh->do($sql_create);

    # budowanie INSERT 
    my $question_marks = join(", ", ("?") x scalar @columns);
    my $sql_insert = "INSERT INTO $tablename (" . join(", ", @columns) . ") VALUES ($question_marks)";
    my $sth = $dbh->prepare($sql_insert);

    # wstawianie danych
    while (my $line = <$fh>) {
        chomp($line);
        my @values = split(',', $line);
        $sth->execute(@values);
    }

    close($fh);
}

