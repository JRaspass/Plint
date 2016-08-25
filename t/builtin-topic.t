use t;

subtest $_ => sub {
    run $_, "bare $_";
    run "$_()", "bare $_ with parentheses";

    run "$_ \$_",
        qq/\$_ should be omitted when calling "$_" at line 1./,
        "$_ with topic";

    run "$_(\$_)",
        qq/\$_ should be omitted when calling "$_" at line 1./,
        "$_ with topic and parentheses";
} for qw/
    abs alarm chomp chop chr chroot cos defined evalbytes exp fc glob hex int
    lc lcfirst length log lstat mkdir oct ord pos print prototype quotemeta
    readlink readpipe ref require rmdir say sin sqrt stat study uc ucfirst
    unlink
/;

subtest eval => sub {
    run 'eval', 'Expression form of "eval" at line 1.', 'bare eval';

    run 'eval()',
        'Expression form of "eval" at line 1.', 'bare eval with parentheses';

    run 'eval $_',
        '$_ should be omitted when calling "eval" at line 1.',
        'Expression form of "eval" at line 1.',
        'eval with topic';

    run 'eval($_)',
        '$_ should be omitted when calling "eval" at line 1.',
        'Expression form of "eval" at line 1.',
        'eval with topic and parentheses';
};

done_testing;
