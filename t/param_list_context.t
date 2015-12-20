#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Test::Deep;
use Test::Warn;

use CGI ();

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';

my $q = CGI->new;
ok $q,"CGI::new()";

my @params;

warnings_are
	{ @params = $q->param }
	[],
    "calling ->param with no args in list does not warn"
;

warning_like
	{ @params = $q->param('game') }
	qr/CGI::param called in list context from .+param_list_context\.t line 28, this can lead to vulnerabilities/,
    "calling ->param with args in list context warns"
;

warnings_are
	{ @params = $q->param('game') }
	[],
    " ... but we only warn once",
;

cmp_deeply(
	[ sort @params ],
	[ qw/ checkers chess / ],
	'CGI::param()',
);

warnings_are
	{ @params = $q->multi_param('game') }
	[],
	"no warnings calling multi_param"
;

cmp_deeply(
	[ sort @params ],
	[ qw/ checkers chess / ],
	'CGI::multi_param'
);

$CGI::LIST_CONTEXT_WARN = 0;

warnings_are
	{ @params = $q->param }
	[],
	"no warnings when LIST_CONTEXT_WARN set to 0"
;
