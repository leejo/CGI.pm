
# Test that header generation is spec compliant.
# Reference: http://www.w3.org/Protocols/rfc2616/rfc2616.html

use strict;
use warnings;

use Test::More 'no_plan';

use CGI;

my $cgi = CGI->new;

like $cgi->header( -type => "text/html" ),
    qr#Type: text/html#, 'known header, basic case: type => "text/html"';

like $cgi->header( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'known header';

like $cgi->header( -type => "text/html\n evil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'known header, with leading whitespace on the continuation line';

like $cgi->header( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'unknown header';

like $cgi->redirect( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'redirect w/ known header';

like $cgi->redirect( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'redirect w/ unknown header';
