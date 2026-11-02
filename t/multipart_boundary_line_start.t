#!perl

# per RFC 2046 the multipart boundary is only a delimiter at the start of a
# line - it previously matched anywhere, so content such as "x--BOUNDARY"
# started a new part (and truncated the content before it)

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

my $C = "\r\n";

sub parse {
    my ( $body ) = @_;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = 'multipart/form-data; boundary=XB';
    local $ENV{CONTENT_LENGTH} = length $body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    return eval { CGI->new };
}

sub part {
    my ( $name, $value, $filename ) = @_;
    my $cd = qq{Content-Disposition: form-data; name="$name"};
    $cd .= qq{; filename="$filename"} if defined $filename;
    return "--XB$C$cd$C$C$value$C";
}

# content with the boundary in the middle of a line
for my $value (
    "hello--XB${C}Content-Disposition: form-data; name=\"is_admin\"$C${C}1",
    "x--XB--${C}trailing",
    "---XB",
    "a--XB",
    "--${C}-XB${C}x--XB",
) {
    ( my $label = $value ) =~ s/\r\n/\\r\\n/g;
    my $body = part( comment => $value ) . part( f => "file--XB${C}data", 'x.txt' ) . part( c => 'C' ) . "--XB--$C";
    my $q = parse( $body );
    ok( $q, "value '$label': body parses" ) or next;
    is_deeply( [ $q->param ], [ qw/ comment f c / ], ' ... into the right params' );
    is( $q->param('comment'), $value, ' ... with the value intact' );
    my $fh = $q->upload('f');
    is( $fh && do { local $/; <$fh> }, "file--XB${C}data", ' ... and the upload intact' );
    is( $q->param('c'), 'C', ' ... and the following part intact' );
}

# mid-line boundaries at every offset across buffer refills
my @bad;
for my $size ( 4070 .. 4110, 8180 .. 8200 ) {
    my $value = ( 'v' x $size ) . '--XB' . ( 'w' x 10 );
    my $file  = ( 'f' x $size ) . "x--XB--$C" . ( 'g' x 10 );
    my $q = parse( part( a => $value ) . part( f => $file, 'x.txt' ) . part( c => 'C' ) . "--XB--$C" );
    my $fh = $q && $q->upload('f');
    push @bad, $size unless $q
        && $q->param('a') eq $value
        && $fh && do { local $/; <$fh> } eq $file
        && $q->param('c') eq 'C';
}
is_deeply( \@bad, [], 'mid-line boundaries spanning buffer refills are content' );

# boundaries at the start of a line are still delimiters
my %ok = (
    'a preamble'                    => [ "preamble text$C" . part( a => 1 ) . "--XB--${C}epilogue", { a => 1 } ],
    'a leading CRLF'                => [ $C . part( a => 1 ) . "--XB--$C", { a => 1 } ],
    'an empty part'                 => [ part( a => '' ) . part( b => 2 ) . "--XB--$C", { a => '', b => 2 } ],
    'no CRLF before an empty parts end' => [ "--XB${C}Content-Disposition: form-data; name=\"a\"$C$C--XB${C}Content-Disposition: form-data; name=\"b\"$C${C}2$C--XB--$C", { a => '', b => 2 } ],
    'no CRLF after the final boundary'  => [ part( a => 1 ) . "--XB--", { a => 1 } ],
    'a value ending in a CRLF'      => [ part( a => "1$C" ) . "--XB--$C", { a => "1$C" } ],
);
for my $name ( sort keys %ok ) {
    my ( $body, $expect ) = @{ $ok{$name} };
    my $q = parse( $body );
    is_deeply( $q && { map { $_ => scalar $q->param($_) } $q->param }, $expect, "a body with $name parses correctly" );
}

done_testing();
