#!perl

# CGI::Carp's warningsToBrowser() buffers warnings in package state, which
# must be reset between requests in a persistent environment so that one
# request's warnings (which may contain that user's data) are never
# emitted into another request's output

use strict;
use warnings;

use Test::More;
use CGI::Carp qw( warningsToBrowser );
use CGI;

# warnings also go to STDERR via CGI::Carp::warn, keep the test output clean
open my $stderr, '>', \my $ignored_stderr or die $!;
local *STDERR = $stderr;

sub request {
    my ( %args ) = @_;
    my $out = '';
    local *STDOUT;
    open STDOUT, '>', \$out or die "In-memory filehandle failed: $!\n";
    $args{code}->();
    close STDOUT;
    return $out;
}

for my $reset (
    [ 'CGI::initialize_globals' => sub { CGI::initialize_globals() } ],
    [ 'CGI::_reset_globals'     => sub { CGI->_reset_globals } ], # CGI::Fast
) {
    my ( $name, $reset_sub ) = @$reset;

    # request A: e.g. a JSON endpoint that never calls warningsToBrowser
    $reset_sub->();
    my $a_out = request( code => sub {
        print "Content-Type: application/json\r\n\r\n{}";
        warn "secret for alice\n";
    } );
    unlike( $a_out, qr/secret for alice/, "$name: request A's warning is buffered, not printed" );

    # request B: an HTML page that does call warningsToBrowser
    $reset_sub->();
    my $b_out = request( code => sub {
        print "Content-Type: text/html\r\n\r\n<html>";
        warn "warning for bob\n";
        warningsToBrowser(1);
        print "</html>";
    } );
    unlike( $b_out, qr/secret for alice/, " ... request A's warning is not emitted into request B" );
    like( $b_out, qr/<!-- warning: warning for bob -->/, " ... but request B's own warning is" );

    # request C: warnings must not be printed before C's headers just
    # because B turned warningsToBrowser on
    $reset_sub->();
    my $c_out = request( code => sub {
        warn "early warning for carol\n";
        print "Content-Type: application/json\r\n\r\n{}";
    } );
    like( $c_out, qr/\AContent-Type/, " ... and warnings aren't printed before the next request's headers" );
    unlike( $c_out, qr/warning for bob/, " ... nor is request B's warning emitted into request C" );
}

done_testing();
