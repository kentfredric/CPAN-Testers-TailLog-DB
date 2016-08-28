#!perl
use strict;
use warnings;

use CPAN::Testers::TailLog::DB::Schema::DeploymentHandler;

my $dh = CPAN::Testers::TailLog::DB::Schema::DeploymentHandler->new();
$dh->write_ddl;
