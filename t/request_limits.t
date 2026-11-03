#!perl

# $CGI::MAX_PARAMS and $CGI::MAX_UPLOADS limit the number of param values
# and uploaded files per request - without them a body within $POST_MAX
# could hold millions of tiny params (seconds of CPU, gigabytes of memory)
# or uploads (a temp file and open filehandle each)

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

is( $CGI::MAX_PARAMS,  10_000, 'MAX_PARAMS defaults to 10,000' );
is( $CGI::MAX_UPLOADS, 1_000,  'MAX_UPLOADS defaults to 1,000' );

sub request {
    my ( %args ) = @_;
    my $body = defined $args{body} ? $args{body} : '';
    CGI::initialize_globals();
    $CGI::APPEND_QUERY_STRING = $args{append} ? 1 : 0; # reset by initialize_globals
    local $ENV{REQUEST_METHOD} = $args{method} || 'POST';
    local $ENV{QUERY_STRING}   = defined $args{query} ? $args{query} : '';
    local $ENV{CONTENT_TYPE}   = $args{type} || 'application/x-www-form-urlencoded';
    local $ENV{CONTENT_LENGTH} = length $body;
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

sub pairs { join '&', map { "p$_=$_" } 1 .. shift }

sub multipart {
    my ( %args ) = @_;
    my $body = '';
    $body .= "--XB\r\nContent-Disposition: form-data; name=\"f$_\"\r\n\r\n$_\r\n" for 1 .. ( $args{fields} || 0 );
    $body .= "--XB\r\nContent-Disposition: form-data; name=\"u$_\"; filename=\"$_.txt\"\r\n\r\n$_\r\n" for 1 .. ( $args{uploads} || 0 );
    $body .= "--XB\r\nContent-Disposition: form-data; name=\"POSTDATA\"\r\n\r\nx\r\n" for 1 .. ( $args{reserved} || 0 );
    return $body . "--XB--\r\n";
}

sub is_within {
    my ( $q, $values, $label ) = @_;
    my $n = 0;
    $n += @$_ for values %{ $q->{param} };
    ok( ! $q->cgi_error && $n == $values, "$label: within the limit" )
        or diag( "cgi_error=" . ( $q->cgi_error // 'undef' ) . " values=$n" );
}

sub is_too_large {
    my ( $q, $label ) = @_;
    is( $q->cgi_error, '413 Request entity too large', "$label: over the limit is a 413" );
    is_deeply( [ $q->param ], [], ' ... and no params are kept' );
    is_deeply( $q->{'.tmpfiles'} || {}, {}, ' ... nor uploads' );
}

{
    local $CGI::MAX_PARAMS = 5;

    is_within(    request( method => 'GET', query => pairs(5) ), 5, 'query string' );
    is_too_large( request( method => 'GET', query => pairs(6) ),    'query string' );

    is_within(    request( body => pairs(5) ), 5, 'urlencoded body' );
    is_too_large( request( body => pairs(6) ),    'urlencoded body' );

    is_within(    request( body => 'a=1&a=2&a=3&a=4&a=5' ), 5, 'urlencoded body, repeated name' );
    is_too_large( request( body => 'a=1&a=2&a=3&a=4&a=5&a=6' ), 'urlencoded body, repeated name' );

    is_within(    request( method => 'GET', query => 'a+b+c+d+e' ), 5, 'keywords' );
    is_too_large( request( method => 'GET', query => 'a+b+c+d+e+f' ), 'keywords' );

    is_within(    request( body => pairs(3), query => 'x=1&y=2', append => 1 ), 5, 'body and appended query string together' );
    is_too_large( request( body => pairs(3), query => 'x=1&y=2&z=3', append => 1 ),    'body and appended query string together' );

    my $mp = 'multipart/form-data; boundary=XB';
    is_within(    request( type => $mp, body => multipart( fields => 3, uploads => 2 ) ), 5, 'multipart parts' );
    is_too_large( request( type => $mp, body => multipart( fields => 4, uploads => 2 ) ),    'multipart parts' );
    is_too_large( request( type => $mp, body => multipart( fields => 1, reserved => 5 ) ),   'multipart parts, including skipped ones' );

    local $CGI::MAX_PARAMS = -1;
    is_within( request( body => pairs(50) ), 50, 'MAX_PARAMS of -1: no limit' );
}

{
    local $CGI::MAX_UPLOADS = 3;
    my $mp = 'multipart/form-data; boundary=XB';
    is_within(    request( type => $mp, body => multipart( fields => 10, uploads => 3 ) ), 13, 'multipart uploads' );
    is_too_large( request( type => $mp, body => multipart( uploads => 4 ) ),                    'multipart uploads' );

    my $related = join '', "--XB\r\nContent-ID: <start>\r\n\r\n<model/>\r\n",
        ( map { "--XB\r\nContent-ID: <part$_>\r\n\r\n$_\r\n" } 1 .. 4 ), "--XB--\r\n";
    is_too_large( request( type => 'multipart/related; boundary=XB; start=start', body => $related ), 'multipart/related uploads' );

    local $CGI::MAX_UPLOADS = -1;
    is_within( request( type => $mp, body => multipart( uploads => 20 ) ), 20, 'MAX_UPLOADS of -1: no limit' );
}

{
    local $CGI::MAX_PARAMS = 3;
    my $related = join '', "--XB\r\nContent-ID: <start>\r\n\r\n<model/>\r\n",
        ( map { "--XB\r\nContent-ID: <part$_>\r\n\r\n$_\r\n" } 1 .. 3 ), "--XB--\r\n";
    is_too_large( request( type => 'multipart/related; boundary=XB; start=start', body => $related ), 'multipart/related parts' );

    # an app's own initializer isn't limited
    my $q = CGI->new( pairs(10) );
    is( scalar( () = $q->param ), 10, 'an app supplied initializer is not limited' );
}

done_testing();
