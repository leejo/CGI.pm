#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use CGI qw/ -compile :all /;

# check html functions are imported into this namespace
# with the -compile pragma
is( a({ bar => "boz" }),"<a bar=\"boz\" />","-compile" );

my $q = CGI->new;

foreach my $tag ( $q->_all_html_tags ) {

	is(
		$q->$tag(),
		"<$tag />",
		"$tag function (no args)"
	);

	is(
		$q->$tag( 'some','contents' ),
		"<$tag>some contents</$tag>",
		"$tag function (content)"
	);

	is(
		$q->$tag( { bar => 'boz', biz => 'baz' } ),
		"<$tag bar=\"boz\" biz=\"baz\" />",
		"$tag function (attributes)"
	);

	is(
		$q->$tag( { bar => 'boz' },'some','contents' ),
		"<$tag bar=\"boz\">some contents</$tag>",
		"$tag function (attributes and content)"
	);

	next if ($tag eq 'html');

	my $start = "start_$tag";
	is( $q->$start( 'foo' ),"<$tag>","$start function" );

	my $end = "end_$tag";
	is( $q->$end( 'foo' ),"</$tag>","$end function" );
}

ok( $q->compile,'compile' );
