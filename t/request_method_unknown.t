#!perl

# offline (command line) debugging mode must only be used when there is no
# request - it was used for any unrecognised REQUEST_METHOD, which a client
# can send (OPTIONS, PROPFIND, "post", ...), making the process' own
# command line arguments the request params

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

sub new_cgi {
    my ( $argv, %env ) = ref $_[0] ? @_ : ( [ 'mode=admin' ], @_ );
    CGI::initialize_globals();
    local %ENV = %ENV;
    delete @ENV{qw/ REQUEST_METHOD GATEWAY_INTERFACE FCGI_ROLE QUERY_STRING CONTENT_LENGTH CONTENT_TYPE PATH_INFO /};
    $ENV{$_} = $env{$_} for keys %env;
    local @ARGV = @$argv;
    return CGI->new;
}

ok( $CGI::DEBUG, 'sanity: DEBUG is on by default' );

for my $method ( qw/ OPTIONS PROPFIND TRACE post get FOO / ) {
    for my $server ( [ GATEWAY_INTERFACE => 'CGI/1.1' ], [], [ FCGI_ROLE => 'RESPONDER' ] ) {
        my $q = new_cgi( [ '/fake/path?mode=admin' ], REQUEST_METHOD => $method, QUERY_STRING => 'q=1', @$server );
        my $label = "REQUEST_METHOD=$method" . ( @$server ? " $server->[0]=$server->[1]" : '' );
        ok( ! defined $q->param('mode') && ! defined $q->param('admin'), "$label: command line args are not params" );
        is( $q->path_info, '', ' ... nor is path_info taken from them' );
    }
}

{
    my $q = new_cgi( GATEWAY_INTERFACE => 'CGI/1.1' );
    ok( ! defined $q->param('mode'), 'no REQUEST_METHOD under a server: command line args are not params' );
}

{
    my $q = new_cgi( FCGI_ROLE => 'RESPONDER' );
    ok( ! defined $q->param('mode'), 'no REQUEST_METHOD under FastCGI: command line args are not params' );
}

{
    # offline debugging still works
    my $q = new_cgi( [ 'mode=admin', 'x=1' ] );
    is( $q->param('mode'), 'admin', 'no request at all: command line args are params (offline debugging)' );
    $q = new_cgi( [ '/fake/path?mode=admin' ] );
    is( $q->path_info, '/fake/path', ' ... including path_info' );
    is( $q->param('mode'), 'admin', ' ... and the query after it' );
}

{
    # and normal requests are unaffected
    my $q = new_cgi( REQUEST_METHOD => 'GET', GATEWAY_INTERFACE => 'CGI/1.1', QUERY_STRING => 'q=1' );
    is_deeply( [ $q->param ], [ 'q' ], 'GET request: params are from the query string only' );
}

done_testing();
