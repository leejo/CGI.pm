use strict;
use warnings;

use Test::More tests => 6;

use CGI;

foreach my $fh ( \*STDOUT,\*STDIN,\*STDERR ) {
	binmode( STDOUT,':utf8' );
	my %layers = map { $_ => 1 } PerlIO::get_layers( \*STDOUT );
	ok( $layers{utf8},'set utf8 on STDOUT' );
}

CGI::_set_binmode();

foreach my $fh ( \*STDOUT,\*STDIN,\*STDERR ) {
	my %layers = map { $_ => 1 } PerlIO::get_layers( \*STDOUT );
	ok( $layers{utf8},'layers were not lost in call to _set_binmode' );
}
