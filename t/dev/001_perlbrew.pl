#!perl

# this is a .pl to stop it running under prove
# do not add this file to MANIFEST (yet)

use strict;
use warnings;

use File::Which;
use Test::More;

$ENV{DEV_TESTS}
	or plan skip_all => "set DEV_TESTS=1 to run";

# find perlbrew
my $perlbrew = which( 'perlbrew' )
	or plan skip_all => "perlbrew not found";

# check available perls and all installed
my @perls = `$perlbrew available`;

foreach my $perl ( reverse @perls ) {

	chomp( $perl );

	if ( $perl =~ s/^i perl-// ) {

		# we skip perls before 5.8 as Makefile.PL requires minimum 5.8
		next if $perl =~ /^5\.[0-7]\./;

		# yes, backticks...
		# should probably fix this to use App::perlbrew module
		`make clean`;
		`$perlbrew exec --with $perl perl Makefile.PL`;
		$? ? fail( "$perl Makefile.PL" ) : pass( "$perl Makefile.PL" );
		`$perlbrew exec --with $perl make test`;
		
		$? ? fail( "$perl make test" ) : pass( "$perl make test" );
	}
}

done_testing();
