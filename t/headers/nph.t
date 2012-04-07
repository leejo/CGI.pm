use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -nph => 1 );
    my $expected = "^HTTP/1.0 200 OK$CGI::CRLF"
                 . "Server: cmdline$CGI::CRLF"
                 . "Date: [^$CGI::CRLF]+$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    like $got, qr($expected), 'nph';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -nph => 0 );
    my $expected = 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'nph';
}

done_testing;
