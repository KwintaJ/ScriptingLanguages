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
    my $q = $dbh->prepare($sql_insert);

    # wstawianie danych
    while (my $line = <$fh>) {
        chomp($line);
        my @values = split(',', $line);
        $q->execute(@values);
    }

    close($fh);
}

##########################################################
# zapytanie top 4 pracownikow
my $query = "
    SELECT 
        e.name, 
        e.surname, 
        u.email, 
        SUM(s.salary) AS total_salary
    FROM employees e
    JOIN user_data u ON e.id = u.employee_id
    JOIN salaries s ON e.id = s.employee_id
    GROUP BY e.id
    ORDER BY total_salary DESC, u.email ASC
    LIMIT 4
";

my $query_report = $dbh->prepare($query);
$query_report->execute();

# wypisanie
print "Top 4 employees with highest total salaries:\n"
print "----------------------------------------\n"
while (my @row = $query_report->fetchrow_array()) {
    printf("%s | %s | %s | %d\n", $row[0], $row[1], $row[2], $row[3]);
}
