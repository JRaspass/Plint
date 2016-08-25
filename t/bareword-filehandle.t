use t;

run +('open my $fh, "<", "foo"') x 2;

run 'open FH, "<", "foo"',
    'Bareword file handle opened at line 1.',
    'open FH, "<", "foo"';

run 'open( FH, "<", "foo" )',
    'Bareword file handle opened at line 1.',
    'open( FH, "<", "foo" )';

run +("open STD$_, '>', \\my \$foo") x 2 for qw/ERR IN OUT/;

done_testing;
