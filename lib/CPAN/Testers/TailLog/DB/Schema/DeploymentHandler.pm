use 5.006;    # our
use strict;
use warnings;

package CPAN::Testers::TailLog::DB::Schema::DeploymentHandler;

our $VERSION = '0.001000';
our $DISTNAME;
BEGIN { $DISTNAME = 'CPAN-Testers-TailLog-DB' }

# ABSTRACT: Database construction and upgrade tooling for C:T:TL:DB

# AUTHORITY

use Path::Tiny qw( path );

# The following logic is uber-reduced, mostly safe
# equivalent logic for File::ShareDir::ProjectDistDir,
# sans all the bugs and wank
# {{
#
# If -e is not a path, then assume some dark eval magic
# where "USE A SHARE DIR" is the only right option.
#
# If -e is a path, then this .pm file is "real" somewhere, and "my lib"
# is relative to __PACKAGE__ name.
use constant LIB_BASE => (
    -e __FILE__
    ? path(__FILE__)->parent( 1 + split /::/, __PACKAGE__ )
      ->realpath->stringify
    : undef
);

# If "my lib" contains 'share/ddl' then we're an author dist.
use constant AUTHOR_MODE =>
  ( defined LIB_BASE and -e path( LIB_BASE, qw( share ddl ) ) );

# If "Author Mode", DDLs are found relative to LIB_BASE, otherwise, they're installed
# Also note, that as long as `share` is installed to blib/ during test, blib mode
# works as installed-mode. It will actually fail and assume system sharedir if
# you didnt.
use constant DDL_ROOT => AUTHOR_MODE
  ? path( LIB_BASE, qw( share ddl ) )->absolute->stringify
  : do {
    require File::ShareDir;
    path( File::ShareDir::dist_dir($DISTNAME), 'ddl' )->stringify;
  };

# }}
# FSD Wank Ends here
use DBIx::Class::DeploymentHandler;
use CPAN::Testers::TailLog::DB::Schema;

sub new {
    my ( $class, @args ) = @_;
    my $args = { ref $args[0] ? %{ $args[0] } : @args };
    my $self = bless $args, $class;

    $self->{schema_class} = 'CPAN::Testers::TailLog::DB::Schema'
      unless exists $self->{schema_class};
    $self->{dh_args} = {} unless exists $self->{dh_args};
    $self->{dh_args}->{script_directory} =
      $args->{script_directory} || DDL_ROOT;
    $self->{dh_args}->{databases} =
      $args->{databases} || [qw( PostgreSQL SQLite MySQL )];
    if ( exists $args->{to_version} ) {
        $self->{dh_args}->{to_version} = $args->{to_version};
    }
    $self;
}

sub write_ddl {
    if ( not AUTHOR_MODE ) {
        die "Can't write DDLs from installed codebase";
    }
    my $dh = DBIx::Class::DeploymentHandler->new(
        { %{ $_[0]->{dh_args} }, schema => $_[0]->{schema_class}, } );
    $dh->prepare_install;
    my $v = $dh->schema_version;
    return if $v <= 1;
    $dh->prepare_upgrade(
        {
            from_version => $v - 1,
            to_version   => $v,
        }
    );
}

sub install {
    my ( $self, @args ) = @_;
    my $config = { ref $args[0] ? %{ $args[0] } : @args };
    my $conn = do {
        exists $config->{schema} ? $config->{schema}
          : exists $config->{dsn}
          ? $self->{schema_class}->connect( @{ $config->{dsn} } )
          : die "dsn or schema required";
    };
    my $dh = DBIx::Class::DeploymentHandler->new(
        { %{ $_[0]->{dh_args} }, schema => $conn, } );
    $dh->install;
    return $conn;
}

1;
