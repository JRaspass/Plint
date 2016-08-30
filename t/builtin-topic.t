use t;

for ( qw/
    abs alarm chomp chop chr chroot cos defined eval evalbytes exp fc glob hex
    int lc lcfirst length log lstat mkdir oct ord pos print prototype
    quotemeta readlink readpipe ref require rmdir say sin sqrt stat study uc
    ucfirst unlink
/ ) {
    my @errors = $_ eq 'eval' ? 'Expression form of "eval" at line 1.' : ();

    t $_, @errors;
    t "$_()", @errors;

    t "$_  \$_",
        qq/\$_ should be omitted when calling "$_" at line 1./, @errors;

    t "$_( \$_ )",
        qq/\$_ should be omitted when calling "$_" at line 1./, @errors;

    t "$_  \$_[0]", @errors;
    t "$_( \$_[0] )", @errors;
    t "$_  \$_->foo", @errors;
    t "$_( \$_->foo )", @errors;
}

done;
