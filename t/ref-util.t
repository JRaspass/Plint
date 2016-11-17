use t;

t 'ref $foo eq "Foo"';

for my $var ('', '()', ' $foo', '($foo)') {
    for my $cmp (qw/eq ne/) {
        for my $q ("'", '"') {
            for my $ref (qw/ARRAY CODE GLOB HASH REF Regexp SCALAR/) {
                t qq(ref$var $cmp $q$ref$q),
                    qq(Ref check should use "Ref::Util::is_\L${ref}ref" at line 1.);
            }
        }
    }
}

done;
