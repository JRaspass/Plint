use t;

run '$foo =~ /foo/', 'Variable matching literal regexp';

run '$@ =~ /foo/', '$@ matching literal regexp';

run '$_ =~ /foo/',
    '$_ should be omitted when matching a regular expression at line 1.',
    '$_ matching literal regexp';

run '$_ !~ /foo/',
    '$_ should be omitted when matching a regular expression at line 1.',
    '$_ not matching literal regexp';

run 'my $re; $_ =~ $re', '$_ matching lexical variable';

run '$_ =~ $re', '$_ matching global variable';

done_testing;
