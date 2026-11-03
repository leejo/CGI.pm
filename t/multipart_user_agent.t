#!perl

# the client controlled User-Agent must not change how a multipart body
# is parsed - CGI.pm used to drop the "--" from the boundary for IE 3.01 on
# the Mac and DreamPassport, which let a field value start a new part

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

my $smuggled = "hello XB\r\nContent-Disposition: form-data; name=\"is_admin\"\r\n\r\n1";

my $body = join "\r\n",
    '--XB',
    'Content-Disposition: form-data; name="comment"',
    '',
    $smuggled,
    '--XB',
    'Content-Disposition: form-data; name="f"; filename="x.txt"',
    '',
    'file data',
    '--XB--',
    '';

for my $ua (
    'Mozilla/5.0',
    'Mozilla/5.0 DreamPassport/3.0',
    'Mozilla/2.0 (compatible; MSIE 3.01; Mac_PowerPC)',
    'Mozilla/2.0 (compatible; MSIE 3.02; Macintosh)',
) {
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD}  = 'POST';
    local $ENV{CONTENT_TYPE}    = 'multipart/form-data; boundary=XB';
    local $ENV{CONTENT_LENGTH}  = length $body;
    local $ENV{QUERY_STRING}    = '';
    local $ENV{HTTP_USER_AGENT} = $ua;
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;

    my $q = eval { CGI->new };
    is( $@, '', "User-Agent: $ua - body parses" );
    is_deeply( [ $q ? $q->param : () ], [ qw/ comment f / ], ' ... into the same params' );
    is( $q && $q->param('comment'), $smuggled, ' ... with the field value intact' );
    ok( ! ( $q && defined $q->param('is_admin') ), ' ... and no smuggled field' );
    my $fh = $q && $q->upload('f');
    is( $fh && do { local $/; <$fh> }, 'file data', ' ... and the upload intact' );
}

done_testing();
