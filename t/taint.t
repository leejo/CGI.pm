#!perl -T

# request data must stay tainted under -T, values extracted with regex
# captures (or used as hash keys) were previously untainted

use strict;
use warnings;

use Test::More;
use Scalar::Util qw( tainted );
use CGI;
use CGI::Cookie;

$CGI::LIST_CONTEXT_WARN = 0;

# %ENV set here is not tainted, so make it so
my $TAINT = substr( $^X,0,0 );
ok( tainted( $TAINT ), 'sanity: have a tainted value to work with' );

my $body = join "\r\n",
    '--XYZ',
    'Content-Disposition: form-data; name="f"; filename="dir/x.txt"',
    'Content-Type: text/plain',
    '',
    'data',
    '--XYZ',
    'Content-Disposition: form-data; name="a"',
    '',
    'plain',
    '--XYZ--',
    '';

my %env = (
    REQUEST_METHOD => 'POST',
    CONTENT_TYPE   => 'multipart/form-data; boundary=XYZ',
    CONTENT_LENGTH => length $body,
    QUERY_STRING   => 'u=1',
    SCRIPT_NAME    => '/s.cgi',
    PATH_INFO      => '/a/b',
    # differs from SCRIPT_NAME.PATH_INFO by repeated slashes, so path_info
    # and script_name are extracted from it
    REQUEST_URI    => '/s.cgi/a//b?u=1',
    HTTP_HOST      => 'victim.example',
    HTTP_COOKIE    => 'sess=abc; expires=Wed, 01 Jan 2031 00:00:00 GMT',
    HTTP_ACCEPT    => 'text/html;q=0.9, */*;q=0.1',
);
$ENV{$_} = $env{$_} . $TAINT for keys %env;

my @hook_names;
my $q;
{
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    $q = CGI->new( sub { push @hook_names, $_[0] } );
}
my $fh = $q->upload('f');
ok( $fh, 'have an upload' );

sub all_tainted {
    my ( $what, @values ) = @_;
    ok( @values && ! grep( { ! tainted( $_ ) } @values ), "$what is tainted" )
        or diag explain [ map { [ $_, tainted( $_ ) ] } @values ];
}

all_tainted( 'param value',              scalar $q->param('a') );
all_tainted( 'param names',              $q->param );
all_tainted( 'upload filename',          "$fh" );
all_tainted( 'upload_hook filename',     @hook_names );
all_tainted( 'uploadInfo values',        values %{ $q->uploadInfo($fh) } );
all_tainted( 'path_info',                $q->path_info );
all_tainted( 'script_name',              $q->script_name );
all_tainted( 'url_param value',          scalar $q->url_param('u') );
all_tainted( 'url_param names',          $q->url_param );
all_tainted( 'cookie value',             scalar $q->cookie('sess') );
all_tainted( 'cookie names',             $q->cookie );
all_tainted( 'raw_cookie value',         scalar $q->raw_cookie('sess') );
all_tainted( 'Accept() types',           $q->Accept );
all_tainted( 'Accept(type) preference',  $q->Accept('text/html') );
all_tainted( 'url() and self_url()',     $q->url, $q->self_url );

my %cookies = CGI::Cookie->parse( $ENV{HTTP_COOKIE} );
ok( $cookies{expires}, 'have a cookie named expires' );
all_tainted( 'CGI::Cookie expires name and value', $cookies{expires}->name, $cookies{expires}->value );

# and the values themselves are still correct
is( "$fh", 'x.txt', 'upload filename is correct' );
is( $q->path_info, '/a//b', 'path_info is correct' );
is( $cookies{expires}->value, 'Wed, 01 Jan 2031 00:00:00 GMT', 'expires cookie value is correct' );
is( $q->Accept('text/html'), '0.9', 'Accept preference is correct' );

done_testing();
