#!perl

# read_postdata_putdata must read the request body in chunks rather than
# slurping the whole of CONTENT_LENGTH into memory in a single read, and
# must never read past CONTENT_LENGTH

use strict;
use warnings;

use Test::More;
use CGI;

my $body  = join( '', map { chr( $_ % 256 ) } 1 .. 20_000 );
my $extra = 'NOT PART OF THIS REQUEST';
my $unit  = $CGI::MultipartBuffer::INITIAL_FILLUNIT;

ok( $unit && $unit < length( $body ), "fill unit ($unit) is smaller than the body" );

for my $method ( qw/ POST PUT PATCH / ) {

    my $stdin = $body . $extra;

    local $ENV{REQUEST_METHOD} = $method;
    local $ENV{CONTENT_TYPE}   = 'application/octet-stream';
    local $ENV{CONTENT_LENGTH} = length( $body );
    local $ENV{QUERY_STRING}   = '';

    {
        CGI::initialize_globals();
        local *STDIN;
        open STDIN, '<', \$stdin or die "In-memory filehandle failed\n";
        binmode STDIN;

        my @chunks;
        my $last_total;
        my $q = CGI->new( sub {
            my ( $param, $data, $total ) = @_;
            push @chunks, length $data;
            $last_total = $total;
        } );

        my $fh = $q->param( "${method}DATA" );
        ok( ref $fh, "$method: ${method}DATA is a filehandle" );

        cmp_ok( scalar @chunks, '>', 1, " ... body was read in more than one chunk" );
        cmp_ok( ( sort { $b <=> $a } @chunks )[0], '<=', $unit, " ... no chunk was larger than $unit bytes" );
        is( $last_total, length( $body ), " ... upload hook saw all of the body" );

        my $got = do { local $/; <$fh> };
        ok( defined $got && $got eq $body, " ... and the tempfile contents are not corrupted" );

        is( do { local $/; <STDIN> }, $extra, " ... and nothing past CONTENT_LENGTH was read" );
    }

    {
        CGI::initialize_globals();
        local $CGI::PUTDATA_UPLOAD  = 1;
        local $CGI::DISABLE_UPLOADS = 1;
        local *STDIN;
        open STDIN, '<', \$stdin or die "In-memory filehandle failed\n";
        binmode STDIN;

        CGI->new;
        is( do { local $/; <STDIN> }, $extra, "$method with DISABLE_UPLOADS: nothing past CONTENT_LENGTH was read" );
    }
}

done_testing();
