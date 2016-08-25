use t;

for ( 'my $fh', qw/$fh STDERR STDIN STDOUT/ ) {
    t sprintf q/open  %6s, '>', \my $foo/, $_;
    t sprintf q/open( %6s, '>', \my $foo )/, $_;
}

t q/open      FH, '>', \my $foo/,
    'Bareword file handle opened at line 1.';

t q/open(     FH, '>', \my $foo )/,
    'Bareword file handle opened at line 1.';

done;
