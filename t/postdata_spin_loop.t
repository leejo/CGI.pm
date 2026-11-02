#!perl

# read_postdata_putdata tolerates up to $CGI::MultipartBuffer::SPIN_LOOP_MAX
# consecutive zero length reads (as some servers return them spuriously),
# as the multipart parser does - it compared against $CGI::SPIN_LOOP_MAX,
# which is never set, so died on the first one

use strict;
use warnings;

use Test::More;
use CGI;

my $max  = $CGI::MultipartBuffer::SPIN_LOOP_MAX;
my $body = 'x' x 10_000;
ok( $max, "SPIN_LOOP_MAX is set ($max)" );

# make read_from_client return 0 bytes $zeros times before every real read
sub request {
    my ( %args ) = @_;
    CGI::initialize_globals();
    local $CGI::PUTDATA_UPLOAD  = 1;
    local $CGI::DISABLE_UPLOADS = $args{disable_uploads} || 0;
    local $ENV{REQUEST_METHOD}  = 'PUT';
    local $ENV{CONTENT_TYPE}    = 'application/octet-stream';
    local $ENV{CONTENT_LENGTH}  = length $body;
    local $ENV{QUERY_STRING}    = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";

    my $orig  = \&CGI::read_from_client;
    my $zeros = 0;
    no warnings 'redefine';
    local *CGI::read_from_client = sub {
        return 0 if $zeros++ < $args{zeros};
        $zeros = 0;
        return $orig->( @_ );
    };
    return CGI->new;
}

for my $disable_uploads ( 0, 1 ) {
    my $label = "DISABLE_UPLOADS=$disable_uploads";

    my $q = eval { request( zeros => $max, disable_uploads => $disable_uploads ) };
    is( $@, '', "$label: $max zero length reads between real ones are tolerated" );
    unless ( $disable_uploads ) {
        my $fh = $q && $q->param('PUTDATA');
        is( $fh && do { local $/; <$fh> }, $body, ' ... and the body is read in full' );
    }

    eval { request( zeros => $max + 1, disable_uploads => $disable_uploads ) };
    like( $@, qr/Server closed socket during read_postdata_putdata/, "$label: but " . ( $max + 1 ) . ' in a row are not' );
}

done_testing();
