use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'DBIx::Class::Allocator',
    VERSION_FROM      => 'lib/DBIx/Class/Allocator.pm', # finds $VERSION
    PREREQ_PM         => { "DBIx::Class" => 0 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/DBIx/Class/Allocator.pm', # retrieve abstract from module
       AUTHOR         => 'Ben Keith <keitwb@gmail.com>') : ()),
);
