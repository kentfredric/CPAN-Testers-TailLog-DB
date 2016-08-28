use strict;
use warnings;

use Test::Needs qw( DBD::SQLite );

use Test::More;
use Test::TempDir::Tiny qw( in_tempdir );
use CPAN::Testers::TailLog::DB::Schema::DeploymentHandler;

in_tempdir "db-io-test" => sub {
    my $db =
      CPAN::Testers::TailLog::DB::Schema::DeploymentHandler->new()->install(
        {
            dsn => [
                "dbi:SQLite:dbname=./test-schema.db",
                "", "", { journal_mode => 'WAL' }
            ]
        }
      );
    my $rs = $db->resultset('Result::TestResult');
    $db->txn_do(
        sub {
            my $record = $rs->new(
                {
                    accepted     => '2016-08-19T11:05:01Z',
                    filename     => 'LTHEISEN/Footprintless-1.08.tar.gz',
                    grade        => 'fail',
                    perl_version => 'perl-v5.12.1',
                    platform     => 'x86_64-gnukfreebsd',
                    reporter     => 'Chris Williams (BINGOS)',
                    uuid         => 'c618d39e-65fc-11e6-ab41-c893a58a4b8c',
                    submitted    => '2016-08-19T11:05:01Z',
                }
            );
            $record->insert();
        }
    );
    $db->txn_do(
        sub {
            my $res =
              $rs->search( { uuid => 'c618d39e-65fc-11e6-ab41-c893a58a4b8c' } );
            my (@items) = $res->all;
            ok( scalar @items, "Got a result" );
            note explain $items[0];
        }
    );
};

done_testing;
