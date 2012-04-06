use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( -cookie => 'foo' );
    my $expected = qr{^Set-Cookie: foo};
    like $got, $expected, 'cookie';
}

{
    my $q = CGI->new;
    my $got = $q->header( -cookie => [ 'foo', 'bar' ]  );
    my $expected = qr!^Set-Cookie: foo${CGI::CRLF}Set-Cookie: bar!;
    like $got, $expected, 'cookie arrayref';
}

{
    my $q = CGI->new;
    my $got = $q->header( -cookie => q{} );
    my $expected = 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'cookie empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-cookie'     => 'foo',
        '-Set-Cookie' => 'bar',
    );
    my $expected = "^Set-Cookie: foo$CGI::CRLF"
                 . "Date: [^$CGI::CRLF]+$CGI::CRLF"
                 . "Set-cookie: bar$CGI::CRLF";
    like $got, qr($expected), 'cookie & set-cookie';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-cookie'     => [ 'foo', 'bar' ],
        '-Set-Cookie' => 'baz',
    );
    my $expected = "^Set-Cookie: foo$CGI::CRLF"
                 . "Set-Cookie: bar$CGI::CRLF"
                 . "Date: [^$CGI::CRLF]+$CGI::CRLF"
                 . "Set-cookie: baz$CGI::CRLF";
    like $got, qr($expected), 'cookie & set-cookie, cookie is arrayref';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-cookie'     => q{},
        '-Set-Cookie' => 'foo',
    );
    my $expected = "Set-cookie: foo$CGI::CRLF"
                 . "Content-Type: text/html; charset=ISO-8859-1"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'cookie & set-cookie, cookie is empty string';
}

done_testing;
