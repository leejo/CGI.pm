#!perl

# the upload filename is client supplied, so any path in it must be
# removed to prevent path traversal by applications that use it

use strict;
use warnings;

use Test::More;
use CGI;

my $boundary = 'XYZ';

my @cases = (
    # [ raw Content-Disposition filename, expected filename ]
    [ '"x.txt"',                       'x.txt' ],
    [ 'x.txt',                         'x.txt' ],
    [ '"../../../etc/passwd"',         'passwd' ],
    [ '"/etc/passwd"',                 'passwd' ],
    [ '"C:\\Users\\me\\My Docs\\x.txt"', 'x.txt' ],
    [ '"..\\..\\boot.ini"',            'boot.ini' ],
    [ '"dir/sub\\mixed/x.txt"',        'x.txt' ],
    [ qq{"evil\0.txt"},                'evil.txt' ],
    [ qq{"tab\tname.txt"},             'tabname.txt' ],
    [ '"..."',                         '...' ],
    [ qq{"r\xc3\xa9sum\xc3\xa9.pdf"},  "r\xc3\xa9sum\xc3\xa9.pdf" ],
    [ '".."',                          'upload' ],
    [ '"."',                           'upload' ],
    [ '"dir/"',                        'upload' ],
    [ '"/"',                           'upload' ],
    [ '..',                            'upload' ],
    # a name that is false in perl must not be lost
    [ '"dir/0"',                       '0' ],
    [ '"0.txt"',                       '0.txt' ],
);

my @parts;
for my $i ( 0 .. $#cases ) {
    push @parts,
        "--$boundary",
        qq{Content-Disposition: form-data; name="f$i"; filename=$cases[$i][0]},
        'Content-Type: text/plain',
        '',
        "content $i";
}
my $body = join( "\r\n", @parts, "--$boundary--", '' );

sub parse_upload {
    my %hook_names;
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = "multipart/form-data; boundary=$boundary";
    local $ENV{CONTENT_LENGTH} = length $body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    my $q = CGI->new( sub { $hook_names{ $_[0] }++ } );
    return ( $q, \%hook_names );
}

ok( $CGI::SANITIZE_UPLOAD_FILENAMES, 'SANITIZE_UPLOAD_FILENAMES is on by default' );

for my $sanitize ( 1, 0 ) {
    local $CGI::SANITIZE_UPLOAD_FILENAMES = $sanitize;
    my ( $q, $hook_names ) = parse_upload();

    for my $i ( 0 .. $#cases ) {
        my ( $raw, $expect ) = @{ $cases[$i] };
        ( my $raw_value = $raw ) =~ s/^"(.*)"$/$1/s;
        # opting out restores the old behaviour of the raw client value
        $expect = $raw_value if ! $sanitize;

        ( my $label = $raw ) =~ s/([^ -~])/sprintf('\\x%02x',ord $1)/ge;
        $label = "SANITIZE_UPLOAD_FILENAMES=$sanitize, filename=$label";

        my $fh = $q->upload("f$i");
        ok( defined $fh, "$label: is an upload" ) or next;
        is( "$fh", $expect, " ... filename is correct" );
        is( $q->param("f$i"), $expect, ' ... param() returns the same' );
        ok( $hook_names->{$expect}, ' ... upload_hook is passed the same' );
        is( do { local $/; <$fh> }, "content $i", ' ... and contents are intact' );

        like(
            $q->uploadInfo($fh)->{'Content-Disposition'},
            qr/filename="?\Q$raw_value\E"?/,
            ' ... raw filename is still available via uploadInfo',
        );
    }
}

done_testing();
