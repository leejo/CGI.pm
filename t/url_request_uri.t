#!perl

# URLs built from REQUEST_URI (the raw, client controlled, request-target)
# must always point at this host: url() with -absolute and -relative, and
# start_form()'s default action, previously returned e.g. //evil.example,
# http://evil.example or javascript:alert(1)

use strict;
use warnings;

use Test::More;
use URI;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

sub new_cgi {
    my ( $request_uri, $script_name, $path_info ) = @_;
    CGI::initialize_globals();
    $ENV{REQUEST_METHOD} = 'GET';
    $ENV{HTTP_HOST}      = 'victim.example';
    $ENV{SERVER_PORT}    = 80;
    $ENV{SCRIPT_NAME}    = $script_name;
    $ENV{REQUEST_URI}    = $request_uri;
    $ENV{QUERY_STRING}   = $request_uri =~ /\?(.*)/ ? $1 : '';
    if ( defined $path_info ) { $ENV{PATH_INFO} = $path_info } else { delete $ENV{PATH_INFO} }
    return CGI->new;
}

# what a browser would do with the URL in a page at this location
sub resolves_to_victim {
    my ( $url ) = @_;
    ( my $browser_url = $url ) =~ tr{\\}{/}; # browsers treat \ as /
    my $abs = URI->new_abs( $browser_url, 'http://victim.example/some/page' );
    return $abs->scheme eq 'http' && $abs->host eq 'victim.example';
}

my @hostile = (
    '//evil.example/login',
    '///evil.example/login',
    '/%2Fevil.example',
    '/%2F%2Fevil.example/x',
    '/\\evil.example/x',
    '/%5Cevil.example/x',
    '/\\/evil.example/x',
    'http://evil.example/login',
    'https://evil.example',
    '//evil.example',
    '/javascript:alert(1)',
    '/x/javascript:alert(1)',
    '/x/data:text/html,<script>alert(1)</script>',
);

for my $request_uri ( @hostile ) {
    ( my $label = $request_uri ) =~ s/\\/\\\\/g;
    my $q = new_cgi( $request_uri, '/index.cgi' );

    my %urls = (
        'url(-absolute)'        => $q->url( -absolute => 1 ),
        'url(-absolute,-query)' => $q->url( -absolute => 1, -query => 1, -path => 1 ),
        'url(-relative)'        => $q->url( -relative => 1 ),
        'url(-full)'            => $q->url( -full => 1, -path => 1 ),
        'self_url'              => $q->self_url,
    );
    ( $urls{'start_form action'} ) = $q->start_form =~ /action="([^"]*)"/;
    $urls{'start_form action'} = CGI::unescapeHTML( $urls{'start_form action'} );

    for my $what ( sort keys %urls ) {
        ok( resolves_to_victim( $urls{$what} ), "REQUEST_URI=$label: $what ($urls{$what}) stays on this host" );
    }

    is( $q->request_uri, $request_uri, ' ... while request_uri() still returns the literal value' );
}

# a path_info that starts with // must not make an absolute URL protocol
# relative either (e.g. a script mounted at the root)
{
    my $q = new_cgi( '//evil.example/x', '', '//evil.example/x' );
    my $url = $q->url( -absolute => 1, -path => 1 );
    ok( resolves_to_victim( $url ), "url(-absolute,-path) with PATH_INFO=//evil.example/x ($url) stays on this host" );
}

# normal values are unchanged
for my $case (
    [ '/app.cgi',                '/app.cgi',   undef,         '/app.cgi',      'app.cgi', '/app.cgi' ],
    [ '/app.cgi?a=1',            '/app.cgi',   undef,         '/app.cgi',      'app.cgi', '/app.cgi?a=1' ],
    [ '/app.cgi/extra/path?a=1', '/app.cgi',   '/extra/path', '/app.cgi',      'app.cgi', '/app.cgi/extra/path?a=1' ],
    [ '/pretty/route?a=1',       '/index.cgi', undef,         '/pretty/route', 'route',   '/pretty/route?a=1' ],
    [ '/a%20b/c',                '/index.cgi', undef,         '/a%20b/c',      'c',       '/a%20b/c' ],
) {
    my ( $request_uri, $script_name, $path_info, $absolute, $relative, $action ) = @$case;
    my $q = new_cgi( $request_uri, $script_name, $path_info );
    is( $q->url( -absolute => 1 ), $absolute, "REQUEST_URI=$request_uri: url(-absolute) is unchanged" );
    is( $q->url( -relative => 1 ), $relative, ' ... url(-relative) is unchanged' );
    like( $q->start_form, qr/action="\Q$action\E"/, ' ... start_form action is unchanged' );
}

done_testing();
