#!/usr/local/bin/perl

# coverage for testing that doesn't sit elsewhere

use strict;
use warnings;

use Test::More tests => 25;
use Test::Deep;
use Test::Warn;

use CGI ();

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';

isa_ok( my $q = CGI->new,'CGI' );

# undocumented ->r method, seems to be a temp store?
$q->r( 'foo' );
is( $q->r,'foo','r' );

diag( "cgi-lib.pl routines" );

ok( $q->ReadParse,'ReadParse' );
is( $q->PrintHeader,$q->header,'PrintHeader' );
is( $q->HtmlTop,$q->start_html,'HtmlTop' );
is( $q->HtmlBot,$q->end_html,'HtmlBot' );

cmp_deeply(
	[ my @params = CGI::SplitParam( "foo\0bar" ) ],
	[ qw/ foo bar /],
	'SplitParam'
);

ok( $q->MethGet,'MethGet' );
ok( ! $q->MethPost,'MethPost' );
ok( ! $q->MethPut,'MethPut' );

note( "TIE methods" );
ok( ! $q->FIRSTKEY,'FIRSTKEY' );
ok( ! $q->NEXTKEY,'NEXTKEY' );
ok( ! $q->CLEAR,'CLEAR' );

is( $q->version,$CGI::VERSION,'version' );
is( $q->as_string,'<ul></ul>','as_string' );

is( ( $q->_style )[0],'<link rel="stylesheet" type="text/css" href="" />','_style' );
is( $q->state,'http://localhost','state' );

$CGI::NOSTICKY = 0;
ok( $q->nosticky( 1 ),'nosticky' );
is( $CGI::NOSTICKY,1,' ... sets $CGI::NOSTICKY' );

$CGI::NPH = 0;
ok( $q->nph( 1 ),'nph' );
is( $CGI::NPH,1,' ... sets $CGI::NPH' );

$CGI::CLOSE_UPLOAD_FILES = 0;
ok( $q->close_upload_files( 1 ),'close_upload_files' );
is( $CGI::CLOSE_UPLOAD_FILES,1,' ... sets $CGI::CLOSE_UPLOAD_FILES' );

cmp_deeply(
	$q->default_dtd,
	[
		'-//W3C//DTD HTML 4.01 Transitional//EN',
		'http://www.w3.org/TR/html4/loose.dtd'
	],
	'default_dtd'
);

ok( ! $q->private_tempfiles,'private_tempfiles' );
