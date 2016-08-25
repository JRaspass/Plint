use t;

t '$foo =~ /foo/';

t '$@ =~ /foo/';

t '$_ =~ /foo/',
    '$_ should be omitted when matching a regular expression at line 1.';

t '$_ !~ /foo/',
    '$_ should be omitted when matching a regular expression at line 1.';

t 'my $re; $_ =~ $re';

t '$_ =~ $re';

done;
