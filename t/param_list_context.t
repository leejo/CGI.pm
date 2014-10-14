#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Deep;
use Test::Warn;

use CGI ();

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';

my $q = new CGI;
ok $q,"CGI::new()";

my @params;

warnings_are
	{ @params = $q->param }
	[],
	"no warnings when calling ->param with no args"
;

warning_like
	{ @params = $q->param('game') }
	qr/CGI::param called in list context from package main line 28, this can lead to vulnerabilities/,
    "calling ->param with args in list context warns"
;

cmp_deeply(
	[ sort @params ],
	[ qw/ checkers chess / ],
	'CGI::param()',
);

$CGI::LIST_CONTEXT_WARN = 0;

warnings_are
	{ @params = $q->param }
	[],
	"no warnings when LIST_CONTEXT_WARN set to 0"
;
