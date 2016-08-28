use 5.006;    # our
use strict;
use warnings;

package CPAN::Testers::TailLog::DB::Schema;

our $VERSION        = '0.001000';
our $SCHEMA_VERSION = 1;

# ABSTRACT: Underlying DBIx::Class to Database mapper

# AUTHORITY

use DBIx::Class::Schema;
our @ISA = qw( DBIx::Class::Schema );

#<<<
__PACKAGE__->load_classes(qw(
  Result::TestResult
));
#>>>

sub schema_version { $SCHEMA_VERSION }

1;

