use t;

t q(use Foo 'bar'), 'Unused import of "bar" from Foo at line 1.';
t q(use Foo 'bar'; bar);

t q(use Foo "bar"), 'Unused import of "bar" from Foo at line 1.';
t q(use Foo "bar"; bar);

t q(use Foo qw/bar/), 'Unused import of "bar" from Foo at line 1.';
t q(use Foo qw/bar/; bar);

# Funcs with the same name as builtins are fun.
t q(use Time::HiRes 'time'),
    'Unused import of "time" from Time::HiRes at line 1.';
t q(use Time::HiRes 'time'; time);

# False positives.
t q(use lib 'lib');
t q(use warnings 'all');

t q(use Exporter 'import');
t q(use Getopt::Long qw/:config bundling/);
t q(use Regexp::Common 'number');

done;
