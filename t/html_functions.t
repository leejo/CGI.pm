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

	is( $q->$tag( { bar => 'boz' } ),"<$tag bar=\"boz\" />","$tag function" );

	next if ($tag eq 'html');

	my $start = "start_$tag";
	is( $q->$start( 'foo' ),"<$tag>","$start function" );

	my $end = "end_$tag";
	is( $q->$end( 'foo' ),"</$tag>","$end function" );
}

ok( $q->compile,'compile' );
