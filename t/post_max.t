#!perl

# $CGI::POST_MAX has a sensible default, and is enforced both up front
# (via CONTENT_LENGTH) and while reading multipart bodies that have no
# CONTENT_LENGTH (chunked transfer encoding)

use strict;
use warnings;

use Test::More;
use CGI;

is( $CGI::POST_MAX, 1024 * 1024 * 128, 'POST_MAX defaults to 128MB' );

my $boundary = 'XYZ';

sub multipart_body {
    my ( $file_size ) = @_;
    return join "\r\n",
        "--$boundary",
        'Content-Disposition: form-data; name="a"',
        '',
        'hello',
        "--$boundary",
        'Content-Disposition: form-data; name="f"; filename="x.txt"',
        'Content-Type: text/plain',
        '',
        ( 'x' x $file_size ),
        "--$boundary--",
        '';
}

sub new_cgi {
    my ( %args ) = @_;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = $args{content_type};
    local $ENV{QUERY_STRING}   = '';
    local $ENV{CONTENT_LENGTH} = $args{content_length};
    delete $ENV{CONTENT_LENGTH} if ! defined $args{content_length};

    local *STDIN;
    open STDIN, '<', \$args{body} or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

subtest 'CONTENT_LENGTH over POST_MAX' => sub {
    local $CGI::POST_MAX = 100;
    my $q = new_cgi(
        content_type   => 'application/x-www-form-urlencoded',
        content_length => 101,
        body           => 'a=' . ( 'x' x 99 ),
    );
    is( $q->cgi_error, '413 Request entity too large', 'cgi_error is set' );
    is_deeply( [ $q->param ], [], ' ... and no params are parsed' );

    $q = new_cgi(
        content_type   => 'application/octet-stream',
        content_length => 101,
        body           => 'x' x 101,
    );
    is( $q->cgi_error, '413 Request entity too large', 'cgi_error is set for other content types' );
    is_deeply( [ $q->param ], [], ' ... and no (empty) POSTDATA param is added' );
};

my $multipart = "multipart/form-data; boundary=$boundary";

subtest 'chunked multipart under POST_MAX' => sub {
    local $CGI::POST_MAX = 10_000;
    my $q  = new_cgi( content_type => $multipart, body => multipart_body( 5000 ) );
    is( $q->cgi_error, undef, 'no cgi_error' );
    is( $q->param('a'), 'hello', ' ... field is parsed' );
    my $fh = $q->upload('f');
    ok( $fh, ' ... upload is parsed' );
    is( length( do { local $/; <$fh> } ), 5000, ' ... and upload is complete' );
};

subtest 'chunked multipart over POST_MAX' => sub {
    local $CGI::POST_MAX = 1000;
    my $q = new_cgi( content_type => $multipart, body => multipart_body( 5000 ) );
    is( $q->cgi_error, '413 Request entity too large', 'cgi_error is set' );
    is_deeply( [ $q->param ], [], ' ... and no params are kept' );
    ok( ! $q->upload('f'), ' ... and no uploads are kept' );
    is_deeply( $q->{'.tmpfiles'}, {}, ' ... and no tmpfiles are kept' );
};

subtest 'chunked multipart with POST_MAX disabled' => sub {
    local $CGI::POST_MAX = -1;
    my $q = new_cgi( content_type => $multipart, body => multipart_body( 50_000 ) );
    is( $q->cgi_error, undef, 'no cgi_error' );
    is( $q->param('a'), 'hello', ' ... field is parsed' );
    my $fh = $q->upload('f');
    is( length( do { local $/; <$fh> } ), 50_000, ' ... and upload is complete' );
};

subtest 'chunked multipart/related over POST_MAX' => sub {
    local $CGI::POST_MAX = 1000;
    my $body = join "\r\n",
        "--$boundary",
        'Content-ID: <model>',
        '',
        '<model/>',
        "--$boundary",
        'Content-ID: <part1>',
        '',
        ( 'x' x 5000 ),
        "--$boundary--",
        '';
    my $q = new_cgi(
        content_type => qq{multipart/related; boundary="$boundary"; start="<model>"},
        body         => $body,
    );
    is( $q->cgi_error, '413 Request entity too large', 'cgi_error is set' );
    is_deeply( [ $q->param ], [], ' ... and no params are kept' );
};

subtest 'malformed multipart still dies' => sub {
    local $CGI::POST_MAX = 1000;
    eval { new_cgi( content_type => $multipart, content_length => 9, body => 'not multi' ) };
    like( $@, qr/Malformed multipart POST/, 'non POST_MAX errors are rethrown' );

    eval { new_cgi( content_type => $multipart, body => 'not multi' ) };
    like( $@, qr/Malformed multipart POST/, ' ... including when chunked' );
};

done_testing();
