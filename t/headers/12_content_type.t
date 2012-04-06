use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( '-Content-Type' => 'text/plain; charset=utf-8' );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type';
}

{
    my $q = CGI->new;
    my $got = $q->header( '-Content-Type' => 'text/plain' );
    my $expected = 'Content-Type: text/plain; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type without charset';
}

{
    my $q = CGI->new;
    my $got = $q->header( '-Content-Type' => q{} );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'content-type empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header( '-Content-Type' => 'charset=utf-8' );
    my $expected = "Content-Type: charset=utf-8" . $CGI::CRLF x 2;
    is $got, $expected, 'content-type edge case';
}

done_testing;
