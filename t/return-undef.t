use t;

t 'return';
t 'return()';
t 'return undef',  '"return" statement with explicit "undef" at line 1.';
t 'return(undef)', '"return" statement with explicit "undef" at line 1.';

t q/return 'undef'/;

t '$foo->return(undef)';

t '$foo and return undef',
    '"return" statement with explicit "undef" at line 1.';

t 'return  undef, 1';
t 'return( undef, 1 )';

done;
