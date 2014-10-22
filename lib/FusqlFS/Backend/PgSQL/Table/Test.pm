use strict;
use v5.10.0;

package FusqlFS::Backend::PgSQL::Table::Test;
our $VERSION = "0.005";
use FusqlFS::Backend::PgSQL::Test;

our $fusqlh;

sub set_up
{
    $fusqlh = FusqlFS::Backend::PgSQL::Test->set_up();
    return unless $fusqlh;
    $fusqlh->{subpackages}->{tables}->create('fusqlfs_table');
    $fusqlh->{subpackages}->{languages}->create('plperl');
    $fusqlh->{subpackages}->{functions}->store('fusqlfs_function()',
        {
            'content.plperl' => 'return;',
            struct => { result => 'trigger', type => 'trigger', volatility => 'immutable' },
            language => \'languages/plperl'
        }
    );
}

sub tear_down
{
    FusqlFS::Backend::PgSQL::Test->tear_down();
}

1;
