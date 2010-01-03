
# Test that header generation is spec compliant.
# References:
#   http://www.w3.org/Protocols/rfc2616/rfc2616.html
#   http://www.w3.org/Protocols/rfc822/3_Lexical.html

use strict;
use warnings;

use Test::More tests => 6;

use CGI;

my $cgi = CGI->new;

like $cgi->header( -type => "text/html" ),
    qr#Type: text/html#, 'known header, basic case: type => "text/html"';

like $cgi->header( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'known header';

like $cgi->header( -type => "text/html\n evil: stuff " ),
    qr#Content-Type: text/html\n evil: stuff#, 'known header, with leading and trailing whitespace on the continuation line';

like $cgi->header( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'unknown header';

like $cgi->redirect( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'redirect w/ known header';

like $cgi->redirect( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'redirect w/ unknown header';
