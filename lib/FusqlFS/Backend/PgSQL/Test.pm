use strict;
use v5.10.0;

package FusqlFS::Backend::PgSQL::Test;

our $fusqlh;

sub dbi_connect
{
    use DBI;
    my $debug = 0;
    DBI->connect('DBI:Pg:database=postgres', 'postgres', '', { PrintError => $debug, PrintWarn => $debug });
}

sub set_up
{
    my $dbh = dbi_connect();
    return unless $dbh;
    $dbh->do("DROP DATABASE IF EXISTS fusqlfs_test");
    return unless $dbh->do("CREATE DATABASE fusqlfs_test");
    $dbh->disconnect;

    use FusqlFS::Backend::PgSQL;
    $fusqlh = FusqlFS::Backend::PgSQL->new(host => '', port => '', database => 'fusqlfs_test', user => 'postgres', password => '');
}

sub tear_down
{
    $fusqlh->{dbh}->disconnect();
    $fusqlh->destroy();

    my $dbh = dbi_connect();
    $dbh->do("DROP DATABASE IF EXISTS fusqlfs_test");
    $dbh->disconnect;
}

1;
