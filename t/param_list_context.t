#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Deep;
use Test::Warn;

use CGI ();

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';

my $q = new CGI;
ok $q,"CGI::new()";

my @params;

warning_like
	{ @params = $q->param }
	qr/CGI::param called in list context from package main line 22, this can lead to vulnerabilities/,
    "calling ->param in list context warns"
;

cmp_deeply(
	\@params,
	[ qw/ game weather / ],
	'CGI::param()',
);

$CGI::LIST_CONTEXT_WARN = 0;

warnings_are
	{ @params = $q->param }
	[],
	"no warnings when LIST_CONTEXT_WARN set to 0"
