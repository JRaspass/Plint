use t;

for ( qw/$fh STDERR STDIN STDOUT/ ) {
    t sprintf q/open  %6s, '>', 'foo'/, $_;
    t sprintf q/open( %6s, '>', 'foo' )/, $_;
}

t q/open      FH, '>', 'foo'/,
    'Bareword file handle opened at line 1.';

t q/open(     FH, '>', 'foo' )/,
    'Bareword file handle opened at line 1.';

done;
