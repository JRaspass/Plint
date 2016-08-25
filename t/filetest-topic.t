use t;

for ( qw/r w x o R W X O e z s f d l p S b c u g k T B M A C/ ) {
    t "-$_";

    t "-$_ \$_",
        '$_ should be omitted when using a filetest operator at line 1.';

    t "-$_ \$_[0]";

    t "-$_ \$_->foo";
}

# -t defaults to STDIN not $_.
t '-t';
t '-t $_';
t '-t $_[0]';
t '-t $_->foo';

done;
