#!perl

use strict;
use warnings;
use Test::More 'no_plan';

use CGI;

my $q    = CGI->new;
my $CRLF = $MultipartBuffer::CRLF;

like(
    $q->multipart_start,
    qr!^Content-Type: text/html$CRLF$CRLF$!,
    'multipart_start with no args'
);

like(
    $q->multipart_start( -type => 'text/plain' ),
    qr!^Content-Type: text/plain$CRLF$CRLF$!,
    'multipart_start with type'
);

like(
    $q->multipart_start( -charset => 'utf-8' ),
    qr!^Content-Type: text/html; charset=utf-8$CRLF$CRLF$!,
    'multipart_start with charset'
);

like(
    $q->multipart_start( -type => 'text/plain', -charset => 'utf-8' ),
    qr!^Content-Type: text/plain; charset=utf-8$CRLF$CRLF$!,
    'multipart_start with type and charset'
);
