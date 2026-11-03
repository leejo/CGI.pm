#!perl

# XForms multipart/related handling: the Content-Type parameters must be
# parsed in linear time (a crafted header previously caused cubic
# backtracking), and in any order

use strict;
use warnings;

use Test::More;
use CGI;

my $boundary = 'XYZ';
my $body = join "\r\n",
    "--$boundary",
    'Content-ID: <model>',
    '',
    '<model/>',
    "--$boundary",
    'Content-ID: <part1>',
    '',
    'part one',
    "--$boundary--",
    '';

sub new_cgi {
    my ( $content_type, $req_body ) = @_;
    $req_body = $body unless defined $req_body;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = $content_type;
    local $ENV{CONTENT_LENGTH} = length $req_body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$req_body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return CGI->new;
}

for my $ct (
    qq{multipart/related; boundary="$boundary"; start="<model>"},
    qq{multipart/related;boundary=$boundary;start=<model>},
    qq{multipart/related; type="text/xml"; boundary="$boundary"; start="model"},
    # parameter order doesn't matter, previously start had to follow boundary
    qq{multipart/related; start="<model>"; boundary="$boundary"},
) {
    my $q = new_cgi( $ct );
    is( $q->param('POSTDATA'), '<model/>', "Content-Type: $ct - start part is POSTDATA" );
    my $fh = $q->upload('part1');
    ok( $fh, ' ... other part is an upload' );
    is( $fh && do { local $/; <$fh> }, 'part one', ' ... with the right contents' );
}

for my $ct (
    qq{multipart/related; boundary="$boundary"},          # no start
    qq{multipart/related; start="<model>"},               # no boundary
    qq{multipart/relatedx; boundary="$boundary"; start="<model>"},
    qq{text/plain; x=multipart/related; boundary="$boundary"; start="<model>"},
) {
    my $q = eval { new_cgi( $ct, 'raw body' ) };
    ok( $q && ! defined $q->param('XForms:Model'), "Content-Type: $ct - not treated as XForms" );
}

SKIP: {
    skip "alarm not available on $^O", 2 if $^O eq 'MSWin32';
    # repeated boundary= with no match previously took ~15s at 8KB. it is
    # now parsed (boundary=a, start=x) so the empty body is then rejected
    # as malformed, which is fine - it just mustn't take forever
    my $ct = 'multipart/related; start=x; ' . ( 'boundary=a ' x 6000 );
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm 10;
        new_cgi( $ct, '' );
        alarm 0;
    };
    alarm 0;
    isnt( $@, "timeout\n", 'crafted ' . length($ct) . ' byte Content-Type does not backtrack' );
    like( $@, qr/Malformed multipart POST/, ' ... and the empty body is rejected as normal' );
}

done_testing();
