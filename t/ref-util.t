use t;

t 'ref $foo eq "Foo"';

for my $func ('ref', 'ref()', 'ref $foo', 'ref($foo)', 'my $foo; ref $foo') {
    for my $cmp (qw/eq ne/) {
        for my $q ("'", '"') {
            for my $ref (qw/ARRAY CODE GLOB HASH REF Regexp SCALAR/) {
                t qq($func $cmp $q$ref$q),
                    qq(Ref check should use "Ref::Util::is_\L${ref}ref" at line 1.);
            }
        }
    }
}

done;
