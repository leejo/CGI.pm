use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use CGI;

$ENV{REQUEST_METHOD} = 'PUT';

eval {
	local $SIG{ALRM} = sub { die "timeout!" };
	alarm 10;
	my $cgi = CGI->new;
	alarm 0;
	pass( 'new() returned' );
};
$@ && do {
	fail( "CGI->new did not return" );
};
