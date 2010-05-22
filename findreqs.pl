#!/usr/bin/perl

use strict;
use v5.10.0;

my $requires = {
    'Getopt::Long' => 0,
    'Pod::Usage'   => 0,
    'Carp'         => 0,

    'DBI'          => '1.600',
    'DBD::Pg'      => 0,

    'YAML::Tiny'   => 0,

    'POSIX'        => 0,
    'Fcntl'        => 0,
    'Fuse'         => '0.09',

    'Test::More'   => 0,

    'DBD::mysql'   => 0,

    'XML::Simple'  => 0,
    'JSON::Syck'   => 0,
};

foreach my $module (keys %$requires)
{
    my $file = $module;
    $file =~ s/::/\//g;
    $file .= '.pm';
    my $found = 0;
    foreach (@INC)
    {
        next unless -e "$_/$file";
        say "Module $module was found in $_/$file.";
        $found = 1;
        last;
    }
    say "Module $module was not found." unless $found;
}


