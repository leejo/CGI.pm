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

	my $expected_tag = lc( $tag );

	is(
		$q->$tag(),
		"<$expected_tag />",
		"$tag function (no args)"
	);

	is(
		$q->$tag( 'some','contents' ),
		"<$expected_tag>some contents</$expected_tag>",
		"$tag function (content)"
	);

	is(
		$q->$tag( { bar => 'boz', biz => 'baz' } ),
		"<$expected_tag bar=\"boz\" biz=\"baz\" />",
		"$tag function (attributes)"
	);

	is(
		$q->$tag( { bar => 'boz' },'some','contents' ),
		"<$expected_tag bar=\"boz\">some contents</$expected_tag>",
		"$tag function (attributes and content)"
	);

	next if ($tag eq 'html');

	my $start = "start_$tag";
	is( $q->$start( 'foo' ),"<$expected_tag>","$start function" );

	my $end = "end_$tag";
	is( $q->$end( 'foo' ),"</$expected_tag>","$end function" );
}

ok( $q->compile,'compile' );
