use t;

run 'eval', 'Expression form of "eval" at line 1.', 'Bare eval';

run 'eval {}', 'Block eval';

run 'eval( {} )', 'Block eval with parentheses';

run 'eval ""',
    'Expression form of "eval" at line 1.',
    'Expression eval with literal string';

run 'eval("")',
    'Expression form of "eval" at line 1.',
    'Expression eval with literal string and parentheses';

run 'eval $foo',
    'Expression form of "eval" at line 1.',
    'Expression eval with variable';

run 'eval($foo)',
    'Expression form of "eval" at line 1.',
    'Expression eval with variable and parentheses';

done_testing;
