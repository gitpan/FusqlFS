#!/usr/bin/perl

$SIG{TERM} = $SIG{INT} = $SIG{QUIT} = sub {
    my $sig = shift;
    print "Signal $sig.\n";
    exit(0);
};

while (<>) {}
