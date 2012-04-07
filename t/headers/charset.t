use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -charset => 'utf-8' );
    my $expected = 'Content-Type: text/html; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -charset => q{} );
    my $expected = 'Content-Type: text/html' . $CGI::CRLF x 2;
    is $got, $expected, 'charset empty string';
}

done_testing;
