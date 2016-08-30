use t;

for ( qw/$ @ %/ ) {
    for my $decl ( 'my', 'local our' ) {
        # Declared but not used.
        t "$decl  ${_}foo",  qq/"${_}foo" is never read from, declared line 1./;
        t "$decl (${_}foo)", qq/"${_}foo" is never read from, declared line 1./;

        # Direct use.
        t "$decl  ${_}foo;  ${_}foo";
        t "$decl (${_}foo); ${_}foo";
    }

    t "my (${_}foo, ${_}bar)",
        qq/"${_}bar" is never read from, declared line 1./,
        qq/"${_}foo" is never read from, declared line 1./;

    # Non lexical.
    t "our ${_}foo";

    # Use in a different scope.
    t "my ${_}foo; { bar(${_}foo) }";

    # Deref.
    t "my \$foo; $_\$foo";
    t "my \$foo; $_\{\$foo}";

    # Hashes don't interpolate.
    my @e = $_ eq '%' ? '"%foo" is never read from, declared line 1.' : ();

    # Interpolation.
    t qq/my ${_}foo; "${_}foo"/,   @e;
    t qq/my ${_}foo; "${_}{foo}"/, @e;
    t qq/my ${_}foo; qq(${_}foo)/, @e;

    t "my ${_}foo; `${_}foo`", @e;

    # Regex interpolation.
    t "my ${_}foo;   /${_}foo/",     @e;
    t "my ${_}foo;  m/${_}foo/",     @e;
    t "my ${_}foo; qr/${_}foo/",     @e;
    t "my ${_}foo; qx/${_}foo/",     @e;
    t "my ${_}foo;  s/${_}foo/foo/", @e;
    t "my ${_}foo;  s/foo/${_}foo/", @e;
    t "my ${_}foo; tr/${_}foo/foo/", @e;
    t "my ${_}foo; tr/foo/${_}foo/", @e;
    t "my ${_}foo;  y/${_}foo/foo/", @e;
    t "my ${_}foo;  y/foo/${_}foo/", @e;

    # Not interpolation.
    t "my ${_}foo;  '${_}foo'", qq/"${_}foo" is never read from, declared line 1./;
    t "my ${_}foo; q/${_}foo/", qq/"${_}foo" is never read from, declared line 1./;

    # Heredocs.
    t qq/my ${_}foo; say <<EOF;\n${_}foo\nEOF/,   @e;
    t qq/my ${_}foo; say <<"EOF";\n${_}foo\nEOF/, @e;
    t qq/my ${_}foo; say <<'EOF';\n${_}foo\nEOF/,
        qq/"${_}foo" is never read from, declared line 1./;
}

t 'my @foo; $foo[0]';
t 'my @foo; @foo[0, 1]';
t 'my %foo; $foo{foo}';
t 'my %foo; @foo{qw/foo bar/}';

t 'my @foo; "$foo[0]"';
t 'my %foo; "$foo{foo}"';

t 'my @foo; $#foo';

t 'state $foo', '"$foo" is never read from, declared line 1.';

t 'my $foo = \&foo; &$foo';

t 'my $foo = \&foo; $foo->()';

t 'my $foo; Foo->$foo';

t 'my $foo; <$foo>';

done;
