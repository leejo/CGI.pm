
# Test that header generation is spec compliant.
# References:
#   http://www.w3.org/Protocols/rfc2616/rfc2616.html
#   http://www.w3.org/Protocols/rfc822/3_Lexical.html

use strict;
use warnings;

use Test::More 'no_plan';

use CGI;

my $cgi = CGI->new;

like $cgi->header( -type => "text/html" ),
    qr#Type: text/html#, 'known header, basic case: type => "text/html"';

eval { like $cgi->header( -type => "text/html".$CGI::CRLF."evil: stuff" ),
    qr#Type: text/html evil: stuff#, 'known header'; };
like($@,qr/contains a newline/,'invalid header blows up');

like $cgi->header( -type => "text/html".$CGI::CRLF." evil: stuff " ),
    qr#Content-Type: text/html evil: stuff#, 'known header, with leading and trailing whitespace on the continuation line';

eval { like $cgi->header( -foobar => "text/html".$CGI::CRLF."evil: stuff" ),
    qr#Foobar: text/htmlevil: stuff#, 'unknown header'; };
like($@,qr/contains a newline/,'unknown header with CRLF embedded blows up');

like $cgi->header( -foobar => "Content-type: evil/header" ),
    qr#^Foobar: Content-type: evil/header#m, 'unknown header with leading newlines';

eval { like $cgi->redirect( -type => "text/html".$CGI::CRLF."evil: stuff" ),
    qr#Type: text/htmlevil: stuff#, 'redirect w/ known header'; };
like($@,qr/contains a newline/,'redirect with known header with CRLF embedded blows up');

eval { like $cgi->redirect( -foobar => "text/html".$CGI::CRLF."evil: stuff" ),
    qr#Foobar: text/htmlevil: stuff#, 'redirect w/ unknown header'; };
like($@,qr/contains a newline/,'redirect with unknown header with CRLF embedded blows up');

eval { like $cgi->redirect( $CGI::CRLF.$CGI::CRLF."Content-Type: text/html"),
    qr#Location: Content-Type#, 'redirect w/ leading newline '; };
like($@,qr/contains a newline/,'redirect with leading newlines blows up');

{
    my $cgi = CGI->new('t=bogus%0A%0A<html>');
    my $out;
    eval { $out = $cgi->redirect( $cgi->param('t') ) };
    like($@,qr/contains a newline/, "redirect does not allow double-newline injection");
}


