#!perl

# multipart boundaries must be valid: RFC 2046 limits them to 70 characters,
# CGI.pm allows up to $CGI::MultipartBuffer::MAX_BOUNDARY_LENGTH. a boundary
# approaching the read size (4096) previously corrupted and merged parts

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

my $C   = "\r\n";
my $max = $CGI::MultipartBuffer::MAX_BOUNDARY_LENGTH;
is( $max, 200, 'MAX_BOUNDARY_LENGTH is 200' );

sub body {
    my ( $boundary, $size ) = @_;
    return join $C,
        "--$boundary",
        'Content-Disposition: form-data; name="a"',
        '',
        'a' x $size,
        "--$boundary",
        'Content-Disposition: form-data; name="c"',
        '',
        'C',
        "--$boundary--",
        '';
}

sub parse {
    my ( $body, $content_type ) = @_;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = $content_type;
    local $ENV{CONTENT_LENGTH} = length $body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

for my $length ( 1, 40, 70, $max ) {
    my $boundary = 'B' x $length;
    for my $how ( 'header', 'body' ) {
        my @bad;
        for my $size ( 0, 1, 4000 .. 4200 ) {
            my $q = eval {
                parse( body( $boundary, $size ),
                    $how eq 'header' ? "multipart/form-data; boundary=$boundary" : 'multipart/form-data' )
            };
            push @bad, $size unless $q && length( $q->param('a') ) == $size && $q->param('c') eq 'C';
        }
        is_deeply( \@bad, [], "$length character boundary (from $how) parses correctly" );
    }
}

for my $length ( $max + 1, 4095, 4096, 5000 ) {
    my $boundary = 'B' x $length;
    eval { parse( body( $boundary, 10 ), "multipart/form-data; boundary=$boundary" ) };
    like( $@, qr/Malformed multipart POST: invalid boundary/, "$length character boundary (from header) is rejected" );
    next if $length + 2 > $CGI::MultipartBuffer::MAX_BOUNDARY_LINE;
    eval { parse( body( $boundary, 10 ), 'multipart/form-data' ) };
    like( $@, qr/Malformed multipart POST: invalid boundary/, "$length character boundary (from body) is rejected" );
}

for my $first_line ( '--', 'XYZ', '' ) {
    eval { parse( "$first_line${C}Content-Disposition: form-data; name=\"a\"$C${C}1$C$first_line--$C", 'multipart/form-data' ) };
    like( $@, qr/Malformed multipart POST: invalid boundary/, "a body starting with the line '$first_line' is rejected" );
}

done_testing();
