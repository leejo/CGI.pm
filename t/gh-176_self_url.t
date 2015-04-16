#!perl

use strict;
use warnings;
use Test::More;

use CGI;

$ENV{REQUEST_METHOD} = 'GET';
$ENV{QUERY_STRING}   = 'game=chess';
$ENV{SERVER_NAME}    = 'foo';
$ENV{SCRIPT_NAME}    = $ENV{PATH_INFO} = '/a.pl';

my $q = CGI->new;

is(
	$q->self_url,
	'http://foo/a.pl?game=chess',
	'self_url when SCRIPT_NAME eq PATH_INFO (! IIS)'
);

$ENV{SCRIPT_NAME} = '/b.pl';
$ENV{PATH_INFO}   = '/a.pl';

is(
	$q->self_url,
	'http://foo/a.pl?game=chess',
	'self_url when SCRIPT_NAME ne PATH_INFO (! IIS)'
);

$CGI::IIS = 1;

is(
	$q->self_url,
	'http://foo/a.pl?game=chess',
	'self_url when SCRIPT_NAME ne PATH_INFO (IIS)'
);

done_testing();
