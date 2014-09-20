#!/usr/local/bin/perl -w

use strict;

use Test::More 'no_plan';

use CGI;

$ENV{REQUEST_METHOD} = 'POST';
$ENV{CONTENT_TYPE}   = 'application/xml';
$ENV{CONTENT_LENGTH} = 792;

my $q;

{
    local *STDIN;
    open STDIN, '<t/rt_75628.txt'
        or die 'missing test file t/rt_75628.txt';
    binmode STDIN;
    $q = CGI->new;
}

like(
	$q->param( 'POSTDATA' ),
	qr!<MM7Version>5.3.0</MM7Version>!,
	'POSTDATA access to XForms:Model'
);
