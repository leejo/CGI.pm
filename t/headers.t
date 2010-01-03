use strict;
use warnings;

use Test::More tests => 4;                      # last test to print

use CGI;

my $cgi = CGI->new;

like $cgi->header( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'known header';

like $cgi->header( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'unknown header';

like $cgi->redirect( -type => "text/html\nevil: stuff" ),
    qr#Type: text/html\n evil: stuff#, 'redirect w/ known header';

like $cgi->redirect( -foobar => "text/html\nevil: stuff" ),
    qr#Foobar: text/html\n evil: stuff#, 'redirect w/ unknown header';
