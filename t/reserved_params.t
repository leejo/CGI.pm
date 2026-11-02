#!perl

# POSTDATA, PUTDATA, PATCHDATA and XForms:Model hold the raw request body
# (or XForms model) - a client must not be able to set them through the
# query string, a form field or a multipart/related part, as an app could
# then not tell attacker supplied values from the real body (e.g. a plain
# HTML form posting POSTDATA={"admin":true} to a JSON endpoint)

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

my @reserved = ( 'POSTDATA', 'PUTDATA', 'PATCHDATA', 'XForms:Model' );
my $spoof    = join '&', map { CGI::escape($_) . '=evil' } @reserved;

sub request {
    my ( %args ) = @_;
    my $body = defined $args{body} ? $args{body} : '';
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = $args{method};
    local $ENV{QUERY_STRING}   = defined $args{query} ? $args{query} : '';
    local $ENV{CONTENT_TYPE}   = $args{type};
    local $ENV{CONTENT_LENGTH} = length $body;
    delete $ENV{CONTENT_TYPE} unless defined $args{type};
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

sub reserved_values {
    my ( $q ) = @_;
    return { map { $_ => [ $q->multi_param($_) ] } grep { defined $q->param($_) } @reserved };
}

{
    my $q = request( method => 'GET', query => "$spoof&a=1" );
    is_deeply( reserved_values( $q ), {}, 'GET: reserved names in the query string are ignored' );
    is( $q->param('a'), 1, ' ... other params are kept' );
}

{
    my $q = request( method => 'POST', type => 'application/x-www-form-urlencoded', body => "$spoof&a=1" );
    is_deeply( reserved_values( $q ), {}, 'urlencoded POST: reserved names in the body are ignored' );
    is( $q->param('a'), 1, ' ... other params are kept' );
}

{
    my $body = join '',
        ( map { "--XB\r\nContent-Disposition: form-data; name=\"$_\"\r\n\r\nevil\r\n" } @reserved ),
        "--XB\r\nContent-Disposition: form-data; name=\"POSTDATA\"; filename=\"x.json\"\r\n\r\nevil\r\n",
        "--XB\r\nContent-Disposition: form-data; name=\"a\"\r\n\r\n1\r\n",
        "--XB\r\nContent-Disposition: form-data; name=\"f\"; filename=\"f.txt\"\r\n\r\nfile\r\n",
        "--XB--\r\n";
    my $q = request( method => 'POST', type => 'multipart/form-data; boundary=XB', body => $body, query => $spoof );
    is_deeply( reserved_values( $q ), {}, 'multipart POST: reserved names as fields, uploads or in the query string are ignored' );
    is( $q->param('a'), 1, ' ... other fields are kept' );
    my $fh = $q->upload('f');
    is( $fh && do { local $/; <$fh> }, 'file', ' ... as are other uploads' );
}

{
    my $q = request( method => 'POST', type => 'application/json', body => '{"real":1}', query => $spoof );
    is_deeply( reserved_values( $q ), { POSTDATA => [ '{"real":1}' ] }, 'JSON POST: POSTDATA is the body, only' );
}

for my $method ( 'PUT', 'PATCH' ) {
    my $q = request( method => $method, type => 'application/json', body => '{"real":1}', query => $spoof );
    is_deeply( reserved_values( $q ), { "${method}DATA" => [ '{"real":1}' ] }, "$method: ${method}DATA is the body, only" );
}

{
    my $q = request( method => 'POST', type => 'application/xml', body => '<model/>', query => "$spoof&a=1" );
    is_deeply( reserved_values( $q ), { 'XForms:Model' => [ '<model/>' ], POSTDATA => [ '<model/>' ] }, 'XForms POST: XForms:Model and POSTDATA are the body, only' );
    is( $q->param('a'), 1, ' ... and other query string params are kept' );
}

{
    my $body = join '',
        "--XB\r\nContent-ID: <start>\r\n\r\n<model/>\r\n",
        "--XB\r\nContent-ID: <XForms:Model>\r\n\r\nevil\r\n",
        "--XB\r\nContent-ID: <POSTDATA>\r\n\r\nevil\r\n",
        "--XB\r\nContent-ID: <part1>\r\n\r\npart one\r\n",
        "--XB--\r\n";
    my $q = request( method => 'POST', type => 'multipart/related; boundary=XB; start=start', body => $body, query => $spoof );
    is_deeply( reserved_values( $q ), { 'XForms:Model' => [ '<model/>' ], POSTDATA => [ '<model/>' ] }, 'multipart/related: parts using reserved names are ignored' );
    my $fh = $q->upload('part1');
    is( $fh && do { local $/; <$fh> }, 'part one', ' ... other parts are kept' );
}

{
    # an app's own initializer, e.g. restoring saved state, can use them
    my $q = CGI->new('POSTDATA=saved&a=1');
    is( $q->param('POSTDATA'), 'saved', 'an app supplied initializer can set POSTDATA' );
}

done_testing();
