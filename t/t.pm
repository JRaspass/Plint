package t;

use strict;
use warnings;

use File::Temp;
use Plint;
use Test::More;

*main::done_testing = \&Test::More::done_testing;

sub import {
    strict->import;
    warnings->import;
}

sub main::run {
    my $name = pop;

    my $fh = File::Temp->new;
    $fh->print(shift);
    $fh->close;

    is_deeply plint( $fh->filename ), \@_, $name;
}
