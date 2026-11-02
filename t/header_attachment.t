#!perl

# header(-attachment => ...) puts the name in a quoted-string, so " and \
# must be escaped - an unescaped " ended it, allowing parameters (e.g. a
# different filename) to be injected when the name came from the request

use strict;
use warnings;

use Test::More;
use CGI;

my $q = CGI->new('');

sub disposition {
    my ( $attachment ) = @_;
    my ( $line ) = $q->header( -type => 'text/plain', -attachment => $attachment ) =~ /^(Content-Disposition: .*?)\r?$/m;
    return $line;
}

# parse the filename back out the way a recipient should (RFC 9110 5.6.4)
sub recipient_filename {
    my ( $line ) = @_;
    my ( $params ) = $line =~ /^Content-Disposition: attachment(.*)$/ or return;
    my @filenames;
    while ( $params =~ /\G;\s*([^=\s;]+)=("((?:[^"\\]|\\.)*)"|[^;]*)/gc ) {
        my ( $name, $raw, $quoted ) = ( lc $1, $2, $3 );
        my $value = $raw;
        ( $value = $quoted ) =~ s/\\(.)/$1/g if defined $quoted;
        push @filenames, $value if $name eq 'filename';
    }
    # anything left over means the header didn't parse as a single filename
    return ( pos( $params ) // 0 ) == length( $params ) ? @filenames : ( @filenames, 'UNPARSED' );
}

for my $name (
    'report.txt',
    'my report (final).txt',
    'report.html"; x="',
    'report.html"; filename="evil.exe',
    'a"b.txt',
    'C:\\dir\\a.txt',
    'trailing\\',
    'x\\"; filename="evil.exe',
) {
    my $line = disposition( $name );
    is_deeply( [ recipient_filename( $line ) ], [ $name ], "-attachment => '$name' gives a single filename of exactly that ($line)" );
}

is( disposition('a"b\\c.txt'), 'Content-Disposition: attachment; filename="a\\"b\\\\c.txt"', '" and \\ are escaped' );
is( disposition('report.txt'), 'Content-Disposition: attachment; filename="report.txt"', 'a plain name is unchanged' );

eval { $q->header( -attachment => "x.txt\r\nSet-Cookie: evil=1" ) };
like( $@, qr/contains a newline/, 'a newline in the name is still rejected' );

done_testing();
