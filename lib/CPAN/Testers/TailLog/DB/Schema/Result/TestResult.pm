use 5.006;    # our
use strict;
use warnings;

package CPAN::Testers::TailLog::DB::Schema::Result::TestResult;

our $VERSION = '0.001000';

# ABSTRACT: A Single Test Result in a database

# AUTHORITY

use DBIx::Class::Core;

our @ISA = (qw( DBIx::Class::Core ));

for (__PACKAGE__) {
    $_->table('test_result');
    $_->add_column('accepted');
    $_->add_column('filename');
    $_->add_column('grade');
    $_->add_column('perl_version');
    $_->add_column('platform');
    $_->add_column('reporter');
    $_->add_column('submitted');
    $_->add_column('uuid');
    $_->set_primary_key('uuid');
}

1;

