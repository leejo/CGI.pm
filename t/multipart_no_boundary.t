#!perl

# multipart/form-data with no boundary= in the Content-Type: the boundary
# is taken from the first line of the body, which must be read in bounded
# size (it previously used an unbounded readline, bypassing $POST_MAX)

use strict;
use warnings;

use Test::More;
use CGI;

my $body = join "\r\n",
    '--XYZ',
    'Content-Disposition: form-data; name="a"',
    '',
    'hello',
    '--XYZ',
    'Content-Disposition: form-data; name="f"; filename="x.txt"',
    '',
    'file data',
    '--XYZ--',
    '';

sub new_cgi {
    my ( $req_body, $chunked ) = @_;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = 'multipart/form-data';
    local $ENV{QUERY_STRING}   = '';
    local $ENV{CONTENT_LENGTH} = length $req_body;
    delete $ENV{CONTENT_LENGTH} if $chunked;
    local *STDIN;
    open STDIN, '<', \$req_body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

for my $chunked ( 0, 1 ) {
    my $label = $chunked ? 'without CONTENT_LENGTH' : 'with CONTENT_LENGTH';

    my $q = eval { new_cgi( $body, $chunked ) };
    is( $q && $q->param('a'), 'hello', "$label: boundary is read from the body" );
    my $fh = $q && $q->upload('f');
    is( $fh && do { local $/; <$fh> }, 'file data', ' ... and the upload is intact' );
    is( $q && $q->cgi_error, undef, ' ... with no error' );

    for my $bad (
        [ ( '-' x 5000 ) . "\r\n--XYZ--\r\n", 'an overlong boundary line' ],
        [ '--XYZ', 'no CRLF after the boundary' ],
    ) {
        eval { new_cgi( $bad->[0], $chunked ) };
        like( $@, qr/Malformed multipart POST: boundary line too long or missing/, "$label: $bad->[1] is rejected" );
    }
}

{
    # the boundary line counts towards $POST_MAX
    local $CGI::POST_MAX = 60;
    my $q = eval { new_cgi( $body, 1 ) };
    is( $q && $q->cgi_error, '413 Request entity too large', 'POST_MAX applies to a body without a boundary= or CONTENT_LENGTH' );
}

{
    # only $MAX_BOUNDARY_LINE bytes are ever read looking for the boundary
    my $read = 0;
    no warnings 'redefine';
    my $orig = \&CGI::read_from_client;
    local *CGI::read_from_client = sub { my $n = $orig->(@_); $read += $n if $n; $n };
    eval { new_cgi( 'A' x ( 1024 * 1024 ), 1 ) };
    like( $@, qr/boundary line too long/, 'a 1MB boundary line is rejected' );
    cmp_ok( $read, '<=', $CGI::MultipartBuffer::MAX_BOUNDARY_LINE, " ... having read at most $CGI::MultipartBuffer::MAX_BOUNDARY_LINE bytes" );
}

done_testing();
