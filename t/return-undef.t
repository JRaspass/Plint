use t;

run 'return', 'Bare return';

run 'return()', 'Bare return with parentheses';

run 'return undef',
    '"return" statement with explicit "undef" at line 1.',
    'Return undef';

run 'return(undef)',
    '"return" statement with explicit "undef" at line 1.',
    'Return undef with parentheses';

run 'return "undef"', 'Return the string of undef';

run '$foo->return(undef)', 'Method called return';

run '$foo and return undef',
    '"return" statement with explicit "undef" at line 1.',
    'Return undef inside an expression';

run 'return undef, 1', 'Return multiple values';

run 'return( undef, 1 )', 'Return multiple values with parentheses';

done_testing;
