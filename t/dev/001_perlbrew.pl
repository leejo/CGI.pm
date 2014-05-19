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

# check available perls and all installed (except < 5.6.2)
my @perls = `$perlbrew available`;

foreach my $perl ( @perls ) {

	chomp( $perl );

	if ( $perl =~ s/^i perl-// ) {

		# yes, backticks...
		# should probably fix this to use App::perlbrew module
		`make clean`;
		`$perlbrew exec --with $perl perl Makefile.PL`;
		$? ? fail( "$perl Makefile.PL" ) : pass( "$perl Makefile.PL" );
		`$perlbrew exec --with $perl perl "-MExtUtils::Command::MM" "-e" "test_harness(0, 'blib/lib', 'blib/arch')", t/*.t t/headers/*.t`;
		
		$? ? fail( "$perl make test" ) : pass( "$perl make test" );
	}
}

done_testing();
