package Plint 0.001;

use strict;
use warnings;

use Compiler::Lexer;

BEGIN {
    no strict 'refs';

    # Copy the TokenType constants into our package to improve readability.
    /^T_/ and *$_ = \&{"Compiler::Lexer::TokenType::$_"}
        for keys %Compiler::Lexer::TokenType::;
}

my $lexer = Compiler::Lexer->_new( { filename => '', verbose => 0 } );

# TODO reverse, split, unpack are different
my %topical_funcs;
@topical_funcs{
    qw/
        abs alarm chomp chop chr chroot cos defined eval evalbytes exp fc glob
        hex int lc lcfirst length log lstat mkdir oct ord pos print prototype
        quotemeta readlink readpipe ref require rmdir say sin sqrt stat study
        uc ucfirst unlink
        /
} = ();

sub import {
    no strict 'refs';

    *{ caller . '::plint' } = \&plint;
}

sub _arg_is_dollar_underscore {
    my ( $i, $tokens ) = @_;

    return if ++$i > $#$tokens;

    # Skip over opening paren if we have it.
    $i++ if $tokens->[$i]{type} == T_LeftParenthesis;

       $tokens->[$i]{type} == T_SpecificValue
    && $tokens->[$i]{data} eq '$_'
    && ( $i == $#$tokens || (
        # Ensure we don't have $_[0] or $_->
           $tokens->[ ++$i ]{type} != T_LeftBracket
        && $tokens->[   $i ]{type} != T_Pointer
    ));
}

