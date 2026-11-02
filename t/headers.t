
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

eval { $cgi->header( -type => "text/html".$CGI::CRLF."evil: stuff" ) };
like($@,qr/contains a newline/,'invalid header blows up');

like $cgi->header( -type => "text/html".$CGI::CRLF." evil: stuff " ),
    qr#Content-Type: text/html evil: stuff#, 'known header, with leading and trailing whitespace on the continuation line';

eval { $cgi->header( -p3p => ["foo".$CGI::CRLF."bar"] ) };
like($@,qr/contains a newline/,'P3P header with CRLF embedded blows up');

eval { $cgi->header( -cookie => ["foo".$CGI::CRLF."bar"] ) };
like($@,qr/contains a newline/,'Set-Cookie header with CRLF embedded blows up');

eval { $cgi->header( -foobar => "text/html".$CGI::CRLF."evil: stuff" ) };
like($@,qr/contains a newline/,'unknown header with CRLF embedded blows up');

eval { $cgi->header( -foobar => $CGI::CRLF."Content-type: evil/header" ) };
like($@,qr/contains a newline/, 'unknown header with leading newlines blows up');

eval { $cgi->redirect( -type => "text/html".$CGI::CRLF."evil: stuff" ) };
like($@,qr/contains a newline/,'redirect with known header with CRLF embedded blows up');

eval { $cgi->redirect( -foobar => "text/html".$CGI::CRLF."evil: stuff" ) };
like($@,qr/contains a newline/,'redirect with unknown header with CRLF embedded blows up');

eval { $cgi->redirect( $CGI::CRLF.$CGI::CRLF."Content-Type: text/html") };
like($@,qr/contains a newline/,'redirect with leading newlines blows up');

{
    my $cgi = CGI->new('t=bogus%0A%0A<html>');
    my $out;
	$CGI::LIST_CONTEXT_WARN = 0;
    eval { $out = $cgi->redirect( $cgi->param('t') ) };
    like($@,qr/contains a newline/, "redirect does not allow double-newline injection");
}



# extra header values are HTML unescaped, so entity encoded newlines must
# be caught too - rearrange() only escapes & when autoEscape is on
for my $escape ( 1, 0 ) {
    my $cgi = CGI->new('');
    local $CGI::Q = $cgi;
    $cgi->autoEscape($escape);

    for my $nl ( '&#13;&#10;', '&#10;', '&#x0d;&#x0a;', "\015\012" ) {
        my $out = eval { $cgi->header( -foobar => "bar${nl}Set-Cookie: evil=1" ) };
        unlike( $out // '', qr/^Set-Cookie: evil/m, "autoEscape($escape): header does not inject a header via '$nl'" );

        $out = eval { $cgi->redirect( -uri => '/x', -foobar => "bar${nl}Set-Cookie: evil=1" ) };
        unlike( $out // '', qr/^Set-Cookie: evil/m, "autoEscape($escape): redirect does not inject a header via '$nl'" );
    }
}

{
    my $cgi = CGI->new('');
    local $CGI::Q = $cgi;
    $cgi->autoEscape(0);
    eval { $cgi->header( -foobar => "bar&#13;&#10;Set-Cookie: evil=1" ) };
    like($@,qr/contains a newline/,'entity encoded CRLF in unknown header blows up with autoEscape off');

    like $cgi->header( -foobar => "bar&#13;&#10; continued" ),
        qr#Foobar: bar continued#, 'entity encoded CRLF followed by whitespace is unfolded';
}
