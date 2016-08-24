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

sub import {
    no strict 'refs';

    *{ caller . '::plint' } = \&plint;
}

sub plint {
    local ( @ARGV, $/ ) = @_;

    my ( $tokens, @errors ) = Compiler::Lexer::tokenize( $lexer, scalar <> );

    for ( my $i = 0; my $token = $tokens->[$i]; $i++ ) {
        my $type = $token->{type};

        if ( $type == T_Return ) {
            next unless $token = $tokens->[ ++$i ];

            $token = $tokens->[ ++$i ] if $token->{type} == T_LeftParenthesis;

            push @errors,
                qq/"return" statement with explicit "undef" at line $token->{line}./
                if $token->{type} == T_Default
                && $token->{data} eq 'undef'
                && ( $i == $#$tokens || $tokens->[ ++$i ]{type} != T_Comma );
        }
        elsif ( $type == T_BuiltinFunc ) {
            my $data = $token->{data};

            if ( $data eq 'eval' ) {
                my $line = $token->{line};

                push @errors, qq/Expression form of "eval" at line $line./
                    unless ( $token = $tokens->[ ++$i ] )
                    && ( $token->{type} == T_LeftBrace
                    || $token->{type} == T_LeftParenthesis
                    && $tokens->[ ++$i ]{type} == T_LeftBrace );
            }
        }
        elsif ( $type == T_SpecificValue ) {
            if ( $token->{data} eq '$_' ) {
                $type = ( $tokens->[ ++$i ] or next )->{type};

                if ( $type == T_RegOK || $type == T_RegNot ) {
                    $type = $tokens->[ ++$i ]{type};

                    push @errors,
                        "\$_ should be omitted when matching a regular expression at line $token->{line}."
                        if $type != T_Var && $type != T_GlobalVar;
                }
            }
        }
    }

    \@errors, $tokens->[-1]{line};
}

1;
