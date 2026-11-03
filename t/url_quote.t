#!perl

# url()/self_url() must not contain a raw single quote: URI->canonical
# decoded the %27 that escape() produces back to a quote, letting request
# data break out of a single quoted attribute or JS string

use strict;
use warnings;

use Test::More;
use CGI;
use CGI::Util qw( unescape );

$CGI::LIST_CONTEXT_WARN = 0;

CGI::initialize_globals();
$ENV{REQUEST_METHOD} = 'GET';
$ENV{HTTP_HOST}      = 'victim.example';
$ENV{SERVER_PORT}    = 80;
$ENV{SCRIPT_NAME}    = '/app.cgi';
$ENV{PATH_INFO}      = "/it's";
$ENV{REQUEST_URI}    = "/app.cgi/it's?x=%27-alert(1)-%27";
$ENV{QUERY_STRING}   = 'x=%27-alert(1)-%27';

my $q = CGI->new;
is( $q->param('x'), "'-alert(1)-'", 'sanity: the param value contains quotes' );

my %urls = (
    'self_url'                     => $q->self_url,
    'url(-query,-path)'            => $q->url( -query => 1, -path => 1 ),
    'url(-absolute,-query,-path)'  => $q->url( -absolute => 1, -query => 1, -path => 1 ),
    'url(-relative,-query,-path)'  => $q->url( -relative => 1, -query => 1, -path => 1 ),
    'url(-absolute,-rewrite=>0,-path)' => $q->url( -absolute => 1, -rewrite => 0, -path => 1 ),
);

for my $what ( sort keys %urls ) {
    my $url = $urls{$what};
    unlike( $url, qr/'/, "$what ($url) has no raw quote" );
    like( $url, qr/%27/, ' ... it is percent encoded instead' );
    like( unescape( $url ), qr/it's/, ' ... and still decodes to the original path' )
        if $what =~ /path/ && $what !~ /relative/;
    like( unescape( $url ), qr/x='-alert\(1\)-'/, ' ... and query' )
        if $what =~ /query/;
}

done_testing();
