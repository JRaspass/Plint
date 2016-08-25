use t;

t 'eval  {}';
t 'eval( {} )';

t q/eval/,       'Expression form of "eval" at line 1.';
t q/eval ''/,    'Expression form of "eval" at line 1.';
t q/eval('')/,   'Expression form of "eval" at line 1.';
t q/eval $foo/,  'Expression form of "eval" at line 1.';
t q/eval($foo)/, 'Expression form of "eval" at line 1.';

done;
