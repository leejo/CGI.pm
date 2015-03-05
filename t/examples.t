#!perl

use strict;
use warnings;

use Test::More;
use CGI;
use FindBin qw/ $Bin /;

# skip if necessary modules for running this test are not installed
# or if the env variable to run this test is not set

if( ! eval 'use Template; 1' ) {
  plan skip_all => "Template is required";
} elsif ( ! eval 'use Test::Command; 1' ) {
  plan skip_all => "Test::Command is required";
} elsif ( ! $ENV{CGI_EXAMPLES_TESTING} ) {
  plan skip_all => "CGI_EXAMPLES_TESTING must be set";
}

my %examples = (
	"clickable_image.cgi" => {
		'magnification=2 letter=C picture.x=50 picture.y=45' => [
			qr/value="2" checked="checked"/,
			qr/Selected Position <strong>\(50,45\)/,
		],
	},
	"cookie.cgi" => {
		'' => [
			qr/Animal Crackers/,
		],
	}
);

foreach my $example ( sort keys( %examples ) ) {
	foreach my $args ( sort keys( %{ $examples{$example} } ) ) {
		foreach my $regexp ( @{ $examples{$example}{$args} } ) {
			stdout_like(
				"$^X $Bin/../examples/$example $args",
				$regexp,
				$example
			);
		}
	}
}

done_testing();
