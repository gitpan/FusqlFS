use strict;
use 5.010;

package FusqlFS::Backend::MySQL::Events;
use FusqlFS::Version;
our $VERSION = $FusqlFS::Version::VERSION;
use parent 'FusqlFS::Artifact';

=head1 NAME

FusqlFS::Backend::MySQL::Events - FusqlFS MySQL database events interface

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EXPOSED STRUCTURE

=cut

sub list
{
    my $self = shift;
    return $self->all_row('SHOW EVENTS');
}

