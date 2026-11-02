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

eval { $q->multipart_start( -type => "text/plain${CRLF}X-Evil: 1" ) };
like( $@, qr/contains a newline/, 'multipart_start with CRLF in type blows up' );

eval { $q->multipart_start( -charset => "utf-8${CRLF}X-Evil: 1" ) };
like( $@, qr/contains a newline/, 'multipart_start with CRLF in charset blows up' );

eval { $q->multipart_start( -foobar => "bar${CRLF}X-Evil: 1" ) };
like( $@, qr/contains a newline/, 'multipart_start with CRLF in unknown header blows up' );

{
    local $CGI::Q = $q;
    for my $escape ( 1, 0 ) {
        $q->autoEscape($escape);
        my $out = eval { $q->multipart_start( -foobar => "bar&#13;&#10;X-Evil: 1" ) };
        unlike( $out // '', qr/^X-Evil/m, "autoEscape($escape): multipart_start does not inject a header via entity encoded CRLF" );
    }
    $q->autoEscape(1);
}

like(
    $q->multipart_start( -type => "text/plain${CRLF} continued" ),
    qr!^Content-Type: text/plain continued$CRLF$CRLF$!,
    'multipart_start unfolds CRLF followed by whitespace'
);
