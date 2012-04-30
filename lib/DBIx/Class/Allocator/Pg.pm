
package DBIx::Class::Allocator::Pg;

use warnings;
use strict;

#use Data::Dumper;

#use base qw/DBIx::Class::Allocator/;

sub do_allocation {
    my ( $self, $storage, $tablename, $column, $count ) = @_;

    return $storage->dbh_do(sub {
        my ($storage, $dbh) = @_;

        my $guard = $storage->txn_scope_guard;

        # Make sure nobody can insert and implicitly call 'nextval', as well as
        # block concurrent allocations.
        $dbh->do("LOCK TABLE $tablename IN ACCESS EXCLUSIVE MODE");

        # This should act as a mutex for concurrent allocations due to the above lock
        $dbh->do("SELECT $column FROM $tablename LIMIT 1");

        my @row = $dbh->selectrow_array("SELECT nextval(pg_get_serial_sequence('$tablename', '$column'))");

        #my @row = $sth->fetchrow_array;
        #if (!defined scalar @row) {
            #die("Table '${tablename}' does not have a sequence on column '$column'!");
        #}

        my $start = int($row[0]);
        my $end = int($row[0] + $count - 1);

        $dbh->do("SELECT setval(pg_get_serial_sequence('$tablename', '$column'), $end)");

        $guard->commit;

        ($start, int($end));
    });
}

1;
