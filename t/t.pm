package t;

use strict;
use warnings;

use File::Temp;
use Plint;
use Test::More;

*main::done = \&Test::More::done_testing;

sub import {
    strict->import;
    warnings->import;
}

sub main::t {
    my $fh = File::Temp->new;
    $fh->print( my $code = shift );
    $fh->close;

    $code =~ y/\n/ /;

    is_deeply +( plint( $fh->filename ) )[0], \@_, $code;
}
