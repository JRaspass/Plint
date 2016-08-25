use t;

for ( qw/r w x o R W X O e z s f d l p S b c u g k T B M A C/ ) {
    run "-$_", "-$_";

    run "-$_ \$_",
        '$_ should be omitted when using a filetest operator at line 1.',
        "-$_ \$_";

    run "-$_ \$_[0]", "-$_ \$_[0]";

    run "-$_ \$_->foo", "-$_ \$_->foo";
}

# -t defaults to STDIN not $_.
run '-t',         '-t';
run '-t $_',      '-t $_';
run '-t $_[0]',   '-t $_[0]';
run '-t $_->foo', '-t $_->foo';

done_testing;
