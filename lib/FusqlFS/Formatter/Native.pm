use strict;
use 5.010;

package FusqlFS::Formatter::Native;
use parent 'FusqlFS::Formatter::Base';
use FusqlFS::Version;
our $VERSION = $FusqlFS::Version::VERSION;

=head1 NAME

FusqlFS::Formatter::Native - native formatter class

=head1 DESCRIPTION

This is a native formatter, it doesn't format data in any way. This is kind of
pass-through filter.

=cut

sub Dump
{
    return $_[0];
}

sub Load
{
    return $_[0];
}

1;
