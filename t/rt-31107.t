#!/usr/local/bin/perl -w

use strict;

use Test::More 'no_plan';

use CGI;

$ENV{REQUEST_METHOD} = 'POST';
$ENV{CONTENT_TYPE}   = 'multipart/related;boundary="----=_Part_0.7772611529786723.1196412625897" type="text/xml"; start="cid:mm7-submit"';

my $q;

{
    local *STDIN;
    open STDIN, '<t/rt_31107.txt'
        or die 'missing test file t/rt_31107.txt';
    binmode STDIN;
    $q = CGI->new;
}

foreach my $class ( 'File::Temp','CGI::File::Temp','Fh' ) {
	isa_ok( $q->param( 'capabilities.zip' ),$class,'capabilities.zip' );
	isa_ok( $q->param( 'mm7-submit' ),$class,'mm7-submit' );
}

my $fh = $q->param( 'mm7-submit' );

my @content = $fh->getlines;
like(
	$content[9],
	qr!<CapRequestId>4401196412625869430</CapRequestId>!,
	'multipart data read'
);

# test back compatibility handle method
seek( $fh,0,0 );
@content = $fh->handle->getlines;
like(
	$content[9],
	qr!<CapRequestId>4401196412625869430</CapRequestId>!,
	'multipart data read'
);
