use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -cookie => 'foo' );
    my $expected = "^Set-Cookie: foo$CGI::CRLF"
                 . "Date: [^$CGI::CRLF]+$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    like $got, qr($expected), 'cookie';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -cookie => [ 'foo', 'bar' ]  );
    my $expected = "^Set-Cookie: foo$CGI::CRLF"
                 . "Set-Cookie: bar$CGI::CRLF"
                 . "Date: [^$CGI::CRLF]+$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    like $got, qr($expected), 'cookie arrayref';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -cookie => q{} );
    my $expected = 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'cookie empty string';
}

done_testing;
