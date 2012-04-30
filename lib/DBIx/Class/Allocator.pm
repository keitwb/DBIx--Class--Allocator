
package DBIx::Class::Allocator;

use warnings;
use strict;
use namespace::clean;

use Data::Dumper;

#use base qw/DBIx::Class::ResultSet/;

our $VERSION = '0.01';

our $sqlt_to_driver_name = {
    PostgreSQL => 'Pg',
    SQLite => 'SQLite',
};

sub allocate_ids {
    my ( $self, $count ) = @_;

    my $storage = $self->result_source->schema->storage;
    #my ($storage_type) = ref $storage =~ m/DBIx::Class::Storage::DBI::([:\w]+)/;
    my $sqlt_type = $storage->sqlt_type;

    my $driver = $sqlt_to_driver_name->{$sqlt_type};

    die "Database type not supported: $sqlt_type" if !$driver;

    my $package_name = "DBIx::Class::Allocator::" . $driver;

    #print Dumper($package_name);

    my $table = $self->result_source->name;
    #$self->load_components($package_name);
    eval "require $package_name";
    if ($@) {
        print "ERROR: " . $@;
    }
    
    my $column = $self->allocated_column || 'id';

    return $package_name->do_allocation($storage, $table, $column, $count);
}

sub allocated_column {
    my $self = shift;
    if (@_) { $self->{_allocated_column} = shift; }
    return $self->{_allocated_column};
}

1;

=head1 NAME

DBIx::Class::Allocator - DBIx::Class component for allocating blocks of auto-incremented columns

=head1 SYNOPSIS

  In your DBIC ResultSet package for a particular model:
    
    __PACKAGE__->load_components(qw/
        Allocator
    /);
    __PACKAGE__->allocated_column('table_id'); # Assuming there is an autoincrement 
                                               # column named 'table_id'

  Then, with your ResultSet instance:

    my ($first_id, $last_id) = $resultset->allocate_ids(10); # Allocates 10 ids

=head1 DESCRIPTION

A DBIx::Class component that gives ResultSets the ability to allocate blocks of
auto-increment ids from the database.  This is useful for creating id pools that
an application can reserve and use without having to be connected (through a web
interface) to the database (e.g. mobile apps that might not always have network
connectivity).

=head2 DBMS support

The following RDBMS systems are currently supported:
 - PostgreSQL
 - SQLite

For SQLite, the call to C<allocated_column> is unnecessary.  SQLite stores the
autoincrement sequences on a table level (in the C<sqlite_sequence> table), so
the column it is used with is irrelevant.   

=head2 EXPORT

None by default.



=head1 SEE ALSO


=head1 AUTHOR

Ben Keith, E<lt>keitwb@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Ben Keith

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
