#!perl

# Content-Disposition parameters must be parsed left to right: the name and
# filename were found by searching the whole value, so they could be read
# from inside another parameter's quoted value

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

sub parse {
    my ( $disposition ) = @_;
    my $body = "--XB\r\nContent-Disposition: $disposition\r\n\r\nV\r\n--XB--\r\n";
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = 'multipart/form-data; boundary=XB';
    local $ENV{CONTENT_LENGTH} = length $body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";
    binmode STDIN;
    my $q = CGI->new;
    my ( $name ) = $q->param;
    my $value = defined $name ? $q->param( $name ) : undef;
    return ( $name, ref $value ? "upload:$value" : $value );
}

for my $case (
    # [ Content-Disposition, expected name, expected value / upload:filename ]

    # a parameter inside another's quoted value is not a parameter
    [ 'form-data; filename="x;name=admin"; name=user',  'user', 'upload:x;name=admin' ],
    [ 'form-data; filename="x name=admin"; name="user"', 'user', 'upload:x name=admin' ],
    [ 'form-data; name="x filename=evil.txt"',          'x filename=evil.txt',  'V' ],
    [ 'form-data; name="x; filename=evil.txt"',         'x; filename=evil.txt', 'V' ],
    [ 'form-data; name="a"; x="; filename=evil.txt"',   'a', 'V' ],
    [ 'form-data; name="a"; x="; name=b"',              'a', 'V' ],

    # normal forms
    [ 'form-data; name="a"',                            'a', 'V' ],
    [ 'form-data; name=a',                              'a', 'V' ],
    [ 'form-data;name="a"',                             'a', 'V' ],
    [ 'form-data; name="a"; filename="x.txt"',          'a', 'upload:x.txt' ],
    [ 'form-data; filename="x.txt"; name="a"',          'a', 'upload:x.txt' ],
    [ 'form-data; name=a; filename=x.txt',              'a', 'upload:x.txt' ],
    [ 'form-data; name="a" ; filename="x.txt"',         'a', 'upload:x.txt' ],
    [ 'form-data; name="a"; filename="a;b.txt"',        'a', 'upload:a;b.txt' ],
    [ 'form-data; name="why do \"this\""',              'why do \"this\"', 'V' ],
    [ qq{form-data; name="hate ()<>@,;:[]?={}\t/\\""},  qq{hate ()<>@,;:[]?={}\t/\\"}, 'V' ],
    [ 'form-data; name="a"; filename=""',               'a', 'V' ],

    # existing behaviour that is kept
    [ 'form-data; name="a"; name="b"',                  'a', 'V' ], # first wins
    [ 'form-data; name=a/b',                            'a', 'V' ], # unquoted token
    [ 'form-data; name="a"; filename=x-y.txt',          'a', 'upload:x' ],
    [ 'form-data; name="a"; filename*=UTF-8\'\'x.txt',  'a', 'V' ],
    [ 'form-data; name="a"; filename="unterminated',    'a', 'V' ],
) {
    my ( $disposition, $name, $value ) = @$case;
    my ( $got_name, $got_value ) = parse( $disposition );
    is( $got_name,  $name,  "Content-Disposition: $disposition - name" );
    is( $got_value, $value, ' ... and value' );
}

done_testing();
