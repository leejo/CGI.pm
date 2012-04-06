use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( -type => 'text/plain' );
    my $expected = 'Content-Type: text/plain; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type';
}

{
    my $q = CGI->new;
    my $got = $q->header( -type => q{} );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'type empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header( -type => 'text/plain; charset=utf-8' );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'         => 'text/html',
        '-Content-Type' => 'text/plain',
    );
    my $expected = 'Content-Type: text/plain; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and content-type';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain',
        '-type'         => 'text/html',
    );
    my $expected = "Content-Type: text/html; charset=ISO-8859-1"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type and type';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain',
        '-type'        => q{}, 
    );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'content-type and type, type is empty';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => q{},
        '-type'         => 'text/plain',
    );
    my $expected = 'Content-Type: text/plain; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type and type, content-type is empty';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain; charset=utf-8',
        '-type'         => 'text/html',
    );
    my $expected = "Content-Type: text/html; charset=ISO-8859-1"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type and type, content-type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain',
        '-type'         => 'text/html; charset=utf-8',
    );
    my $expected = 'Content-Type: text/html; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type and type, type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'    => 'text/plain',
        '-charset' => 'utf-8',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'    => q{},
        '-charset' => 'utf-8',
    );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, type is empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'    => 'text/plain',
        '-charset' => q{},
    );
    my $expected = 'Content-Type: text/plain' . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, charset is empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'    => 'text/plain; charset=utf-8',
        '-charset' => 'EUC-JP',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'    => 'text/plain; charset=utf-8',
        '-charset' => 'EUC-JP',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'         => 'text/plain',
        '-charset'      => 'EUC-JP',
        '-Content-Type' => 'text/html; charset=Shift_JIS',
    );
    my $expected = 'Content-Type: text/html; charset=Shift_JIS'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset and Content-Type';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'         => 'text/plain; charset=utf-8',
        '-charset'      => 'EUC-JP',
        '-Content-Type' => 'text/html; charset=Shift_JIS',
    );
    my $expected = 'Content-Type: text/html; charset=Shift_JIS'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type & charset & Content-Type, type defines charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-type'         => q{},
        '-charset'      => 'EUC-JP',
        '-Content-Type' => 'text/html; charset=Shift_JIS',
    );
    my $expected = 'Content-Type: text/html; charset=Shift_JIS'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type & charset & Content-Type, type is empty string';
}

done_testing;