sub _find_vars_in_str {
    my ( $vars, $str ) = @_;

    for ( my $i = $#$vars; $i != -1; $i-- ) {
        for ( keys %{ $vars->[$i] } ) {
            my ( $sigil, $name ) = /(.)(.*)/;

            # It's an array and a slice is interpolated.
            _var_is_used( $vars, $_ )
                if $sigil eq '@' && -1 != index $str, "\$$name\[";

            # It's a hash and a slice is interpolated.
            _var_is_used( $vars, $_ )
                if $sigil eq '%' && -1 != index $str, "\$$name\{";

            if  ( $sigil eq '$' || $sigil eq '@' ) {
                # It's directly interpolated.
                # The character after the last can either be not a
                # variable char, or it can be the end of the string.
                _var_is_used( $vars, $_ )
                    if $str =~ /\Q$_\E(?:[^\w\[{]|$)/
                    # It's iterpolated with braces, e.g. ${foo}
                    || -1 != index $str, "$sigil\{$name}";
            }
        }
    }
}

sub _var_is_used {
    my ( $vars, $var ) = @_;

    for ( my $i = $#$vars; $i != -1; $i-- ) {
        last if delete $vars->[$i]{$var};
    }
}

sub plint {
    local ( @ARGV, $/ ) = @_;

    my ( $tokens, @errors ) = Compiler::Lexer::tokenize( $lexer, scalar <> );
    my @vars = {};

    for ( my $i = 0; my $token = $tokens->[$i]; $i++ ) {
        my $type = $token->{type};

        if ( $type == T_Return ) {
            next unless $token = $tokens->[ my $j = $i + 1 ];

            $token = $tokens->[ ++$j ] if $token->{type} == T_LeftParenthesis;

            push @errors,
                qq/"return" statement with explicit "undef" at line $token->{line}./
                if $token->{type} == T_Default
                && $token->{data} eq 'undef'
                && ( $j == $#$tokens || $tokens->[ ++$j ]{type} != T_Comma );
        }

        elsif ( $type == T_BuiltinFunc ) {
            my $data = $token->{data};

            push @errors,
                qq/\$_ should be omitted when calling "$data" at line $token->{line}./
                if exists $topical_funcs{$data}
                && _arg_is_dollar_underscore( $i, $tokens );

            if ( $data eq 'eval' ) {
                my $line = $token->{line};

                push @errors, qq/Expression form of "eval" at line $line./
                    unless ( $token = $tokens->[ $i + 1 ] )
                    && ( $token->{type} == T_LeftBrace
                    || $token->{type} == T_LeftParenthesis
                    && $tokens->[ $i + 2 ]{type} == T_LeftBrace );
            }
            elsif ( $data eq 'open' ) {
                push @errors, "Bareword file handle opened at line $token->{line}."
                    if $tokens->[ $i + 1 ]{type} == T_Key
                    || (
                           $tokens->[ $i + 1 ]{type} == T_LeftParenthesis
                        && $tokens->[ $i + 2 ]{type} == T_Key
                    );
            }
            elsif ( $data eq 'no' && $tokens->[++$i]{data} eq 'strict' ) {
                push @errors, "strict disabled at line $token->{line}.";
            }
        }
        elsif ( $type == T_SpecificValue ) {
            if ( $token->{data} eq '$_' ) {
                $type = ( $tokens->[ my $j = $i + 1 ] or next )->{type};

                if ( $type == T_RegOK || $type == T_RegNot ) {
                    $type = $tokens->[ ++$j ]{type};

                    push @errors,
                        "\$_ should be omitted when matching a regular expression at line $token->{line}."
                        if $type != T_Var && $type != T_GlobalVar;
                }
            }
        }
        elsif ( $type == T_RequireDecl ) {
            push @errors,
                qq/\$_ should be omitted when calling "require" at line $token->{line}./
                if _arg_is_dollar_underscore( $i, $tokens );
        }
        elsif ( $type == T_Handle ) {
            push @errors,
                "\$_ should be omitted when using a filetest operator at line $token->{line}."
                if $token->{data} ne '-t'
                && _arg_is_dollar_underscore( $i, $tokens );
        }
        elsif (
               $type == T_VarDecl
            || $type == T_StateDecl
            # local our is kinda like my. Especially in old CGIs.
            || ( $type == T_LocalDecl && $tokens->[ ++$i ]{type} == T_OurDecl )
        ) {
            my $type = ( $token = $tokens->[ ++$i ] )->{type};

            if (
                   $type == T_LocalVar
                || $type == T_LocalArrayVar
                || $type == T_LocalHashVar
                || $type == T_GlobalVar
                || $type == T_GlobalArrayVar
                || $type == T_GlobalHashVar
            ) {
                $vars[-1]{ $token->{data} } = $token->{line};
            }
            elsif ( $type == T_LeftParenthesis ) {
                until ( ( $type = ( $token = $tokens->[ ++$i ] )->{type} )
                    == T_RightParenthesis
                ) {
                    $vars[-1]{ $token->{data} } = $token->{line}
                        if $type == T_GlobalVar
                        || $type == T_GlobalArrayVar
                        || $type == T_GlobalHashVar;
                }
            }
        }
        elsif (
               $type == T_Var
            || $type == T_ArrayVar
            || $type == T_HashVar
            || $type == T_GlobalVar
            || $type == T_GlobalArrayVar
            || $type == T_GlobalHashVar
        ) {
            my ( $sigil, $name ) = $token->{data} =~ /(.)(.*)/;

            if ( $sigil eq '$' && $i != $#$tokens ) {
                $type = $tokens->[ $i + 1 ]{type};

                if ( $type == T_LeftBrace ) {
                    _var_is_used( \@vars, "\%$name" );
                }
                elsif ( $type == T_LeftBracket ) {
                    _var_is_used( \@vars, "\@$name" );
                }
                else {
                    _var_is_used( \@vars, $token->{data} );
                }
            }
            elsif ( $sigil eq '@' && $i != $#$tokens ) {
                if ( $tokens->[ $i + 1 ]{type} == T_LeftBrace ) {
                    _var_is_used( \@vars, "\%$name" );
                }
                else {
                    _var_is_used( \@vars, $token->{data} );
                }
            }
            else {
                _var_is_used( \@vars, $token->{data} );
            }
        }
        # HACK Treat derefs as a new scope so that the braces stay balenced.
        elsif (
               $type == T_LeftBrace
            || $type == T_ArrayDereference
            || $type == T_CodeDereference
            || $type == T_HashDereference
            || $type == T_ScalarDereference
        ) {
            push @vars, {};
        }
        elsif ( $type == T_RightBrace ) {
            my $vars = pop @vars;

            push @errors, qq/"$_" is never read from, declared line $vars->{$_}./
                for sort keys %$vars;
        }
        elsif (
               $type == T_ShortArrayDereference
            || $type == T_ShortCodeDereference
            || $type == T_ShortHashDereference
            || $type == T_ShortScalarDereference
        ) {
            _var_is_used( \@vars, '$' . $tokens->[ ++$i ]{data} );
        }
        elsif ( $type == T_RegExp ) {
            # Ensure we don't mistake // for q//.
            _find_vars_in_str( \@vars, $token->{data} )
                if $tokens->[ $i - 2 ]{type} != T_RegQuote;
        }
        elsif (
               $type == T_String
            || $type == T_ExecString
            || $type == T_RegReplaceFrom
            || $type == T_RegReplaceTo
        ) {
            _find_vars_in_str( \@vars, $token->{data} );
        }
        elsif ( $type == T_RegDoubleQuote ) {
            _find_vars_in_str( \@vars, $tokens->[ $i += 2 ]{data} );
        }
        elsif ( $type == T_HereDocumentBareTag || $type == T_HereDocumentTag ) {
            # Look ahead to where the here document is.
            # Don't use $i so we don't miss any errors between here & there.
            my $j;
            for ( $j = $i; $tokens->[$j]{type} != T_HereDocument; $j++ ) {}

            _find_vars_in_str( \@vars, $tokens->[$j]{data} );
        }
        elsif ( $type == T_ArraySize ) {
            _var_is_used( \@vars, '@' . $tokens->[ ++$i ]{data} );
        }
    }

    push @errors, qq/"$_" is never read from, declared line $vars[-1]{$_}./
        for sort keys %{ $vars[-1] };

    \@errors, $tokens->[-1]{line};
}

1;
