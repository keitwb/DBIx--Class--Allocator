
package DBIx::Class::Allocator::SQLite;

use warnings;
use strict;

#use Data::Dumper;

#use base qw/DBIx::Class::Allocator/;

sub do_allocation {
    my ( $self, $storage, $table, $column, $count ) = @_;

    my $guard = $storage->txn_scope_guard;
    my $sth = $storage->dbh->prepare("SELECT seq FROM sqlite_sequence WHERE name = ?");
    $sth->execute($table);

    my @row = $sth->fetchrow_array;
    if (not scalar @row) {
        die("Table '${table}' not in sqlite_sequence!  Are you sure it has a
            PRIMARY KEY that is also AUTO_INCREMENT?");
    }

    my $start = int($row[0] + 1);
    my $end = int($row[0] + $count);

    $sth = $storage->dbh->prepare("UPDATE sqlite_sequence SET seq = ? WHERE name = ?");
    $sth->execute($end, $table);

    $guard->commit;

    return ($start, int($end));
}

1;
